#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ServicexSdkRn, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString *)apiKey environment:(NSString *)environment marketName:(NSString *)marketName)
RCT_EXTERN_METHOD(setUserProfile:(NSDictionary *)userDict)
RCT_EXTERN_METHOD(getOfferList:(RCTPromiseResolveBlock*)resolve rejecter:(RCTPromiseRejectBlock*)reject)
RCT_EXTERN_METHOD(clearCache)
RCT_EXTERN_METHOD(showOfferDetail:(NSString *)offerId pushClaimCB:(RCTResponseSenderBlock)pushClaimCB)
RCT_EXTERN_METHOD(setPushClaimRequestStatus:(Bool)isSuccess)
RCT_EXTERN_METHOD(appDidBecomeActive:(UIApplication *)application)
//RCT_EXTERN_METHOD(showReferral)

@end

