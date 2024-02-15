//
//  main.m
//  qoi_objc
//
//  Created by Zhangtao on 2022/11/20.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ZTQOIImage.h"

#define STR_ENDS_WITH(S, E) (strcmp(S + strlen(S) - (sizeof(E)-1), E) == 0)

int main(int argc, const char * argv[]) {
//    ZTQOIImage *image = [[ZTQOIImage alloc] initWithFilePath:@"/Users/bytedance/workspace/qoi_objc/qoi_objc/apple.qoi"];
//    NSData *data = [ZTQOIImage decodeQOIImage:image];
    if (argc < 3) {
            puts("Usage: qoiconv <infile> <outfile>");
            puts("Examples:");
            puts("  qoiconv input.png output.qoi");
            puts("  qoiconv input.qoi output.png");
            exit(1);
    }
    
    if (STR_ENDS_WITH(argv[1], ".png") && STR_ENDS_WITH(argv[2], ".qoi")) {
        ZTQOIImage *image = [[ZTQOIImage alloc] initWithPNGPath:[NSString stringWithUTF8String:argv[1]]];
        NSError *err = [[NSError alloc] init];
        [image.data writeToFile:[NSString stringWithUTF8String:argv[2]] options:0 error:&err];
    } else if (STR_ENDS_WITH(argv[1], ".qoi") && STR_ENDS_WITH(argv[2], ".png")) {
        ZTQOIImage *image = [[ZTQOIImage alloc] initWithFilePath:[NSString stringWithUTF8String:argv[1]]];
        [image writePNGFileName:[NSString stringWithUTF8String:argv[2]]];
    } else {
        puts("Usage: qoiconv <infile> <outfile>");
        puts("Examples:");
        puts("  qoiconv input.png output.qoi");
        puts("  qoiconv input.qoi output.png");
        exit(1);
    }
}
