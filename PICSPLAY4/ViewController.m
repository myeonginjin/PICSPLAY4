//
//  ViewController.m
//  PICSPLAY4
//
//  Created by 진명인 on 1/8/24.
//

#import "ViewController.h"
#import <Photos/Photos.h>

struct RGBAPixel {
    UInt8 red;
    UInt8 green;
    UInt8 blue;
    UInt8 alpha;
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(37.5, 200, 300, 300)];
    image = [UIImage imageNamed:@"input.jpg"];

    [imageView setImage:image];

    [self.view addSubview:imageView];
    [imageView release];
    
    applyGrayScaleBtn = [[UIButton alloc] initWithFrame:CGRectMake(47.5, 530, 100, 60)];
    applyGrayScaleBtn.layer.cornerRadius = 10.0;
    applyGrayScaleBtn.layer.borderWidth = 1.0;
    applyGrayScaleBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [applyGrayScaleBtn setBackgroundColor:[UIColor whiteColor]];
    [applyGrayScaleBtn setTitle:@"Apply" forState:UIControlStateNormal];
    [applyGrayScaleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [applyGrayScaleBtn addTarget:self action:@selector(applyGrayBtnTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:applyGrayScaleBtn];
    
    saveImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(227.5, 530, 100, 60)];
    saveImageBtn.layer.cornerRadius = 10.0;
    saveImageBtn.layer.borderWidth = 1.0;
    saveImageBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [saveImageBtn setBackgroundColor:[UIColor whiteColor]];
    [saveImageBtn setTitle:@"Download" forState:UIControlStateNormal];
    [saveImageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    [self.view addSubview:saveImageBtn];

    
    [saveImageBtn addTarget:self action:@selector(saveImageBtnTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    if (imageView != nil) {
        [imageView removeFromSuperview];
        imageView = nil;
    }
    
    [applyGrayScaleBtn removeFromSuperview];
    [applyGrayScaleBtn release];
    [saveImageBtn removeFromSuperview];
    [saveImageBtn release];

    [super dealloc];
}

- (void)applyGrayBtnTapped {
    // Get CGImage from UIImage
    CGImageRef cgImage = [image CGImage];

    // Call the function to manipulate image pixel data
    [self manipulateImagePixelData:cgImage];
}

- (void)saveImageBtnTapped {
    NSLog(@"Download button tapped");
    
    // 이미지 저장
    [self saveImageToLibrary];
}

- (void)saveImageToLibrary {
    if (imageView.image == nil) {
        NSLog(@"No image to save.");
        return;
    }
    NSLog(@"!!!!!@@!!!!!@@@11111111\n");
    
    UIImage *imageToSave = imageView.image;
    
    NSLog(@"!!!!!@@!!!!!@@@1.5\n");
    // 권한 확인
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self saveImage:imageToSave];
    } else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        NSLog(@"Access to photo library denied or restricted.");
    } else if (status == PHAuthorizationStatusNotDetermined) {
        // 사용자에게 권한 요청
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (authStatus == PHAuthorizationStatusAuthorized) {
                    [self saveImage:imageToSave];
                } else {
                    NSLog(@"Access to photo library denied.");
                }
            });
        }];
    }
}

- (void)saveImage:(UIImage *)imageToSave {
    // 이미지 저장
    NSLog(@"!!!!!@@!!!!!@@@2222222\n");
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:imageToSave];
        changeRequest.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Image saved to photo library.");
        } else {
            NSLog(@"Error saving image: %@", error.localizedDescription);
        }
    }];
}





- (void)manipulateImagePixelData:(CGImageRef)inImage {
    // Create the bitmap context
    CGContextRef cgctx = [self createARGBBitmapContext:inImage];
    if (cgctx == NULL) {
        // error creating context
        return;
    }

    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0, 0}, {w, h}};

    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);

    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    void *data = CGBitmapContextGetData(cgctx);
    if (data != NULL) {
        // Apply the grayscale filter
        UIImage *grayScaleImage = [self getGrayScaleUIImageWithData:data image:image];
        [imageView setImage:grayScaleImage];

        // **** Do stuff with the data here ****
    }

    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) {
        free(data);
    }
}

- (CGContextRef)createARGBBitmapContext:(CGImageRef)inImage {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;

    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);

    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (unsigned int)(pixelsWide * 4);
    bitmapByteCount = (unsigned int)(bitmapBytesPerRow * pixelsHigh);

    // Use the generic RGB color space.
//    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }

    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }

    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, // bits per component
                                    bitmapBytesPerRow, colorSpace, kCGImageAlphaNoneSkipLast);
    if (context == NULL) {
        free(bitmapData);
        fprintf(stderr, "Context not created!");
    }

    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);

    return context;
}

- (UIImage *)getGrayScaleUIImageWithData:(UInt8 *)pData image:(UIImage *)image {
    NSUInteger width = (NSUInteger)image.size.width;
    NSUInteger height = (NSUInteger)image.size.height;

    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawdata = (uint8_t *)malloc(width * height * sizeof(struct RGBAPixel));
    float ratioR, ratioG, ratioB;
    
    ratioR = 0.0132075;
    
    ratioB =  0.12396694;
    ratioG = 1 - (ratioR + ratioB);

    for (NSUInteger i = 0; i < width * height; i++) {
        
/* 방법 1
        UInt8 maxValue = (UInt8) (MAX(pData[i * bytesPerPixel], pData[i * bytesPerPixel + 1]));
        
        maxValue = (UInt8) (MAX(maxValue, pData[i * bytesPerPixel + 2]));
        
        UInt8 minValue = (UInt8) (MIN(pData[i * bytesPerPixel], pData[i * bytesPerPixel + 1]));
        
        minValue = (UInt8) (MIN(minValue, pData[i * bytesPerPixel + 2]));
        
        UInt8 gray = (UInt8)((maxValue + minValue) / 2 );
*/
        
/* 방법 2
        UInt8 gray = (UInt8)( (pData[i * bytesPerPixel] + pData[i * bytesPerPixel + 1] + pData[i * bytesPerPixel + 2])/3  );
 */
        
        
/* 방법 3 */
//        UInt8 gray = (UInt8)((0.2126 * pData[i * bytesPerPixel] + 0.7152 * pData[i * bytesPerPixel + 1] + 0.0722 * pData[i * bytesPerPixel + 2]) );

        
/* 방법 4
        UInt8 gray = (UInt8)((0.299 * pData[i * bytesPerPixel] + 0.587 * pData[i * bytesPerPixel + 1] + 0.114 * pData[i * bytesPerPixel + 2]) );
 
 */ 
        
/*방법 5
        UInt8 gray = (UInt8)((0.3 * pData[i * bytesPerPixel] + 0.59 * pData[i * bytesPerPixel + 1] + 0.11 * pData[i * bytesPerPixel + 2]) );
 */

    
        UInt8 gray = (UInt8)((ratioR * pData[i * bytesPerPixel] + ratioG * pData[i * bytesPerPixel + 1] + ratioB * pData[i * bytesPerPixel + 2]) );

        
        rawdata[i * 4] = gray;
        rawdata[i * 4 + 1] = gray;
        rawdata[i * 4 + 2] = gray;
        rawdata[i * 4 + 3] = 255;
    }

    CGContextRef context = CGBitmapContextCreate(rawdata, width, height, bitsPerComponent, bytesPerRow, colorspace, kCGImageAlphaNoneSkipLast);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *grayScaleImage = [UIImage imageWithCGImage:cgImage];

    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    free(rawdata);

    return grayScaleImage;
}

@end

