//
//  ReportAsyncHandler.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 7/9/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonObject.h"
#import "WSCommon.h"

@interface ReportAsyncHandler : NSObject <WSCommonDelegate>
+ (ReportAsyncHandler *)sharedInstanceWithPersonObject:(PersonObject *)personObject;
+ (void)checkAndUploadFromOutBox;
@property (nonatomic, strong) PersonObject *personObject;
@end
