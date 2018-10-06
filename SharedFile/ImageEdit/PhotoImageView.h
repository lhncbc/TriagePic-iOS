//
// PhotoImageView.h
//  ReUnite + TriagePic + TriagePic.iPad
//
// Created by Krittach on 6/7/12.
// Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceRectView.h"
#import "PersonObject.h"

@protocol PhotoImageViewControllerDelegate <NSObject>
@optional
- (void)didStartFaceFinding;
- (void)didEndFaceFindingWithValidResult:(BOOL)hasValidResult;
- (void)didSelectBox;
- (void)didDeselectBox;
@end

@interface PhotoImageView : UIImageView <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, assign) int selectedFrame;
- (id)initWithImage:(UIImage *)image borderWidth:(float)borderWidth faceRectAvailable:(BOOL)faceRectAvailable faceRect:(CGRect)faceRect editable:(BOOL)editableValue;

//- (void)addRect;
- (void)initRect;
- (void)removeRect;
- (void)selectRect;
- (void)redoRect;

@property (weak) id<PhotoImageViewControllerDelegate> delegate;

@end
