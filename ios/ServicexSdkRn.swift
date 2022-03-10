import serviceX
import Combine


extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

@objc(ServicexSdkRn)
class ServicexSdkRn: RCTEventEmitter {
    
    var listOffer: [CCOfferData] = [CCOfferData]()
    var userInput: NSDictionary?
    private var cancellables = Set<AnyCancellable>()
    var pushClaimResponseCallback: ((Result<Void, Error>) -> Void)?
    
    class UnmanagedError : Error {
        var error: String
        
        init() {
            self.error = "Unmanaged error"
        }
    }
    
    @objc(initialize:environment:marketName:packageVersion:theme:)
    func initialize(apiKey:String, environment: String, marketName: String, packageVersion: String,theme: NSDictionary) -> Void {
        let envDict = ["DEV": CCEnvironmentType.DEV, "PRODUCTION": .PRODUCTION,"SANDBOX":  .SANDBOX,"SIT": .SIT,"UAT": .UAT]
        let themeData = parseThemeObject(value: theme)
        let config = serviceXConfig(apiKey: apiKey, env: envDict[environment]!, appName: marketName, theme: themeData ?? serviceXTheme.default)
        CredifyServiceX.configure(config)
        CredifyServiceX.updateUserAgent("servicex/rn/ios/\(packageVersion)")
        CredifyServiceX.applicationDidBecomeActive(UIApplication.shared)
    }
    
    func parseUserProfile(value:NSDictionary) -> CCPlatformUserModel? {
        guard let v = value as? [String:Any] else { return nil }
        if let id = v["id"] as? Int {
            let firstName = v["first_name"] as? String ?? ""
            let lastName =  v["last_name"] as? String ?? ""
            let email = v["email"] as? String ?? ""
            let credifyId = v["credify_id"] as? String
            let phoneNumber = v["phone_number"] as? String
            let phoneCountryCode = v["country_code"] as? String
            
            return CCPlatformUserModel(id: "\(id)",
                                       firstName: firstName,
                                       lastName: lastName,
                                       email: email,
                                       credifyId: credifyId,
                                       countryCode: phoneCountryCode ?? "",
                                       phoneNumber: phoneNumber ?? "")
        }
        return nil
    }
    
    // In case we need to trigger it manually in AppDelegate Callback
    @objc(appDidBecomeActive:)
    func appDidBecomeActive(application: UIApplication) -> Void {
        CredifyServiceX.applicationDidBecomeActive(application)
    }
    
    func parseThemeObject(value:NSDictionary) -> serviceXTheme? {
        guard let v = value as? [String:Any] else { return nil }
        
        let primaryBrandyStart = v["primaryBrandyStart"] as? String
        let primaryBrandyEnd =  v["primaryBrandyEnd"] as? String
        let primaryText = v["primaryText"] as? String
        let secondaryActive = v["secondaryActive"] as? String
        let secondaryText = v["secondaryText"] as? String
        let secondaryComponentBackground = v["secondaryComponentBackground"] as? String
        let secondaryBackground = v["secondaryBackground"] as? String
        let inputFieldRadius = v["inputFieldRadius"] as? Double ?? serviceXTheme.default.inputFieldRadius
        let pageHeaderRadius = v["pageHeaderRadius"] as? Double ?? serviceXTheme.default.pageHeaderRadius
        let buttonRadius = v["buttonRadius"] as? Double ?? serviceXTheme.default.buttonRadius
        let shadowHeight = v["shadowHeight"] as? CGFloat ?? serviceXTheme.default.shadowHeight
        
        let color = ThemeColor(primaryBrandyStart: primaryBrandyStart != nil ? UIColor(hexString: primaryBrandyStart!): ThemeColor.default.primaryBrandyStart,
                               primaryBrandyEnd: primaryBrandyEnd != nil ? UIColor(hexString: primaryBrandyEnd!): ThemeColor.default.primaryBrandyEnd,
                               primaryText: primaryText != nil ? UIColor(hexString: primaryText!): ThemeColor.default.primaryText,
                               secondaryActive: secondaryActive != nil ? UIColor(hexString: secondaryActive!): ThemeColor.default.secondaryActive,
                               secondaryText: secondaryText != nil ? UIColor(hexString: secondaryText!): ThemeColor.default.secondaryText,
                               secondaryComponentBackground: secondaryText != nil ? UIColor(hexString: secondaryComponentBackground!): ThemeColor.default.secondaryComponentBackground,
                               secondaryBackground: secondaryBackground != nil ? UIColor(hexString: secondaryBackground!): ThemeColor.default.secondaryBackground)
        
        let theme = serviceXTheme(color: color,
                                  font: ThemeFont.default,
                                  icon: ThemeIcon.default,
                                  inputFieldRadius: inputFieldRadius,
                                  pageHeaderRadius: pageHeaderRadius,
                                  buttonRadius: buttonRadius,
                                  shadowHeight: shadowHeight)
        return theme
    }
    
