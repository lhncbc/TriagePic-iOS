//
//  ImageDisplayRowView.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 2/10/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageObject.h"

@protocol ImageDisplayRowViewDelegate;


@interface ImageDisplayRowView : UIView <UIScrollViewDelegate, UIActionSheetDelegate>
- (id)initWithImageObjectArray:(NSArray *)imageObjectArray editable:(BOOL)editable cellHeight:(CGFloat)cellHeight;
@property (nonatomic, strong) NSArray *imageObjectArray;
@property (nonatomic, weak) id<ImageDisplayRowViewDelegate> delegate;
@end



@protocol ImageDisplayRowViewDelegate <NSObject>
- (void)imageDisplayRowView:(ImageDisplayRowView *)displayView buttonNumberTapped:(int)buttonNumber;
@end