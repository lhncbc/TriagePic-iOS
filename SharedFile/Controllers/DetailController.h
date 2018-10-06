//
//  DetailController.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 2/6/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import "BTFilterController.h"
#import "PersonObject.h"
#import "ImageDisplayRowView.h"
#import "ImageViewer.h"
#import "CommentDisplayRowView.h"
#import "CommentInputController.h"
#import "PeopleDatabase.h"

@protocol DetailControllerDelegate <NSObject>
- (void)didSwiped:(UISwipeGestureRecognizer *)gesture;
@optional
- (void)didFinishSavingPerson;
- (void)refreshRecordsForType:(int)type;
- (void)editPersonObject:(PersonObject *)personObject;
@end

@interface DetailController : BTFilterController <BTFilterControllerDelegate, ImageDisplayRowViewDelegate, CommentDisplayRowViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, WSCommonDelegate, UINavigationControllerDelegate>

- (id)initWithPersonObject:(PersonObject *)personObject;
- (void)fillWithPersonObject:(PersonObject *)personObject tableViewAnimation:(UITableViewRowAnimation)tableViewAnimation;
@property (nonatomic, weak) id<DetailControllerDelegate> detailDelegate;
@end

@interface HeaderView : UILabel
@end