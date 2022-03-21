import Credify

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
    
    private var offerIns: Any?
    private var passportIns: Any?
    var listOffer: [OfferData] = [OfferData]()
    var userInput: NSDictionary?
    var pushClaimResponseCallback: ((Bool) -> Void)?
    
    class UnmanagedError : Error {
        var error: String
        
        init() {
            self.error = "Unmanaged error"
        }
    }
    
    @objc(initialize:environment:marketName:packageVersion:theme:)
    func initialize(apiKey:String, environment: String, marketName: String, packageVersion: String,theme: NSDictionary) -> Void {
        
        passportIns = serviceX.Passport()
        offerIns = serviceX.Offer()
        
        let envDict = ["DEV": CredifyEnvs.dev, "PRODUCTION": .production,"SANDBOX":  .sandbox,"SIT": .sit,"UAT": .uat]
        let config = serviceXConfig(apiKey: apiKey, env: envDict[environment]!, appName: marketName)
        serviceX.configure(config)
        //serviceX.updateUserAgent("servicex/rn/ios/\(packageVersion)")
    }
    
    func parseUserProfile(value:NSDictionary) -> CredifyUserModel? {
        guard let v = value as? [String:Any] else { return nil }
        if let id = v["id"] as? Int {
            let firstName = v["first_name"] as? String ?? ""
            let lastName =  v["last_name"] as? String ?? ""
            let email = v["email"] as? String ?? ""
            let credifyId = v["credify_id"] as? String
            let phoneNumber = v["phone_number"] as? String
            let phoneCountryCode = v["country_code"] as? String
            
            return CredifyUserModel(id: "\(id)",
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    credifyId: credifyId,
                                    countryCode: phoneCountryCode ?? "",
                                    phoneNumber: phoneNumber ?? "")
        }
        return nil
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
        let offerList: [OfferData]
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
        
        if let offerIns = offerIns as? serviceX.Offer
        {
            offerIns.getOffers(user: user, productTypes: _productTypes) { [weak self] result in
                switch result {
                case .success(let offers):
                    self?.listOffer = offers
                    let offerListRes = OfferListRes(credifyId: user?.credifyId, offerList: offers)
                    let jsonEncoder = JSONEncoder()
                    do{
                        
                        let jsonData = try jsonEncoder.encode(offerListRes)
                        let json = String(data: jsonData, encoding: .utf8)
                        resolve(json)
                    }catch let error as NSError {
                        reject("CredifySDK error","parsing json error", error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc(clearCache)
    func clearCache(){
        //serviceX.resetSession()
    }
    
    @objc(setPushClaimRequestStatus:)
    func setPushClaimRequestStatus(isSuccess: Bool){
        self.pushClaimResponseCallback?(isSuccess)
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
        
        let offerData = self.listOffer.first(where: { item -> Bool in
            item.id == offerId
        })
        
        guard let offerData = offerData else {
            print("Offer was not found")
            return
        }
        
      
        
        DispatchQueue.main.async {
            guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
                print("There is no view controller")
                return
            }
            
            let task: ((String, ((Bool) -> Void)?) -> Void) = { credifyId, result in
                pushClaimCB([user.id, credifyId])
                self.pushClaimResponseCallback = result
            }
            
            if let offerIns = self.offerIns as? serviceX.Offer
            {
                offerIns.presentModally(
                    from: vc,
                    offer: offerData,
                    userProfile: user,
                    pushClaimTokensTask: task
                ) { [weak self] result in
                    let payload = ["status": self?.redemptionResultString(type: result)]
                    self?.sendEvent(withName: "onRedeemCompleted", body:payload)
                }
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
            
            if let passportIns = self.passportIns as? serviceX.Passport
            {
                passportIns.showMypage(from: vc, user: user) {
                    dismissCB([])
                }
            }
            
        }
    }
    
}
