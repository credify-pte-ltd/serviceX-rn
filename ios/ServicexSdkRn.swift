import serviceX

@objc(ServicexSdkRn)
class ServicexSdkRn: NSObject {
    
    var listOffer: [CCOfferData] = [CCOfferData]()
    var pushClaimResponseCallback: ((Bool) -> Void)?
    var userInput: NSDictionary?
    
    @objc(initialize:environment:marketName:packageVersion:)
    func initialize(apiKey:String, environment: String, marketName: String, packageVersion: String) -> Void {
        let envDict = ["DEV":  EnvironmentType.DEV, "PRODUCTION":  EnvironmentType.PRODUCTION,"SANDBOX":  EnvironmentType.SANDBOX,"SIT":  EnvironmentType.SIT,"UAT":  EnvironmentType.UAT]
        
        let config = CredifyServiceXConfiguration(apiKey: apiKey,
                                                  environment: envDict[environment]!, appName: marketName)
        CredifyServiceX.shared.config(with: config)
        CredifyServiceX.shared.applicationDidBecomeActive(UIApplication.shared)
        CredifyServiceX.shared.setVersion(version: "servicex/rn/android/\(packageVersion)")
    }
    
    // In case we need to trigger it manually in AppDelegate Callback
    @objc(appDidBecomeActive:)
    func appDidBecomeActive(application: UIApplication) -> Void {
        CredifyServiceX.shared.applicationDidBecomeActive(application)
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
        let user = self.parseUserProfile(value: userInput!)
        guard let _productTypes = productTypes as? [String] else { reject("CredifySDK error","productTypes must be a string array", nil)
            return
        }
        
        print(_productTypes)
        ServiceXService.shared.offerService.getOffers(phoneNumber: user?.phoneNumber,
                                                      countryCode: user?.countryCode,
                                                      localId: user!.id,
                                                      credifyId: user?.credifyId, productTypes:_productTypes) { [weak self] result in
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
                reject("CredifySDK error", "get offerlist error", error)
            }
        }
    }
    
    @objc(clearCache)
    func clearCache(){
        ServiceXService.shared.sessionService.resetSession()
    }
    
    @objc(setPushClaimRequestStatus:)
    func setPushClaimRequestStatus(isSuccess: Bool){
        self.pushClaimResponseCallback?(isSuccess)
        // Dereference callback to avoid memory leak
        self.pushClaimResponseCallback = nil
    }
    
    @objc(showOfferDetail:pushClaimCB:)
    func showOfferDetail(offerId: String, pushClaimCB:@escaping(RCTResponseSenderBlock)) {
        let user = self.parseUserProfile(value: userInput!)
        let offer = self.listOffer.first(where: { item -> Bool in
            item.id == offerId
        })
        DispatchQueue.main.async {
            ServiceXService.shared.offerService.presentModally(from: UIApplication.shared.keyWindow!.rootViewController!, offer: offer!, userProfile: user!){ credifyId, result in
                // Demo Market call push claim token
                pushClaimCB([user?.id, credifyId])
                self.pushClaimResponseCallback = result
            }
            
            ServiceXService.shared.offerService.redemptionResult = { result in
                print(result)
            }
        }
    }
    
    //    @objc(showReferral)
    //    func showReferral(){
    //
    //    }
    
    @objc(showPassport:)
    func showPassport(dismissCB:@escaping(RCTResponseSenderBlock)){
        let user = self.parseUserProfile(value: userInput!)
        DispatchQueue.main.async {
            ServiceXService.shared.offerService.showPassport(from: UIApplication.shared.keyWindow!.rootViewController!, userProfile: user!) {
                dismissCB([])
            }
        }
    }
    
}
