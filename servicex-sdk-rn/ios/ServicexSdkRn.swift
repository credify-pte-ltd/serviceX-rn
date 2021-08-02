import CredifyServiceXSDK

@objc(ServicexSdkRn)
class ServicexSdkRn: NSObject {
    
    var listOffer: [OfferData] = [OfferData]()
    var pushClaimResponseCallback: ((Bool) -> Void)?
    var userInput: NSDictionary?
    
    @objc(initialize:environment:marketName:)
    func initialize(apiKey:String, environment: String, marketName: String) -> Void {
        let envDict = ["DEV":  EnvironmentType.DEV, "PRODUCTION":  EnvironmentType.PRODUCTION,"SANDBOX":  EnvironmentType.SANDBOX,"SIT":  EnvironmentType.SIT,"UAT":  EnvironmentType.UAT]
        
        let config = CredifyServiceXConfiguration(apiKey: apiKey,
                                                  environment: envDict[environment]!, appName: marketName)
        CredifyServiceX.shared.config(with: config)
        CredifyServiceX.shared.applicationDidBecomeActive(UIApplication.shared)
    }
    
    // In case we need to trigger it manually in AppDelegate Callback
    @objc(appDidBecomeActive:)
    func appDidBecomeActive(application: UIApplication) -> Void {
        CredifyServiceX.shared.applicationDidBecomeActive(application)
    }
    
    func parseUserProfile(value:NSDictionary) -> PlatformUserModel? {
        guard let v = value as? [String:Any] else { return nil }
        if let id = v["id"] as? Int {
            let firstName = v["first_name"] as? String ?? ""
            let lastName =  v["last_name"] as? String ?? ""
            let email = v["email"] as? String ?? ""
            let credifyId = v["credify_id"] as? String
            let phoneNumber = v["phone_number"] as? String
            let phoneCountryCode = v["country_code"] as? String
            
            return PlatformUserModel(id: "\(id)",
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
        let offerList: [OfferData]
    }
    
    @objc(getOfferList:rejecter:)
    func getOfferList(_ resolve: @escaping(RCTPromiseResolveBlock), rejecter reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        let user = self.parseUserProfile(value: userInput!)
        OfferManager.shared.getOffersConsumer(user: user!) { [weak self] result in
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
        
    }
    
    @objc(setPushClaimRequestStatus:)
    func setPushClaimRequestStatus(isSuccess: Bool){
        self.pushClaimResponseCallback?(isSuccess)
    }
    
    @objc(showOfferDetail:pushClaimCB:)
    func showOfferDetail(offerId: String, pushClaimCB:@escaping(RCTResponseSenderBlock)) {
        let user = self.parseUserProfile(value: userInput!)
        let offer = self.listOffer.first(where: { item -> Bool in
            item.id == offerId
        })
        DispatchQueue.main.async {
            OfferManager.shared.startRedemptionFlow(from: UIApplication.shared.keyWindow!.rootViewController!, offer: offer!, inputUser: user!)
            
            OfferManager.shared.redemptionHandler = { result in
                print(result)
            }
            
            OfferManager.shared.pushClaimTokensHandler = { (credifyId, result) in
                // Demo Market call push claim token
                pushClaimCB([credifyId, user?.id])
                self.pushClaimResponseCallback = result
            }
        }
    }
    
    //    @objc(showReferral)
    //    func showReferral(){
    //
    //    }
    
}
