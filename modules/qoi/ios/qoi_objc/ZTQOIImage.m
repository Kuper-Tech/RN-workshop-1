//
//  ZTQOIImage.m
//  qoi_objc
//
//  Created by Zhangtao on 2022/11/20.
//


#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
#define STBI_NO_LINEAR
#import "ZTQOIImage.h"
#import "ZTQOIImageDefine.h"
#import "stb_images.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#import "stb_image_write.h"
#import <malloc/malloc.h>


#define FORWARD4Bytes(bytes) bytes+=4
#define FORWARDNBytes(bytes,n) bytes+=n
#define QOIDATAMAXSIZE(width,height,channel) width*height*(channel+1)+QOI_HEADER_SIZE+sizeof(qoi_padding)
#define INITQOIPIXEL(pixel)     pixel.rgba.r = 0;pixel.rgba.g = 0;pixel.rgba.b = 0;pixel.rgba.a = 255;
#define QOI_COLOR_HASH(C) (C.rgba.r*3 + C.rgba.g*5 + C.rgba.b*7 + C.rgba.a*11) % 64

static char QOImagic[4] = {'q','o','i','f'};

uint8_t _READByte(const char *bytes) {
    uint8_t temp = *(int*) bytes;
    return temp;
}

uint32_t _READ4Bytes(const char *bytes) {
    uint32_t ret = 0;
    ret |= (_READByte(bytes) << 24);
    bytes ++;
    ret |= (_READByte(bytes) << 16);
    bytes ++;
    ret |= (_READByte(bytes) << 8);
    bytes ++;
    ret |= (_READByte(bytes));
    return ret;
}

uint32_t READBytes(const char *bytes, uint32_t *p) {
    uint32_t a = bytes[(*p)++];
    uint32_t b = bytes[(*p)++];
    uint32_t c = bytes[(*p)++];
    uint32_t d = bytes[(*p)++];
    return a << 24 | b << 16 | c << 8 | d;
}

uint8_t READByte(const char *bytes, uint32_t *p) {
    return bytes[(*p) ++];
}

void WRITEByte(char *bytes, uint32_t *p ,uint8_t v) {
    bytes[(*p)++] = v;
}

void WRITE4Bytes(char *bytes, uint32_t *p,uint32_t v) {
    bytes[(*p)++] = (0xff000000 & v) >> 24;
    bytes[(*p)++] = (0x00ff0000 & v) >> 16;
    bytes[(*p)++] = (0x0000ff00 & v) >> 8;
    bytes[(*p)++] = (0x000000ff & v);
}

bool checQOIMagic(const char *bytes) {
    for (int i = 0 ; i < 4 ; i ++) {
        if (QOImagic[i] != bytes[i]) {
            QOI_MAGIC_ERROR
            return NO;
        }
    }
    return YES;
}

bool checkDesc(const struct _ZTQOIImageHeader desc) {
    if (desc.width <= 0 || desc.height <= 0) {
        QOI_IMAGE_SIZE_ERROR
        return NO;
    }
    if (desc.channel != QOI_CHANNEL_RGBA && desc.channel != QOI_CHANNEL_RGB) {
        QOI_IMAGE_CHANNEL_ERROR
        return NO;
    }
    if (desc.colorspace != QOI_SRGB && desc.colorspace != QOI_LINEAR) {
        QOI_IMAGE_COLOR_SPACE_ERROR
        return NO;
    }
    return YES;
}

struct _ZTQOIImageHeader makeQOIHeader(const char *bytes) {
    uint32_t width = _READ4Bytes(bytes);
    FORWARD4Bytes(bytes);
    uint32_t height = _READ4Bytes(bytes);
    FORWARD4Bytes(bytes);
    uint8_t channel = _READByte(bytes);
    bytes ++;
    uint8_t colorspace = _READByte(bytes);
    bytes ++;
    struct _ZTQOIImageHeader ret = {
        width,
        height,
        channel,
        colorspace
    };
    return ret;
}

@interface ZTQOIImageHeader ()

@property (nonatomic,assign) uint32_t width;
@property (nonatomic,assign) uint32_t height;
@property (nonatomic,assign) uint8_t channel;
@property (nonatomic,assign) uint8_t colorspace;

@end

@implementation ZTQOIImageHeader

-(instancetype)initWithWidth:(uint32_t)width withHeight:(uint32_t)height withChannel:(uint8_t)channel withColorspace:(uint8_t)colorspace {
    if (self = [super init]) {
        self.width = width;
        self.height = height;
        self.channel = channel;
        self.colorspace = colorspace;
    }
    return self;
}

+(instancetype)makeQOIHeader:(char*)bytes {
    uint32_t width = _READ4Bytes(bytes);
    FORWARD4Bytes(bytes);
    uint32_t height = _READ4Bytes(bytes);
    FORWARD4Bytes(bytes);
    uint8_t channel = _READByte(bytes);
    bytes ++;
    uint8_t colorspace = _READByte(bytes);
    bytes ++;
    return [[self alloc] initWithWidth:width withHeight:height withChannel:channel withColorspace:colorspace];
}

