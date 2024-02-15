//
//  ZTQOIImage.h
//  qoi_objc
//
//  Created by Zhangtao on 2022/11/20.
//

#import <Foundation/Foundation.h>
#import "ZTQOIImageDefine.h"
@interface ZTQOIImageHeader : NSObject

@property (nonatomic,readonly,assign) uint32_t width;
@property (nonatomic,readonly,assign) uint32_t height;
@property (nonatomic,readonly,assign) uint8_t channel;
@property (nonatomic,readonly,assign) uint8_t colorspace;

@end

NS_ASSUME_NONNULL_BEGIN
@interface ZTQOIImage : NSObject
@property (nonatomic,readonly,strong) ZTQOIImageHeader* header;
@property (nonatomic,readonly,strong) NSData *data;

-(instancetype)initWithFilePath:(NSString*)url;
-(instancetype)initWithPNGPath:(NSString*)url;
-(instancetype)initWithDesc:(ZTQOIImageHeader*)desc andData:(NSData*)data;

-(void)writePNGFileName:(NSString*)url;
+(NSData*)decodeQOIImage:(ZTQOIImage*) img;

@end

NS_ASSUME_NONNULL_END
