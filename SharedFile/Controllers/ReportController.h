//
//  ReportController.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 4/1/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import "BTFilterController.h"
#import "PersonObject.h"
#import "WSCommon.h"
#import "PhotoEditViewController.h"
#import "PeopleDatabase.h"
#import "ScannerController.h"

@protocol ReportControllerDelegate <NSObject>
- (void)refreshRecordsForType:(int)type;
@end

@interface ReportController : BTFilterController <BTFilterControllerDelegate, UITextViewDelegate, MKMapViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, WSCommonDelegate, UIAlertViewDelegate, ScannerControllerDelegate, UITextFieldDelegate>
@property (nonatomic, strong) PersonObject *personObject;
@property (nonatomic, weak) id<ReportControllerDelegate> reportDelegate;
@property (strong)    UIImagePickerController* cameraPickerController;


- (id)initWithPersonObject:(PersonObject *)personObject;
- (void)fillWithPersonObject:(PersonObject *)personObject;

@end
