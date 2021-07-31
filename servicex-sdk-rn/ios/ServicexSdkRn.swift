@objc(ServicexSdkRn)
class ServicexSdkRn: NSObject {
    
    @objc(initialize:environment:marketName:)
    func initialize(apiKey:NSDictionary, environment: String, marketName: String) -> Void {
     
    }
    
    
    @objc(getOfferList:withResolver:withRejecter:)
    func getOfferList(userDict:NSDictionary, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
     
    }
    
    @objc(clearCache)
    func clearCache(){
        
    }
    
    @objc(showOfferDetail)
    func showOfferDetail(offerId: String) {
        
    }
    
    @objc(showReferral)
    func showReferral(){
        
    }
 
}
