//
//  ZFTViewController.m
//  OpenCVSecondChapter-histogram_equalization
//
//  Created by glodon on 2019/11/15.
//  Copyright © 2019 persion. All rights reserved.
//


#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/core/operations.hpp>

#import <opencv2/core/core_c.h>
using namespace cv;
using namespace std;

#endif
#import "ZFTViewController.h"

@interface ZFTViewController ()

@end

@implementation ZFTViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    Mat src, dst;
    UIImage * src1Image = [UIImage imageNamed:@"chicky_512.png"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    /// 转为灰度图
    cvtColor( src, src, CV_BGR2GRAY );
    
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
     [self.view addSubview:imageView];
     imageView.image  = [self UIImageFromCVMat:src];
    /// 应用直方图均衡化
     equalizeHist( src, dst );
      /// 设置源图像和目标图像上的三组点以计算仿射变换
     
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
     [self.view addSubview:imageView];
     imageView.image  = [self UIImageFromCVMat:dst];
}


#pragma mark  - private
//brg
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                 cols,                       // Width of bitmap
                                                 rows,                       // Height of bitmap
                                                 8,                          // Bits per component
                                                 cvMat.step[0],              // Bytes per row
                                                 colorSpace,                 // Colorspace
                                                 kCGImageAlphaNoneSkipLast |
                                                 kCGBitmapByteOrderDefault); // Bitmap info flags
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
    
    Mat dst;
    Mat src;
    cvtColor(cvMat, dst, COLOR_RGBA2BGRA);
    cvtColor(dst, src, COLOR_BGRA2BGR);

  return src;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
//    mat 是brg 而 rgb
    Mat src;
    NSData *data=nil;
    CGBitmapInfo info =kCGImageAlphaNone|kCGBitmapByteOrderDefault;
    CGColorSpaceRef colorSpace;
    if (cvMat.depth()!=CV_8U) {
        Mat result;
        cvMat.convertTo(result, CV_8U,255.0);
        cvMat = result;
    }
  if (cvMat.elemSize() == 1) {
      colorSpace = CGColorSpaceCreateDeviceGray();
      data= [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  } else if(cvMat.elemSize() == 3){
      cvtColor(cvMat, src, COLOR_BGR2RGB);
       data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      colorSpace = CGColorSpaceCreateDeviceRGB();
  }else if(cvMat.elemSize() == 4){
      colorSpace = CGColorSpaceCreateDeviceRGB();
      cvtColor(cvMat, src, COLOR_BGRA2RGBA);
      data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      info =kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
  }else{
      NSLog(@"[error:] 错误的颜色通道");
      return nil;
  }
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  // Creating CGImage from cv::Mat
  CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                     cvMat.rows,                                 //height
                                     8,                                          //bits per component
                                     8 * cvMat.elemSize(),                       //bits per pixel
                                     cvMat.step[0],                            //bytesPerRow
                                     colorSpace,                                 //colorspace
                                     kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                     provider,                                   //CGDataProviderRef
                                     NULL,                                       //decode
                                     false,                                      //should interpolate
                                     kCGRenderingIntentAbsoluteColorimetric                   //intent
                                     );
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  return finalImage;
 }
@end
