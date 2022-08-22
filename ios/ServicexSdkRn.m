#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(ServicexSdkRn, RCTEventEmitter)

RCT_EXTERN_METHOD(initialize:(NSString *)apiKey marketId:(NSString *)marketId environment:(NSString *)environment marketName:(NSString *)marketName packageVersion:(NSString *)packageVersion theme:(NSDictionary *)theme)
RCT_EXTERN_METHOD(setUserProfile:(NSDictionary *)userDict)
RCT_EXTERN_METHOD(getOfferList:(NSArray *)productTypes resolve:(RCTPromiseResolveBlock*)resolve rejecter:(RCTPromiseRejectBlock*)reject)
RCT_EXTERN_METHOD(clearCache)
RCT_EXTERN_METHOD(showOfferDetail:(NSString *)offerId)
RCT_EXTERN_METHOD(showPromotionOffers)
RCT_EXTERN_METHOD(showPassport)
RCT_EXTERN_METHOD(showServiceInstance:(NSString *)marketId productTypes:(NSArray *)productTypes)
RCT_EXTERN_METHOD(setPushClaimRequestStatus:(BOOL)isSuccess)
RCT_EXTERN_METHOD(supportedEvents)
RCT_EXTERN_METHOD(getBNPLAvailability:(RCTPromiseResolveBlock*)resolve rejecter:(RCTPromiseRejectBlock*)reject)
RCT_EXTERN_METHOD(showBNPL:(NSDictionary *)orderInfo)

@end

