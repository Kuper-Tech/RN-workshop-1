#import "QoiView.h"

#import <react/renderer/components/RNQoiViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNQoiViewSpec/EventEmitters.h>
#import <react/renderer/components/RNQoiViewSpec/Props.h>
#import <react/renderer/components/RNQoiViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "qoi_objc/ZTQOIImage.h"

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
        NSString *urlString = [NSString stringWithFormat:@"%s", newViewProps.url.c_str()];
        NSURL *url = [NSURL URLWithString:urlString];
        [self download:url];
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)download:(NSURL *)url
{
    NSString *fileName = [url lastPathComponent]; //image.qoi
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSString *filePath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:fileName];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateImageView:filePath];
            });
        }
    }];

    [downloadTask resume];
    
}

-(void)updateImageView:(NSString *)path
{
    ZTQOIImage *image = [[ZTQOIImage alloc] initWithFilePath:path];
    NSData *data = [ZTQOIImage decodeQOIImage:image];
    CGSize size = CGSizeMake(image.header.width, image.header.height);

    CIImage *ciImage = [CIImage imageWithBitmapData:data bytesPerRow:image.header.width * 4 size:size format:kCIFormatRGBA8 colorSpace:CGColorSpaceCreateDeviceRGB()];

    UIImage *im = [[UIImage alloc] initWithCIImage:ciImage];
    
    UIImageView *view = (UIImageView*) self.contentView;
    [view setImage:im];
}

Class<RCTComponentViewProtocol> QoiViewCls(void)
{
    return QoiView.class;
}

@end