    @objc override func supportedEvents() -> [String]! {
        return ["onRedeemCompleted"]
    }
    
    @objc(setUserProfile:)
    func setUserProfile(value:NSDictionary) {
        userInput = value
    }
    
    struct OfferListRes: Codable {
        let credifyId: String?
        let offerList: [CCOfferData]
    }
    
    @objc(getOfferList:resolve:rejecter:)
    func getOfferList(productTypes: NSArray, resolve: @escaping(RCTPromiseResolveBlock), rejecter reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        let user = self.parseUserProfile(value: ui)
        guard let _productTypes = productTypes as? [String] else { reject("CredifySDK error","productTypes must be a string array", nil)
            return
        }
        
        CredifyServiceX.offer.getOffers(
            phoneNumber: user?.phoneNumber,
            countryCode: user?.countryCode,
            localId: user!.id,
            credifyId: user?.credifyId,
            productTypes: _productTypes
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { offers in
                self.listOffer = offers
                let offerListRes = OfferListRes(credifyId: user?.credifyId, offerList: offers)
                let jsonEncoder = JSONEncoder()
                do{
                    
                    let jsonData = try jsonEncoder.encode(offerListRes)
                    let json = String(data: jsonData, encoding: .utf8)
                    resolve(json)
                }catch let error as NSError {
                    reject("CredifySDK error","parsing json error", error)
                }
            }).store(in: &cancellables)
        
    }
    
    @objc(clearCache)
    func clearCache(){
        CredifyServiceX.resetSession()
    }
    
    @objc(setPushClaimRequestStatus:)
    func setPushClaimRequestStatus(isSuccess: Bool){
        if isSuccess {
            self.pushClaimResponseCallback?(.success(()))
        }else {
            print("push claim token issue")
            self.pushClaimResponseCallback?(.failure(UnmanagedError.init()))
        }
        // Dereference callback to avoid memory leak
        self.pushClaimResponseCallback = nil
    }
    
    
    func redemptionResultString(type: RedemptionResult) -> String {
        switch type {
        case .completed:
            return "completed"
        case .canceled:
            return "canceled"
        case .pending:
            return "pending"
        @unknown default:
            return "unknown"
            
        }
    }
    
    @objc(showOfferDetail:pushClaimCB:)
    func showOfferDetail(offerId: String, pushClaimCB:@escaping(RCTResponseSenderBlock)) {
        
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }
        
        let offer = self.listOffer.first(where: { item -> Bool in
            item.id == offerId
        })
        
        guard let offer = offer else {
            print("Offer was not found")
            return
        }
        
        
        let task = { (credifyId: String) -> Future<Void, Error> in
            return Future() { promise in
                pushClaimCB([user.id, credifyId])
                self.pushClaimResponseCallback = promise
            }
        }
        
        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }
            
            CredifyServiceX.offer.presentModally(
                from: vc,
                offer: offer,
                userProfile: user,
                pushClaimTokensTask: task
            ) { [weak self] result in
                let payload = ["status": self?.redemptionResultString(type: result)]
                self?.sendEvent(withName: "onRedeemCompleted", body:payload)
            }
        }
    }
    
    @objc(showPassport:)
    func showPassport(dismissCB:@escaping(RCTResponseSenderBlock)){
        guard let ui = userInput else {
            print("User input was not found")
            return
        }
        guard let user = self.parseUserProfile(value: ui) else {
            print("User was not found")
            return
        }
        
        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }
            CredifyServiceX.offer.showPassport(from: vc, userProfile: user) {
                dismissCB([])
            }
        }
    }
    
}
