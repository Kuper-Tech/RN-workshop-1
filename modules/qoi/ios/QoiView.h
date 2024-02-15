// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef QoiViewNativeComponent_h
#define QoiViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface QoiView : RCTViewComponentView
@end

NS_ASSUME_NONNULL_END

#endif /* QoiViewNativeComponent_h */
#endif /* RCT_NEW_ARCH_ENABLED */
