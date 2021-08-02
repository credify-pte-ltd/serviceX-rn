import CredifyServiceXSDK

@objc(ServicexSdkRn)
class ServicexSdkRn: NSObject {
    var userInput: PlatformUserModel?
    var listOffer: [OfferData] = [OfferData]()
    var pushClaimResponseCallback: ((Bool) -> Void)?
    
    @objc(initialize:environment:marketName:)
    func initialize(apiKey:NSDictionary, environment: String, marketName: String) -> Void {
        let config = CredifyServiceXConfiguration(apiKey: "4nN5UifKTRxR1At4syeBHM6e4p0cFOdoqsuUKOIgSYBEJRa8UpGprqorfyWFgdVk",
                                                        environment: .SANDBOX, appName: "App Name")
        CredifyServiceX.shared.config(with: config)
        CredifyServiceX.shared.applicationDidBecomeActive(UIApplication.shared)
    }
    
    // In case we need to trigger it manually in AppDelegate Callback
    @objc(appDidBecomeActive:)
    func appDidBecomeActive(application: UIApplication) -> Void {
        CredifyServiceX.shared.applicationDidBecomeActive(application)
    }
    
    @objc(setUserProfile:)
    func setUserProfile(value:NSDictionary) {
        guard let v = value as? [String:Any] else { return }
        if let id = v["id"] as? Int {
            let firstName = v["first_name"] as? String ?? ""
            let lastName =  v["last_name"] as? String ?? ""
            let email = v["email"] as? String ?? ""
            let credifyId = v["credify_id"] as? String
            let phoneNumber = v["phone_number"] as? String
            let phoneCountryCode = v["country_code"] as? String

            self.userInput = PlatformUserModel(id: "\(id)",
                                               firstName: firstName,
                                               lastName: lastName,
                                               email: email,
                                               credifyId: credifyId,
                                               countryCode: phoneCountryCode ?? "",
                                               phoneNumber: phoneNumber ?? "")
        }
    }
    
    @objc(getOfferList:withResolver:withRejecter:)
    func getOfferList(userDict:NSDictionary, resolve:@escaping (RCTPromiseResolveBlock), reject: @escaping(RCTPromiseRejectBlock)) -> Void {
        guard let user = self.userInput else { return }
        // Demo Market call API to get list offer for user
        OfferManager.shared.getOffersConsumer(user: user) { [weak self] result in
            switch result {
            case .success(let offers):
                self?.listOffer = offers
                resolve(offers)
            case .failure(let error):
                print(error)
                reject("Get Offers error", "Errors:", error);
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
        guard let user = userInput else { return }
        OfferManager.shared.startRedemptionFlow(from: UIApplication.shared.keyWindow!.rootViewController!, offer: listOffer[0], inputUser: user)
        OfferManager.shared.redemptionHandler = { result in
            print(result)
        }
        OfferManager.shared.pushClaimTokensHandler = { (credifyId, result) in
            // Demo Market call push claim token
            pushClaimCB([credifyId])
            self.pushClaimResponseCallback = result
        }
    }
    
    @objc(showReferral)
    func showReferral(){
        
    }
 
}
