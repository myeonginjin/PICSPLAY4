//
//  ViewController.h
//  PICSPLAY4
//
//  Created by 진명인 on 1/8/24.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    
    UIImageView *imageView;
    UIImage *image;
    UIImage *appliedGrayScaleImage;
    UIButton *applyGrayScaleBtn;
    UIButton *saveImageBtn;
    UIImage *imageToSave;
    
    
    BOOL isOriginalImage;
    BOOL readyToShow;
    
}

@end

