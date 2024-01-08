//
//  ViewController.m
//  PICSPLAY4
//
//  Created by 진명인 on 1/8/24.
//

#import "ViewController.h"



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
    [saveImageBtn setTitle:@"DownLoad" forState:UIControlStateNormal];
    [saveImageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

    
    [imageView setImage:image];
    
    [self.view addSubview:imageView];
    [self.view addSubview:applyGrayScaleBtn];
    [self.view addSubview:saveImageBtn];
    
    [imageView release];
    [applyGrayScaleBtn release];
    [saveImageBtn release];
    
    [applyGrayScaleBtn addTarget:self action:@selector(ApplyGrayBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [saveImageBtn addTarget:self action:@selector(saveImageBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)dealloc
{
    if (imageView != nil) {
        [imageView removeFromSuperview];
        imageView = nil;
    }
    if (applyGrayScaleBtn != nil) {
        [applyGrayScaleBtn removeFromSuperview];
        applyGrayScaleBtn = nil;
    }
    
    [super dealloc];
}

- (void)ApplyGrayBtnTapped {

    NSLog(@"!!!!!");

}

- (void)saveImageBtnTapped {

    NSLog(@"?????");

}




@end
  
