#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ServicexSdkRn, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)id environment:(NSString *)environment marketName:(NSString *)marketName)
RCT_EXTERN_METHOD(getOfferList:(NSDictionary *)userDict
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(clearCache)
RCT_EXTERN_METHOD(showOfferDetail:(NSString *)offerId pushClaimCB:(RCTResponseSenderBlock)pushClaimCB)
RCT_EXTERN_METHOD(showReferral)
RCT_EXTERN_METHOD(appDidBecomeActive:(UIApplication *)application)

@end

