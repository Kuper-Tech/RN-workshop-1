#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"

@interface QoiViewManager : RCTViewManager
@end

@implementation QoiViewManager

RCT_EXPORT_MODULE(QoiView)

- (UIView *)view
{
  return [[UIView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(color, NSString)

@end
