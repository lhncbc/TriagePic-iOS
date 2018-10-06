//
//  FaceMatchHandlerObject.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 7/24/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoEditViewController.h"

@protocol FaceMatchHandlerObjectDelegate;

@interface FaceMatchHandlerObject : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, PhotoEditViewControllerDelegate>
+ (void)openCameraWithDelegate:(id)delegate;
- (void)openChoice;
@property (nonatomic, strong) id<FaceMatchHandlerObjectDelegate>delegate;
@end

@protocol FaceMatchHandlerObjectDelegate <NSObject>
- (void)haveFaceImageEncodedString:(NSString *)string;
@end
