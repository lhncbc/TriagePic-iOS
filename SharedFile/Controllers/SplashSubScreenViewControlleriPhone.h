//
//  SplashSubScreenViewControlleriPhone.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 3/28/13.
//  Copyright (c) 2013 Krittach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>

@protocol SplashSubScreenViewControlleriPhoneDelegate <NSObject>
@optional
- (void)didDismissedSplashscreen;
@end

@interface SplashSubScreenViewControlleriPhone : UIViewController <MFMailComposeViewControllerDelegate, UIScrollViewDelegate>
- (id)initWithAgreeButton:(BOOL)hasAgreeButton isFirstScreen:(BOOL)isFirstScreen scrollsToPrivacy:(BOOL)scrollsToPrivacy delegate:(id)delegate;
- (void)scrollToPrivacy;

@property (nonatomic, weak) id<SplashSubScreenViewControlleriPhoneDelegate> delegate;
@property (nonatomic, assign) BOOL hasAgreeButton;

@end
