//
//  ScannerController.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 5/12/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScannerControllerDelegate <NSObject>

- (void)successScanWithString:(NSString *)string;

@end

@interface ScannerController : UIViewController <UIAlertViewDelegate>
@property (nonatomic, weak) id<ScannerControllerDelegate> delegate;
@end
