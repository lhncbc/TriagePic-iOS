//
// FaceRectView.h
//  ReUnite + TriagePic
//
// Created by Krittach on 6/7/12.
// Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface FaceRectView : UIView

- (id) initWithFrame:(CGRect)frame borderwitdh:(CGFloat)borderWidth automatic:(BOOL) automatic editable:(BOOL)editable;
- (void)setSelect;
- (void)setDeselect;
@end
