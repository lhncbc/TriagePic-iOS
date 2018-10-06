//
//  FindViewController.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 2/27/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailController.h"
#import "PersonTableViewCell.h"
#import "FilterViewController.h"
#import "WSCommon.h"
#import "SVProgressHUD.h"
#import "FaceMatchHandlerObject.h"

@interface FindViewController : UITableViewController <UISearchBarDelegate, WSCommonDelegate, PersonObjectDelegate, BTFilterControllerDelegate, DetailControllerDelegate, FaceMatchHandlerObjectDelegate>

@end
