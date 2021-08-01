import CredifyServiceXSDK

@objc(ServicexSdkRn)
class ServicexSdkRn: NSObject {
    
    @objc(initialize:environment:marketName:)
    func initialize(apiKey:NSDictionary, environment: String, marketName: String) -> Void {
        let config = CredifyServiceXConfiguration(apiKey: "4nN5UifKTRxR1At4syeBHM6e4p0cFOdoqsuUKOIgSYBEJRa8UpGprqorfyWFgdVk",
                                                        environment: .SANDBOX, appName: "App Name")
        CredifyServiceX.shared.config(with: config)
    }
    
    
    @objc(getOfferList:withResolver:withRejecter:)
    func getOfferList(userDict:NSDictionary, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
     
    }
    
    @objc(clearCache)
    func clearCache(){
        
    }
    
    @objc(showOfferDetail:)
    func showOfferDetail(offerId: String) {
        
    }
    
    @objc(showReferral)
    func showReferral(){
        
    }
 
}