@end

@interface ZTQOIImage ()

@property (nonatomic,strong) ZTQOIImageHeader* header;
@property (nonatomic,strong) NSData *data;

@end

@implementation ZTQOIImage

-(instancetype)initWithDesc:(ZTQOIImageHeader*)desc andData:(NSData*)data {
    if (self = [super init]) {
        self.header = desc;
        self.data = data;
    }
    return self;
}

-(instancetype)initWithPNGPath:(NSString *)url {
    if (self = [super init]) {
        int w , h , channel;
        if(!stbi_info([url UTF8String], &w, &h, &channel)) {
            return nil;
        }
        if (channel != 3) {
            channel = 4;
        }
        void* pixels = (void *)stbi_load([url UTF8String], &w, &h, NULL, channel);
        NSData *data = [[NSData alloc] initWithBytes:pixels length:malloc_size(pixels)];
        ZTQOIImageHeader *header = [[ZTQOIImageHeader alloc] initWithWidth:w withHeight:h withChannel:channel withColorspace:QOI_SRGB];
        if (data) {
            return [self encodingToQOIImageFromPNGData:data withQOIHeader:header];
        }
        return nil;
    }
    return self;
}

-(instancetype)initWithFilePath:(NSString*)url {
    if (self = [super init]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:url];
        if (data) {
            ZTQOIImage *img = [ZTQOIImage encodeToQOIImageFromData:data];
            self.header = [ZTQOIImageHeader makeQOIHeader:((void*)data.bytes+QOI_HEADER_MAGIC_SIZE)];
            self.data = [NSData dataWithData:img.data];
            return self;
        }
        return nil;
    }
    return nil;
}

+(ZTQOIImage*)encodeToQOIImageFromData:(NSData*) data {
    NSUInteger length = data.length;
    const void *bytes = data.bytes;
    assert(data);
    if (!checQOIMagic(bytes)| (length < QOI_HEADER_SIZE)) {
        return nil;
    }
    struct _ZTQOIImageHeader desc = makeQOIHeader((void*)bytes+QOI_HEADER_MAGIC_SIZE);
    if (!checkDesc(desc)) {
        return nil;
    }
    ZTQOIImage *image = [[ZTQOIImage alloc] init];
    image.header = [ZTQOIImageHeader makeQOIHeader:((void*)bytes+QOI_HEADER_MAGIC_SIZE)];
    image.data = [[NSData alloc] initWithBytes:(void*) (bytes) length:data.length];
    return image;
}

-(ZTQOIImage*)encodingToQOIImageFromPNGData:(NSData*) data withQOIHeader:(ZTQOIImageHeader*) header {
    // init
    ZTPNGPixel pixel ,  pre_pixel , indexinit_pixel , index[64];
    char *pixels = (char *) data.bytes , *bytes = malloc(QOIDATAMAXSIZE(header.width, header.height, header.channel));
    uint32_t px_pos , px_len = header.width*header.height*header.channel , p = 0 , run = 0;
    uint32_t px_end = px_len - header.channel;
    INITQOIPIXEL(pre_pixel);
    INITQOIPIXEL(pixel);
    INITQOIPIXEL(indexinit_pixel);
    indexinit_pixel.rgba.a = 0;
    for (int i = 0 ; i < 64 ; i ++) {
        index[i] = indexinit_pixel;
    }
    
    // Write QOI header
    WRITE4Bytes(bytes, &p, QOI_MAGIC);
    WRITE4Bytes(bytes, &p, header.width);
    WRITE4Bytes(bytes, &p, header.height);
    WRITEByte(bytes, &p, header.channel);
    WRITEByte(bytes, &p, header.colorspace);
    
    // encode
    for (px_pos = 0 ; px_pos < px_len ; px_pos += header.channel) {
        pixel.rgba.r = pixels[px_pos + 0];
        pixel.rgba.g = pixels[px_pos + 1];
        pixel.rgba.b = pixels[px_pos + 2];
        if (header.channel == 4) {
            pixel.rgba.a = pixels[px_pos + 3];
        }
        
        // equal to pre pixel
        if (pixel.v == pre_pixel.v) {
            run ++;
            if (run == 62 || px_pos == px_end) {
                WRITEByte(bytes, &p, QOI_OP_RUN | (run-1));
                run = 0;
            }
        } else {
            if (run > 0) {
                WRITEByte(bytes, &p, QOI_OP_RUN | (run-1));
                run = 0;
            }
            // found pixel appear before
            uint32_t index_pos = QOI_COLOR_HASH(pixel);
            if (index[index_pos].v == pixel.v) {
                WRITEByte(bytes, &p, QOI_OP_INDEX | index_pos);
            } else {
                index[index_pos] = pixel;
                if (pixel.rgba.a == pre_pixel.rgba.a) {
                    signed char vr = pixel.rgba.r - pre_pixel.rgba.r;
                    signed char vg = pixel.rgba.g - pre_pixel.rgba.g;
                    signed char vb = pixel.rgba.b - pre_pixel.rgba.b;
                    
                    signed char vg_r = vr - vg;
                    signed char vg_b = vb - vg;
                    if (
                        vr > -3 && vr < 2 &&
                        vg > -3 && vg < 2 &&
                        vb > -3 && vb < 2
                        ) {
                            WRITEByte(bytes, &p, QOI_OP_DIFF | (vr + 2) << 4 | (vg + 2) << 2 | (vb + 2));
                        } else if (
                                   vg_r >  -9 && vg_r <  8 &&
                                   vg   > -33 && vg   < 32 &&
                                   vg_b >  -9 && vg_b <  8
                                   ) {
                                       WRITEByte(bytes, &p, QOI_OP_LUMA | (vg+32));
                                       WRITEByte(bytes, &p, (vg_r+8) << 4 | (vg_b+8));
                                   } else {
                                       WRITEByte(bytes, &p, QOI_OP_RGB);
                                       WRITEByte(bytes, &p, pixel.rgba.r);
                                       WRITEByte(bytes, &p, pixel.rgba.g);
                                       WRITEByte(bytes, &p, pixel.rgba.b);
                                   }
                    
                } else {
                    WRITEByte(bytes, &p, QOI_OP_RGBA);
                    WRITEByte(bytes, &p, pixel.rgba.r);
                    WRITEByte(bytes, &p, pixel.rgba.g);
                    WRITEByte(bytes, &p, pixel.rgba.b);
                    WRITEByte(bytes, &p, pixel.rgba.a);
                }
            }
        }
        pre_pixel = pixel;
    }
    for (int i = 0 ; i < (int)sizeof(qoi_padding) ; i ++) {
        WRITEByte(bytes, &p, qoi_padding[i]);
    }
    ZTQOIImage *QOIImage = [[ZTQOIImage alloc] initWithDesc:header andData:[[NSData alloc] initWithBytes:bytes length:p]];
    return QOIImage;
}

