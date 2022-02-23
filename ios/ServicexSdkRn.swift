import serviceX
import Combine

@objc(ServicexSdkRn)
class ServicexSdkRn: NSObject {
    
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
    @objc(initialize:environment:marketName:packageVersion:)
    func initialize(apiKey:String, environment: String, marketName: String, packageVersion: String) -> Void {
        let envDict = ["DEV": CCEnvironmentType.DEV, "PRODUCTION": .PRODUCTION,"SANDBOX":  .SANDBOX,"SIT": .SIT,"UAT": .UAT]
        
        let config = serviceXConfig(apiKey: apiKey, env: envDict[environment]!, appName: marketName)
        CredifyServiceX.configure(config)
        CredifyServiceX.updateUserAgent("servicex/rn/ios/\(packageVersion)")
        CredifyServiceX.applicationDidBecomeActive(UIApplication.shared)
    }
    
    // In case we need to trigger it manually in AppDelegate Callback
    @objc(appDidBecomeActive:)
    func appDidBecomeActive(application: UIApplication) -> Void {
        CredifyServiceX.applicationDidBecomeActive(application)
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
        
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            print("There is no view controller")
            return
        }
        
        let task = { (credifyId: String) -> Future<Void, Error> in
            return Future() { promise in
                pushClaimCB([user.id, credifyId])
                self.pushClaimResponseCallback = promise
            }
        }
        
        DispatchQueue.main.async {
            CredifyServiceX.offer.presentModally(
                from: vc,
                offer: offer,
                userProfile: user,
                pushClaimTokensTask: task
            ) { [weak self] result in
                
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
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            print("There is no view controller")
            return
        }
        DispatchQueue.main.async {
            CredifyServiceX.offer.showPassport(from: vc, userProfile: user) {
                dismissCB([])
            }
        }
    }
    
}
