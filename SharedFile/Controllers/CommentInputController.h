//
//  CommentInputController.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 2/24/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import "BTFilterController.h"
#import "PersonObject.h"
#import "ImageViewer.h"
#import "WSCommon.h"



@interface CommentInputController : BTFilterController <BTFilterControllerDelegate, UITextViewDelegate, MKMapViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, WSCommonDelegate>
- (void)fillWithUUID:(NSString *)uuid;
@end

@interface HighlightButton : UIButton

@end