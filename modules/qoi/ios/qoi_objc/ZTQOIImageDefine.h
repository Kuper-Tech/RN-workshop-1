//
//  ZTQOIImageDefine.h
//  qoi_objc
//
//  Created by Zhangtao on 2022/11/26.
//

#ifndef ZTQOIImageDefine_h
#define ZTQOIImageDefine_h

#define QOI_MAGIC_ERROR printf("encoding an QOIImage,magic not correct!");
#define QOI_IMAGE_SIZE_ERROR printf("encoding an QOIImage,image width and height cant be 0!");
#define QOI_IMAGE_CHANNEL_ERROR printf("encoding an QOIImage,channel should be RGB or RGBA");
#define QOI_IMAGE_COLOR_SPACE_ERROR printf("encoding an QOIImage,color-space should be SRGB or LINEAR");
#define QOI_IMAGE_DECODE_ERROR printf("there is some problem,")

#define QOI_OP_INDEX  0x00 /* 00xxxxxx */
#define QOI_OP_DIFF   0x40 /* 01xxxxxx */
#define QOI_OP_LUMA   0x80 /* 10xxxxxx */
#define QOI_OP_RUN    0xc0 /* 11xxxxxx */
#define QOI_OP_RGB    0xFE /* 11111110 */
#define QOI_OP_RGBA   0xFF /* 11111111 */

#define QOI_CHANNEL_RGB    0x03 /* 00000011 */
#define QOI_CHANNEL_RGBA   0x04 /* 00000100 */


#define QOI_MASK_2    0xc0 /* 11000000 */
#define QOI_HEADER_SIZE 14
#define QOI_HEADER_MAGIC_SIZE 4
#define QOI_PADDING_SIZE 8

#define QOI_SRGB   0
#define QOI_LINEAR 1

// -----------------
#define PNG_HEADER_SIZE 33
// -----------------

#define QOI_MAGIC \
    (((unsigned int)'q') << 24 | ((unsigned int)'o') << 16 | \
     ((unsigned int)'i') <<  8 | ((unsigned int)'f'))

static const unsigned char qoi_padding[8] = {0,0,0,0,0,0,0,1};

struct _ZTQOIImageHeader {
    uint32_t width;
    uint32_t height;
    uint8_t channel;
    uint8_t colorspace;
};

struct _ZTPNGPixel {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
};

typedef union {
    struct _ZTPNGPixel rgba;
    uint32_t v;
} ZTPNGPixel;

struct ZTIHDRChunk {
    uint32_t width;
    uint32_t height;
    uint8_t  bit_depth;
    uint8_t  colort_type;
    uint8_t  compression_method;
    uint8_t  filter_method;
    uint8_t  interlace_method;
};

struct ZTPNGHeader {
    uint32_t data_length;
    uint32_t chunk_type_code;
    struct ZTIHDRChunk chunk_data;
    uint32_t CRC_code;
};

#endif /* ZTQOIImageDefine_h */
