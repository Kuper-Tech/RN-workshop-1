#import <React/RCTBridgeModule.h>


//RCT_EXTERN_MODULE(Metrica, NSObject)
//#define RCT_EXTERN_REMAP_MODULE(js_name, objc_name, objc_supername)
@interface Metrica:NSObject
@end
@interface Metrica(RCTExternModule)<RCTBridgeModule>
@end
@implementation Metrica (RCTExternModule)
RCT_EXPORT_MODULE_NO_LOAD(js_name, Metrica)


RCT_EXTERN_METHOD(activate :(NSString *)apiKey)

RCT_EXTERN_METHOD(reportEvent
                  :(NSString *)eventName
                  :(NSDictionary *)params)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
