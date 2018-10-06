//
//  PersonTableViewCell.h
//  ReUnite + TriagePic
//
//  Created by Krittach on 8/26/13.
//  Copyright (c) 2013 NLM LHC CEB LPF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonObject.h"

@interface PersonTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *personImageView;
@property (strong, nonatomic) UILabel *personNameLabel;
@property (strong, nonatomic) UILabel *personUpdatedLabel;
@property (strong, nonatomic) UILabel *personAgeLabel;
@property (strong, nonatomic) UILabel *personGenderLabel;
@property (strong, nonatomic) UILabel *personRankLabel;
@property (strong, nonatomic) PersonObject *personObject;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

- (void)fillWithPersonObject:(PersonObject *)personObject;

@end
