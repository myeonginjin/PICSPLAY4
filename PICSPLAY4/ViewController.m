//
//  ViewController.m
//  PICSPLAY4
//
//  Created by 진명인 on 1/8/24.
//

#import "ViewController.h"

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
    applyGrayScaleBtn = [[UIButton alloc] initWithFrame:CGRectMake(47.5, 530, 100, 60)];
    saveImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(227.5, 530, 100, 60)];

    image = [UIImage imageNamed:@"input.jpg"];

    applyGrayScaleBtn.layer.cornerRadius = 10.0;
    applyGrayScaleBtn.layer.borderWidth = 1.0;
    applyGrayScaleBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [applyGrayScaleBtn setBackgroundColor:[UIColor whiteColor]];
    [applyGrayScaleBtn setTitle:@"Apply" forState:UIControlStateNormal];
    [applyGrayScaleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    saveImageBtn.layer.cornerRadius = 10.0;
    saveImageBtn.layer.borderWidth = 1.0;
    saveImageBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [saveImageBtn setBackgroundColor:[UIColor whiteColor]];
    [saveImageBtn setTitle:@"Download" forState:UIControlStateNormal];
    [saveImageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    [imageView setImage:image];

    [self.view addSubview:imageView];
    [self.view addSubview:applyGrayScaleBtn];
    [self.view addSubview:saveImageBtn];

    [applyGrayScaleBtn addTarget:self action:@selector(applyGrayBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [saveImageBtn addTarget:self action:@selector(saveImageBtnTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [imageView removeFromSuperview];
    [imageView release];
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
    // Implement your download logic here
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
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
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
                                    bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
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

    for (NSUInteger i = 0; i < width * height; i++) {
//        UInt8 gray = (UInt8)((pData[i * bytesPerPixel] + pData[i * bytesPerPixel + 1] + pData[i * bytesPerPixel + 2]) / 3);
        UInt8 gray = (UInt8)((0.299 * pData[i * bytesPerPixel] + 0.587 * pData[i * bytesPerPixel + 1] + 0.114 * pData[i * bytesPerPixel + 2]) * pData[i * bytesPerPixel + 3] / 255);
        rawdata[i * 4] = gray;
        rawdata[i * 4 + 1] = gray;
        rawdata[i * 4 + 2] = gray;
        rawdata[i * 4 + 3] = 255;
    }

    CGContextRef context = CGBitmapContextCreate(rawdata, width, height, bitsPerComponent, bytesPerRow, colorspace, kCGImageAlphaPremultipliedLast);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *grayScaleImage = [UIImage imageWithCGImage:cgImage];

    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    free(rawdata);

    return grayScaleImage;
}

@end

