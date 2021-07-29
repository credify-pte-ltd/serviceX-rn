#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ServicexSdkRn, NSObject)

RCT_EXTERN_METHOD(getOfferList:(NSString *)id
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

@end

