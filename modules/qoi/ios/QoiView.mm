#import "QoiView.h"

#import <react/renderer/components/RNQoiViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNQoiViewSpec/EventEmitters.h>
#import <react/renderer/components/RNQoiViewSpec/Props.h>
#import <react/renderer/components/RNQoiViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface QoiView () <RCTQoiViewViewProtocol>

@end

@implementation QoiView {
    UIView * _view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<QoiViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const QoiViewProps>();
    _props = defaultProps;

    _view = [[UIImageView alloc] init];

    self.contentView = _view;
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<QoiViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<QoiViewProps const>(props);

    if (oldViewProps.url != newViewProps.url) {
        
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> QoiViewCls(void)
{
    return QoiView.class;
}

@end