+(NSData*)decodeQOIImage:(ZTQOIImage*) img {
    const char *bytes = img.data.bytes;
    char *pixels;
    uint32_t px_pos , p = QOI_HEADER_SIZE , run = 0 ,  px_len = img.header.width*img.header.height*img.header.channel, channel = img.header.channel , chunks_len = img.data.length - QOI_PADDING_SIZE;
    ZTPNGPixel pixel , indexinit_pixel , index[64];
    INITQOIPIXEL(pixel);
    INITQOIPIXEL(indexinit_pixel);
    indexinit_pixel.rgba.a = 0;
    for (int i = 0 ; i < 64 ; i ++) {
        index[i] = indexinit_pixel;
    }
    pixels = malloc(img.header.width*img.header.height*img.header.channel);
    for (px_pos = 0 ; px_pos < px_len ; px_pos += channel) {
        if (run > 0) {
            run --;
        } else if (p < chunks_len) {
            uint32_t b = READByte(bytes, &p);
            if (b == QOI_OP_RGB) {
                pixel.rgba.r = READByte(bytes, &p);
                pixel.rgba.g = READByte(bytes, &p);
                pixel.rgba.b = READByte(bytes, &p);
            } else if (b == QOI_OP_RGBA) {
                pixel.rgba.r = READByte(bytes, &p);
                pixel.rgba.g = READByte(bytes, &p);
                pixel.rgba.b = READByte(bytes, &p);
                pixel.rgba.a = READByte(bytes, &p);
            } else if ((b & QOI_MASK_2) == QOI_OP_INDEX) {
                pixel = index[b];
            } else if ((b & QOI_MASK_2) == QOI_OP_DIFF) {
                pixel.rgba.r += ((b >> 4) & 0x03) - 2;
                pixel.rgba.g += ((b >> 2) & 0x03) - 2;
                pixel.rgba.b += ( b       & 0x03) - 2;
            } else if ((b & QOI_MASK_2) == QOI_OP_LUMA) {
                int b2 = READByte(bytes, &p);
                int vg = (b & 0x3f) - 32;
                pixel.rgba.r += vg - 8 + ((b2 >> 4) & 0x0f);
                pixel.rgba.g += vg;
                pixel.rgba.b += vg - 8 +  (b2       & 0x0f);
            } else if ((b & QOI_MASK_2) == QOI_OP_RUN) {
                run = (b & 0x3f);
            }
            index[QOI_COLOR_HASH(pixel) % 64] = pixel;
        }
        pixels[px_pos + 0] = pixel.rgba.r;
        pixels[px_pos + 1] = pixel.rgba.g;
        pixels[px_pos + 2] = pixel.rgba.b;
        
        if (channel == 4) {
            pixels[px_pos + 3] = pixel.rgba.a;
        }
    }
    
    return [[NSData alloc] initWithBytes:pixels length:malloc_size(pixels)];
}

-(void)writePNGFileName:(NSString*)url {
    NSData *data = [ZTQOIImage decodeQOIImage:self];
    int err = stbi_write_png([url UTF8String], self.header.width, self.header.height, self.header.channel, data.bytes, 0);
    if (!err) {
        NSLog(@"Can't Write!!");
    }
}

@end
