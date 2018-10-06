//
// PhotoEditViewController.h
//
// Created by Krittach on 6/6/12.
// Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ImageViewer : UIViewController <UIScrollViewDelegate>
- (id)initWithImage:(UIImage *)image;
@property (nonatomic, strong) UIImage *image;
@end
