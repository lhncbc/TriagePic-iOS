//
//  HomeViewController.m
//  ReUnite + TriagePic
//
//  Created by Krittach on 3/19/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import "HomeViewController.h"

#import "BTSplitViewController.h"
#import "ReportAsyncHandler.h"
#import "HospitalObject.h"
//#import "GAIDictionaryBuilder.h"
//#import "GAI.h"


#define ALERT_TAG_LOGIN 54
#define ALERT_TAG_LOGIN_FAILED 55
#define ALERT_TAG_LOGOUT 56

#define ALERT_TAG_LOGIN_SUCCESS 67
#define ALERT_TAG_LOGOUT_SUCCESS 77
#define ALERT_TAG_RESET_PASSWORD_SUCCESS 78

#define ALERT_TAG_NO_EVENT_LIST 79

#define ALERT_TAG_ADD_NEW_SERVER 80
#define ALERT_TAG_REMOVE_SERVER 81
#define ALERT_TAG_LAST_SERVER 82

#define TAG_ALERT_PUSH_NOTIFICATION 24

#define ADD_NEW_SERVER_STRING @"Add New Server..."


@interface HomeViewController ()

@end

@implementation HomeViewController
{
    FindViewController *_findViewController;
    OrganizeController *_organizeController;
    
    UISwitch *_loginSwitch;
    UIButton *_loginLabel;
    
    UIView *_infoBoxView;
    UILabel *_selectedEventLabel;
    UILabel *_startedOnLabel;
    UILabel *_locationLabel;
    UILabel *_serverAddressLabel;
    UILabel *_statusLabel;
    UILabel *_latencyLabel;
    UILabel *_lastUpdateLabel;
    
    NSTimer *_pingTimer;
    
    UIAlertView *_loginAlertView;
    BOOL _awaitingAnonymousToken;
    NSString *_currentUsername;
    
    BTSubFilterController *_eventPickerVC;
    BTFilterController *_settingsController;
    BTFilterController *_registerController;
    BTFilterController *_forgotPasswordController;
    
    
    // iPad only
    UIPopoverController *_settingPopOver;
    BTSplitViewController *_findSpltViewController;
    BTSplitViewController *_reportSplitViewController;
    
    // Send to edit flag for "Save and edit" button
    BOOL _sendToEdit;
    PersonObject *_personObjectToEdit;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[NSString stringWithFormat:@"%@®", [CommonFunctions appName]]];

        UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped)];
        [self.navigationItem setRightBarButtonItem:settingsBarButtonItem];
        
        UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain target:self action:@selector(infoTapped)];
        [self.navigationItem setLeftBarButtonItem:infoBarButtonItem];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSLog(@"Main bundle path: %@", mainBundle);

    // originally a label but use button to add image into text otherwise I would have to create 2 variables
    _loginLabel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_loginLabel setTitle:@" Login:" forState:UIControlStateNormal];
    [_loginLabel setImage:[UIImage imageNamed:@"key"] forState:UIControlStateNormal];
    [_loginLabel setTintColor:[UIColor blackColor]];
    [_loginLabel setUserInteractionEnabled:NO];
    [self.view addSubview:_loginLabel];
    
    _loginSwitch = [[UISwitch alloc] init];
    [_loginSwitch setOn:NO];
    [_loginSwitch addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventValueChanged];
    [_loginSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_loginSwitch];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:IS_TRIAGEPIC?[UIImage imageNamed:@"triagepic"]:[[UIImage imageNamed:@"reunite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [imageView setTintColor:[UIColor colorWithRed:.5 green:.6 blue:.9 alpha:1]];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:imageView];
    
    UILabel *sloganLabel = [[UILabel alloc] init];
    [sloganLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sloganLabel setFont:[UIFont fontWithName:@"Verdana-Italic" size:13]];
    [sloganLabel setText:@"...For Family Reunification"];
    [self.view addSubview:sloganLabel];
    
    _infoBoxView = [[UIView alloc] init];
    [_infoBoxView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_infoBoxView setBackgroundColor:[UIColor colorWithWhite:.97 alpha:1]];
    [self.view addSubview:_infoBoxView];
    
    [self setUpInfoBox];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [findButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [findButton setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
    [findButton.layer setCornerRadius:5];
    [findButton addTarget:self action:@selector(findButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@" Find " forState:UIControlStateNormal];
    [findButton setImage:[UIImage imageNamed:@"find"] forState:UIControlStateNormal];
    [self.view addSubview:findButton];
    
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reportButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [reportButton setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
    [reportButton.layer setCornerRadius:5];
    [reportButton addTarget:self action:@selector(reportButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [reportButton setTitle:@" Report " forState:UIControlStateNormal];
    [reportButton setImage:[UIImage imageNamed:@"report"] forState:UIControlStateNormal];
    [self.view addSubview:reportButton];
    
    UIView *referenceViewForCenteringInfoBoxVertically = [[UIView alloc] init];
    [referenceViewForCenteringInfoBoxVertically setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:referenceViewForCenteringInfoBoxVertically];
    
    id topLayoutGuide = self.topLayoutGuide;
    id selfView = self.view;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sloganLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-[_loginSwitch]-(5)-[imageView]-(5)-[sloganLabel]-[referenceViewForCenteringInfoBoxVertically]-[findButton]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(topLayoutGuide, _loginSwitch, imageView, sloganLabel, referenceViewForCenteringInfoBoxVertically, findButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:referenceViewForCenteringInfoBoxVertically attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_infoBoxView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoBoxView(<=referenceViewForCenteringInfoBoxVertically)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_infoBoxView, referenceViewForCenteringInfoBoxVertically)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_infoBoxView(<=selfView)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_infoBoxView, selfView)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_infoBoxView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_loginLabel]-[_loginSwitch]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_loginLabel, _loginSwitch)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_loginLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_loginSwitch attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[findButton(44)]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(findButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reportButton(44)]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(reportButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[findButton]-(5)-[reportButton(findButton)]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(reportButton, findButton)]];
    
    
    bool agreeBurden = [[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_STATUS_PRIVACY_AGREE];
    if (!agreeBurden){
        //[privacyAlert show];versionNumberLabel
        SplashSubScreenViewControlleriPhone *splashSubScreenViewControlleriPhone = [[SplashSubScreenViewControlleriPhone alloc] initWithAgreeButton:YES isFirstScreen:YES scrollsToPrivacy:NO delegate:self];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController: splashSubScreenViewControlleriPhone] animated:YES completion:nil];
    }else{
        [WSCommon getEventListWithDelegate:self];
    }
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveAndEditNotificationCalled:) name:NOTIFICATION_SAVE_AND_EDIT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:NOTIFICATION_LOG_OUT object:nil];
}

- (void)setUpInfoBox
{
    UIFont *smallFont = [CommonFunctions fontSmallDeviceSpecific:YES];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    [headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerLabel setText:[NSString stringWithFormat:@"%@ Status", IS_TRIAGEPIC? @"TriageTrak": @"People Locator"]];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [_infoBoxView addSubview:headerLabel];
    
    UILabel *selectedEventLabel = [[UILabel alloc] init];
    [selectedEventLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [selectedEventLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [selectedEventLabel setText:@"Selected Event"];
    selectedEventLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];

    //[selectedEventLabel setFont:smallFont];
    [_infoBoxView addSubview:selectedEventLabel];
    
    UILabel *startedOnLabel = [[UILabel alloc] init];
    [startedOnLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [startedOnLabel setText:@"  Began On"];
    [startedOnLabel setFont:smallFont];
    [_infoBoxView addSubview:startedOnLabel];
    
    UILabel *locationLabel = [[UILabel alloc] init];
    [locationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [locationLabel setText:@"  Location"];
    [locationLabel setFont:smallFont];
    [_infoBoxView addSubview:locationLabel];
    
    UILabel *serverAddressLabel = [[UILabel alloc] init];
    [serverAddressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [serverAddressLabel setText:@"  Server Address"];
    [serverAddressLabel setFont:smallFont];
    [_infoBoxView addSubview:serverAddressLabel];
    
    UILabel *statusLabel = [[UILabel alloc] init];
    [statusLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [statusLabel setText:@"  Status"];
    [statusLabel setFont:smallFont];
    [_infoBoxView addSubview:statusLabel];
    
    UILabel *latencyLabel = [[UILabel alloc] init];
    [latencyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [latencyLabel setText:@"  Latency"];
    [latencyLabel setFont:smallFont];
    [_infoBoxView addSubview:latencyLabel];
    
    _selectedEventLabel = [[UILabel alloc] init];
    [_selectedEventLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_selectedEventLabel setText:@": No Event Selected"];
    [_selectedEventLabel setFont:smallFont];
    [_infoBoxView addSubview:_selectedEventLabel];
    
    _startedOnLabel = [[UILabel alloc] init];
    [_startedOnLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_startedOnLabel setText:@": No Event Selected"];
    [_startedOnLabel setFont:smallFont];
    
    [_infoBoxView addSubview:_startedOnLabel];
    
    _locationLabel = [[UILabel alloc] init];
    [_locationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_locationLabel setText:@": No Event Selected"];
    [_locationLabel setFont:smallFont];
    [_infoBoxView addSubview:_locationLabel];
    
    _serverAddressLabel = [[UILabel alloc] init];
    [_serverAddressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *serverAddress = [NSString stringWithFormat:@"    : %@%@", [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_HTTP], [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_NAME]];
    [_serverAddressLabel setText:serverAddress];
    [_serverAddressLabel setFont:smallFont];
    [_infoBoxView addSubview:_serverAddressLabel];
    
    _statusLabel = [[UILabel alloc] init];
    [_statusLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_statusLabel setText:@": Refreshing..."];
    [_statusLabel setFont:smallFont];
    [_infoBoxView addSubview:_statusLabel];
    
    _latencyLabel = [[UILabel alloc] init];
    [_latencyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_latencyLabel setText:@": Refreshing..."];
    [_latencyLabel setFont:smallFont];
    [_infoBoxView addSubview:_latencyLabel];

    _lastUpdateLabel = [[UILabel alloc] init];
    [_lastUpdateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_lastUpdateLabel setFont:smallFont];
    [_infoBoxView addSubview:_lastUpdateLabel];
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [refreshButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [refreshButton setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
    [refreshButton.layer setCornerRadius:5];
    [refreshButton addTarget:self action:@selector(refreshEventTapped) forControlEvents:UIControlEventTouchUpInside];
    [_infoBoxView addSubview:refreshButton];
    
    UIButton *changeEventButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [changeEventButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [changeEventButton setTitle:@" Change Event " forState:UIControlStateNormal];
    [changeEventButton.titleLabel setFont:[CommonFunctions fontSmallDeviceSpecific:YES]];
    [changeEventButton setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
    [changeEventButton.layer setCornerRadius:5];
    [changeEventButton addTarget:self action:@selector(changeEventTapped) forControlEvents:UIControlEventTouchUpInside];
    [_infoBoxView addSubview:changeEventButton];
    
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[headerLabel]-[selectedEventLabel]-(2)-[startedOnLabel]-(2)-[locationLabel]-(2)-[_lastUpdateLabel]-[serverAddressLabel]-(2)-[statusLabel]-(2)-[latencyLabel]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(headerLabel, selectedEventLabel, startedOnLabel, locationLabel, serverAddressLabel, statusLabel, latencyLabel, _lastUpdateLabel)]];
   // [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[headerLabel]-[_selectedEventLabel]-(2)-[_startedOnLabel]-(2)-[_locationLabel]-(2)-[_lastUpdateLabel]-[_serverAddressLabel]-(2)-[_statusLabel]-(2)-[_latencyLabel]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(headerLabel, _selectedEventLabel, _startedOnLabel, _locationLabel, _serverAddressLabel, _statusLabel, _latencyLabel, _lastUpdateLabel)]];

    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[headerLabel]-[refreshButton]-[changeEventButton]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(headerLabel, refreshButton, changeEventButton)]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[refreshButton(changeEventButton)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(refreshButton, changeEventButton)]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:refreshButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:refreshButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:refreshButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:changeEventButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[selectedEventLabel]-(10)-[_selectedEventLabel]-(>=10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(selectedEventLabel, _selectedEventLabel)]];
    
    
    // line the label and value up
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_selectedEventLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:startedOnLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_startedOnLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:locationLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_locationLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:serverAddressLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_serverAddressLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:statusLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_statusLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:latencyLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_latencyLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    
    // line up the left side of label
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:startedOnLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:locationLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:startedOnLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_lastUpdateLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:serverAddressLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:statusLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:latencyLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    
    
    //line up the left side of value
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:_selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_startedOnLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:_selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_locationLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:_selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_serverAddressLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:_selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_statusLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_infoBoxView addConstraint:[NSLayoutConstraint constraintWithItem:_selectedEventLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_latencyLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];

    // line up the right side of value
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectedEventLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_selectedEventLabel)]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_locationLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_locationLabel)]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_startedOnLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_startedOnLabel)]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_serverAddressLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_serverAddressLabel)]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_statusLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_statusLabel)]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_statusLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_statusLabel)]];
    [_infoBoxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_latencyLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_latencyLabel)]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshEventDisplay];
    [self refreshLoginDisplay];
    [self refreshUpdateTimeDisplayAsOfNow:NO];
    [self refreshPingAndStartTimer];
    
    if (![CommonFunctions isPad]) {
        [_infoBoxView setAlpha:UIDeviceOrientationIsPortrait((UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation])];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // Because of the decolorization I put in the Progress View, the adjustment mode will not turn back to automatic when pop from BTSplitView,
    // This is put to prevent the grey out when not needed.
    [[[UIApplication sharedApplication]windows][0] setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    [[[UIApplication sharedApplication] windows][0] setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - User Interaction

#pragma Shake For Testing
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        // Put in code here to handle shake
        [WSCommon storeToken:@"invalidTokenToTestTheAwesomeNewFeature"];
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

#pragma mark Bar Button
- (void)infoTapped
{
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    [self.navigationController pushViewController:aboutViewController animated:YES];
}

- (void)settingsTapped
{
    if (!_settingsController) {
        _settingsController = [[BTFilterController alloc] initWithStyle:UITableViewStyleGrouped itemArray:[self settingsItemArray] selectionArray:nil];
        [_settingsController setDelegate:self];
        [_settingsController setTitle:@"Settings"];
    }
    
    if (IS_IPAD) {
        if (!_settingPopOver) {
            _settingPopOver = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:_settingsController]];
        }
        [_settingPopOver presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self.navigationController pushViewController:_settingsController animated:YES];
    }
}


#pragma mark Info Box
- (void)refreshEventTapped
{
    [SVProgressHUD showWithStatus:@"Updating Event List..." maskType:SVProgressHUDMaskTypeBlack];
    [WSCommon getEventListWithDelegate:self];
}

- (void)changeEventTapped
{
    if (!_eventPickerVC) {
        _eventPickerVC = [[BTSubFilterController alloc] initWithStyle:UITableViewStyleGrouped];
        [_eventPickerVC setModalPresentationStyle:UIModalPresentationFormSheet];
        [_eventPickerVC setDelegate:self];
    }
    
    NSMutableArray *eventRowChoiceArray = [NSMutableArray array];
    for (NSDictionary *dict in [PersonObject eventArray]) {
        NSString *eventName = dict[@"name"];
        if ([eventName rangeOfString:@"Google Code In"].location == NSNotFound && [eventName rangeOfString:@"GCI"].location == NSNotFound) {
            NSDictionary *eventChoiceRow = [BTFilterController choiceWithString:eventName];
            [eventRowChoiceArray addObject:eventChoiceRow];
        }
    }
    
    if (eventRowChoiceArray.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Events Found" message:@"Either your event list have not been updated or we do not have any active event at this moment. Tap refresh button to get our latest list of events" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Refresh", nil];
        [alert setTag:ALERT_TAG_NO_EVENT_LIST];
        [alert show];
        return;
    }
    [_eventPickerVC setChoiceArray:eventRowChoiceArray];
    [_eventPickerVC setIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *_currentEvent = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT];
    if (_currentEvent) {
        int currentSelect = 0;
        for (NSDictionary *eventChoiceDict in eventRowChoiceArray) {
            if ([eventChoiceDict[KEY_3_CHOICE] isEqualToString:_currentEvent]) {
                break;
            }
            currentSelect++;
        }
        [_eventPickerVC setCurrentSelect:currentSelect];
    }
    
    [self presentViewController:_eventPickerVC animated:YES completion:nil];
}

#pragma mark Main
- (void)loginTapped
{
    // sanity check
    BOOL currentlyLoggedIn = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_USERNAME]? YES:NO;
    if (currentlyLoggedIn == _loginSwitch.isOn) {
        //the value DID NOT CHANGE... APPLE GET IT TOGETHER!
        return;
    }
    
    if (_loginSwitch.isOn) {
        _loginAlertView = [[UIAlertView alloc] initWithTitle:@"Login" message:[NSString stringWithFormat:@"Enter your %@ credentials and tap on the Log In button. To register, tap on the Register button", IS_TRIAGEPIC? @"TriageTrak": @"People Locator"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log In", @"Register", nil];

        [_loginAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [_loginAlertView setTag:ALERT_TAG_LOGIN];
        [_loginAlertView show];
    } else {
        UIAlertView *logoutAlertView = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"To confirm, please tap on the Log Out button" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil];
        [logoutAlertView setTag:ALERT_TAG_LOGOUT];
        [logoutAlertView show];
    }
}
- (void)findButtonTapped
{
    if (!_findViewController) {
        _findViewController = [[FindViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    
    if (IS_IPAD) {
        if (_findSpltViewController == nil) {
            UINavigationController *master = [[UINavigationController alloc] initWithRootViewController:_findViewController];
            UIViewController *controller = [[UIViewController alloc] init];
            [controller.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
            UINavigationController *detail = [[UINavigationController alloc] initWithRootViewController:controller];
            _findSpltViewController = [[BTSplitViewController alloc] initWithMaster:master detail:detail];
        }
        [self.navigationController pushViewController:_findSpltViewController animated:YES];
    } else {
        [self.navigationController pushViewController:_findViewController animated:YES];
    }
}

- (void)reportButtonTapped
{
    if (!_organizeController) {
        _organizeController = [[OrganizeController alloc] initWithStyle:UITableViewStylePlain];
    }
    
    
    if (IS_IPAD) {
        if (_reportSplitViewController == nil) {
            UINavigationController *master = [[UINavigationController alloc] initWithRootViewController:_organizeController];
            UIViewController *controller = [[UIViewController alloc] init];
            [controller.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
            UINavigationController *detail = [[UINavigationController alloc] initWithRootViewController:controller];
            _reportSplitViewController = [[BTSplitViewController alloc] initWithMaster:master detail:detail];
        }
        [self.navigationController pushViewController:_reportSplitViewController animated:YES];
    } else {
        [self.navigationController pushViewController:_organizeController animated:YES];
    }
}

#pragma mark Notification
- (void)saveAndEditNotificationCalled:(NSNotification *)notification
{
    _personObjectToEdit = notification.object;
    _sendToEdit = YES;
    [self.navigationController setDelegate:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reportButtonTapped];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_organizeController editPersonObject:personObject];
        });
    });
     */
}

- (void)logOut
{
    [_loginLabel setTitle:@" Login" forState:UIControlStateNormal];
    [_loginSwitch setOn:NO animated:YES];
}

#pragma mark - Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if ([CommonFunctions isPad]) {
        return;
    }
    [UIView animateWithDuration:duration animations:^{
        [_infoBoxView setAlpha:UIInterfaceOrientationIsPortrait(toInterfaceOrientation)];
    }];
}

#pragma mark - UI Updates
- (void)refreshEventDisplay
{
    //sanity check
    if ([PersonObject eventArray].count == 0) {
        return;
    }
    
    NSString *currentEvent = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT];
    NSDictionary *chosenEventDict;
    
    // the user has yet to select a current event
    if (!currentEvent) {
        chosenEventDict = [PersonObject eventArray][0];
        [[NSUserDefaults standardUserDefaults] setObject:chosenEventDict[@"name"] forKey:GLOBAL_KEY_CURRENT_EVENT];
    } else {
        // the user has selected, try to find the one matching it
        BOOL found = NO;
        for (NSDictionary *eventDict in [PersonObject eventArray]) {
            if ([eventDict[@"name"] isEqualToString:currentEvent]) {
                chosenEventDict = eventDict;
                found = YES;
                break;
            }
        }
        
        if (!found) {
            chosenEventDict = [PersonObject eventArray][0];
            [[NSUserDefaults standardUserDefaults] setObject:chosenEventDict[@"name"] forKey:GLOBAL_KEY_CURRENT_EVENT];
        }
    }

    NSString *dateString = chosenEventDict[@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSTimeInterval interval = [date timeIntervalSinceNow];
    int daysAgo = floor(interval/86400);
    
    [dateFormatter setDateFormat:@"MMM d, y"];
    dateString = [dateFormatter stringFromDate:date];
    
    NSString *location = chosenEventDict[@"street"];
    location = (location && ![location isEqualToString:@""])?location:@"Not Available";
    
    [_selectedEventLabel setText:[NSString stringWithFormat:@": %@", chosenEventDict[@"name"]]];
    _selectedEventLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    
    
    NSString *shortname = chosenEventDict[@"shortname"];
    
    NSLog(@"shortname%@",shortname);
    
    
    //
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    
//    
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:shortname
//                                                          action:@"Shortname"
//                                                           label:nil
//                                                           value:nil] build]];

    [_startedOnLabel setText:[NSString stringWithFormat:@": %@ (%i days ago)", dateString, -daysAgo]];
    [_locationLabel setText:[NSString stringWithFormat:@": %@", location]];

}

- (void)refreshLoginDisplay
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_USERNAME];
    if (username) {
        [_loginSwitch setOn:YES animated:YES];
        NSString *title = [NSString stringWithFormat:@" Logged in as %@", username];
        [_loginLabel setTitle:title forState:UIControlStateNormal];
    } else {
        [_loginSwitch setOn:NO animated:YES];
        [_loginLabel setTitle:@" Login" forState:UIControlStateNormal];
    }
}

- (void)refreshUpdateTimeDisplayAsOfNow:(BOOL)isNow
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"MMM d, yyyy - h:mm"];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];

    NSDate *lastUpdateTime;
    NSString *sinceString;
    if (isNow) { // if now, register the date
        lastUpdateTime = [NSDate date];
        sinceString = @"Just Now";
        //[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:GLOBAL_KEY_EVENT_UPDATE_TIME];
    } else { // if not use the registered date
        lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_EVENT_UPDATE_TIME];
        sinceString = [CommonFunctions timeDurationFrom:lastUpdateTime to:[NSDate date]];
    }
    
    if (lastUpdateTime) {
        [_lastUpdateLabel setText:[NSString stringWithFormat: @"  Updated at %@ (%@)", [dateFormatter stringFromDate:lastUpdateTime], sinceString]];
    } else {
        [_lastUpdateLabel setText:@"  Event list has never been updated"];
    }

}

- (void)refreshPingAndStartTimer
{
    [_pingTimer invalidate];
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(refreshPing) userInfo:nil repeats:YES];
    [_pingTimer setTolerance:60];
    [_pingTimer fire];
}

- (void)refreshPing
{
    // Check and Send out ping
    [WSCommon pingWithDelegate:self];
    
    // Also Look at auto upload
    [self checkAutoUpload];
}

- (void)checkAutoUpload
{
    [ReportAsyncHandler checkAndUploadFromOutBox];
}


#pragma mark - Supplemental

typedef enum {
    SettingsSectionReview,
    SettingsSectionFaceDetection,
    SettingsSectionAutoUpload,
    SettingsSectionRetainInfo,
    SettingsSectionAlert,
    SettingsSocial,
    SettingsSectionServer
}SettingsSection;

- (NSArray *)settingsItemArray
{
    // Review
    NSDictionary *reviewRow = [BTFilterController rowWithLabel:@"Review This App" cellType:BTCellTypeAction defaultValue:@"review"];
    NSDictionary *reviewSection = [BTFilterController sectionWithRowArray:@[reviewRow] header:nil footer:nil];
    
    // Face Detection
    NSDictionary *faceDetectionRow = [BTFilterController rowInputBoolWithLabel:GLOBAL_KEY_SETTINGS_FACE_DETECTION defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FACE_DETECTION]];
    NSDictionary *faceDetectionSection = [BTFilterController sectionWithRowArray:@[faceDetectionRow] header:nil footer:@"Allow app to highlight faces on photos"];
    
    // Auto upload
    NSDictionary *autoUploadRow = [BTFilterController rowInputBoolWithLabel:GLOBAL_KEY_SETTINGS_AUTO_UPLOAD defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_AUTO_UPLOAD]];
    NSDictionary *autoUploadSection = [BTFilterController sectionWithRowArray:@[autoUploadRow] header:nil footer:@"Allow app to automatically upload reports from its outbox"];
    
    // Retaining information
    NSDictionary *familyRetainRow = [BTFilterController rowInputBoolWithLabel:GLOBAL_KEY_SETTINGS_FAMILY_NAME defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FAMILY_NAME]];
    NSDictionary *statusRetainRow = [BTFilterController rowInputBoolWithLabel:GLOBAL_KEY_SETTINGS_STATUS defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_STATUS]];
    NSDictionary *locationRetainRow = [BTFilterController rowInputBoolWithLabel:GLOBAL_KEY_SETTINGS_LOCATION defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_LOCATION]];
    NSDictionary *retainSection = [BTFilterController sectionWithRowArray:@[familyRetainRow, statusRetainRow, locationRetainRow] header:@"SAVE ON DEVICE" footer:@"Allow app to save and reuse selected fields"];
    
    // Alerts
    NSDictionary *faceAlertRow = [BTFilterController rowInputBoolWithLabel:GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND]];
    NSDictionary *gpsAlertRow = [BTFilterController rowInputBoolWithLabel:GLOBAL_KEY_SETTINGS_GPS_INACCURATE defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_GPS_INACCURATE]];
    NSDictionary *alertSection = [BTFilterController sectionWithRowArray:@[faceAlertRow, gpsAlertRow] header:@"ALERTS" footer:@"Alerts for special situation"];
    
    
    //social Hub
    
   // NSDictionary *twtreviewRow = [BTFilterController rowWithLabel:@"Twitter" cellType:BTCellTypeAction defaultValue:@"https:twitter.com"];
   // NSDictionary *fbreviewRow = [BTFilterController rowWithLabel:@"Facebook" cellType:BTCellTypeAction defaultValue:nil];
    //NSDictionary *gpreviewRow = [BTFilterController rowWithLabel:@"Google+" cellType:BTCellTypeAction defaultValue:nil];


    //NSDictionary *SocialalertSection = [BTFilterController sectionWithRowArray:@[twtreviewRow, fbreviewRow,gpreviewRow] header:@"Social Hub" footer:nil];
    //
   // NSDictionary *serverChoiceRowDict = [self serverChoiceRowDict];
    //NSDictionary *removeServerRowDict = [BTFilterController rowDeleteActionWithLabel:GLOBAL_KEY_SETTINGS_SERVER_REMOVE defualtValue:@"remove"];
   // NSDictionary *serverChoiceSectionDict = [BTFilterController sectionWithRowArray:@[serverChoiceRowDict, removeServerRowDict] header:@"WEB SERVICE END POINT" footer:nil];


//    if (IS_TRIAGEPIC) {
//        // Server Choice
//       
//        
//       // return @[reviewSection, faceDetectionSection, autoUploadSection, retainSection, alertSection,serverChoiceSectionDict];//serverChoiceSectionDict
//    } else {
        return @[reviewSection, faceDetectionSection, autoUploadSection, retainSection, alertSection];
   //}
}
- (NSDictionary *)serverChoiceRowDict
{
    NSArray *serverEndPointArray = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_END_POINT_ARRAY];
    NSMutableArray *serverEndPointchoiceArray = [NSMutableArray array];
    for (NSString *endPointString in serverEndPointArray) {
        [serverEndPointchoiceArray addObject:[BTFilterController choiceWithString:endPointString]];
    }
    [serverEndPointchoiceArray addObject:[BTFilterController choiceWithString:ADD_NEW_SERVER_STRING]];
    NSString *currentEndPoint = [WSCommon currentServerString];
    NSDictionary *serverChoiceRowDict = [BTFilterController rowInputChoiceWithLabel:GLOBAL_KEY_SETTINGS_SERVER_END_POINT choiceArray:serverEndPointchoiceArray lastChoice:currentEndPoint hasColorOrImage:NO];
    return serverChoiceRowDict;
}

typedef enum {
    RegisterSectionInfo,
    RegisterSectionCred,
    RegisterSectionButton
}RegisterSection;

- (NSArray *)registerItemArray
{
    NSDictionary *firstNameRow = [BTFilterController rowInputTextWithLabel:@"First Name" defaultString:nil placeHolder:@"John"];
    NSDictionary *lastNameRow = [BTFilterController rowInputTextWithLabel:@"Last Name" defaultString:nil placeHolder:@"Smith"];
    NSDictionary *emailRow = [BTFilterController rowInputTextWithLabel:@"E-mail" defaultString:nil placeHolder:@"user@email.com" keyboardType:UIKeyboardTypeEmailAddress isSecureInput:NO shouldAutoCorrect:NO];
    NSDictionary *infoSection = [BTFilterController sectionWithRowArray:@[firstNameRow, lastNameRow, emailRow] header:@"USER INFORMATION" footer:nil];
    
    NSDictionary *usernameRow = [BTFilterController rowInputTextWithLabel:@"Username" defaultString:nil placeHolder:@"john2014" keyboardType:UIKeyboardTypeDefault isSecureInput:NO shouldAutoCorrect:NO];
    NSDictionary *passwordRow = [BTFilterController rowInputTextWithLabel:@"Password" defaultString:nil placeHolder:@"P@ssw0rd" keyboardType:UIKeyboardTypeDefault isSecureInput:YES shouldAutoCorrect:NO];
    NSDictionary *rePasswordRow = [BTFilterController rowInputTextWithLabel:@"Re-Enter" defaultString:nil placeHolder:@"P@ssw0rd" keyboardType:UIKeyboardTypeDefault isSecureInput:YES shouldAutoCorrect:NO];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:STRING_PASSWORD_GUIDE attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    NSDictionary *passwordRuleRow = [BTFilterController rowDisplayTextWithAttributeString:attrString];
    NSDictionary *credSection = [BTFilterController sectionWithRowArray:@[usernameRow, passwordRow, rePasswordRow, passwordRuleRow] header:@"CREDENTIALS" footer:nil];
    
    NSDictionary *registerButtonRow = [BTFilterController rowActionWithLabel:@"Register" defualtValue:@"register"];
    NSDictionary *cancelButtonRow = [BTFilterController rowDeleteActionWithLabel:@"Cancel" defualtValue:@"cancel"];
    NSDictionary *buttonSection = [BTFilterController sectionWithRowArray:@[registerButtonRow, cancelButtonRow] header:nil footer:nil];
    
    return @[infoSection, credSection, buttonSection];
}

typedef enum {
    ForgotSectionEmail,
    ForgotSectionButton
}ForgotSection;

- (NSArray *)forgotPasswordArray
{
    NSDictionary *emailAddressRow = [BTFilterController rowInputTextWithLabel:@"Email" defaultString:nil placeHolder:@"john.smith@email.com"];
    NSDictionary *infoSection = [BTFilterController sectionWithRowArray:@[emailAddressRow] header:@"RESET PASSWORD" footer:nil];

    NSDictionary *registerButtonRow = [BTFilterController rowActionWithLabel:@"Submit" defualtValue:@"forgot"];
    NSDictionary *cancelButtonRow = [BTFilterController rowDeleteActionWithLabel:@"Cancel" defualtValue:@"cancel"];
    NSDictionary *buttonSection = [BTFilterController sectionWithRowArray:@[registerButtonRow, cancelButtonRow] header:nil footer:nil];
    
    return @[infoSection, buttonSection];
}

- (void)registerUserWithSelectionArray:(NSArray *)selectionArray
{
    // sanity
    if (!selectionArray) {
        return;
    }
    
    // check for empty filled
    //DLog(@"%@",selectionArray);
    NSString *firstName = selectionArray[RegisterSectionInfo][@"First Name"];
    NSString *lastName = selectionArray[RegisterSectionInfo][@"First Name"];
    NSString *email = selectionArray[RegisterSectionInfo][@"E-mail"];
    NSString *username = selectionArray[RegisterSectionCred][@"Username"];
    NSString *password = selectionArray[RegisterSectionCred][@"Password"];
    NSString *password2 = selectionArray[RegisterSectionCred][@"Re-Enter"];
    
    
    // check that all feilds are filled
    if (!(firstName && lastName && email && username && password && password2)) {
        UIAlertView *missingField = [[UIAlertView alloc] initWithTitle:@"Empty Field(s)" message:@"One or more fields appears to be empty. All fields are required." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [missingField show];
        return;
    }
    
    // check password
    if (![password isEqualToString:password2]) {
        UIAlertView *passwordNotMatchAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:@"These passwords don't match. Try again?" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [passwordNotMatchAlert show];
        return;
    }
    
    // call web service
    [SVProgressHUD showWithStatus:@"Registering..." maskType:SVProgressHUDMaskTypeBlack];
    [WSCommon registerUsername:username password:password firstName:firstName lastName:lastName email:email delegate:self];
    
}

- (void)resetPassword:(NSArray *)selectionArray
{
    // sanity
    if (!selectionArray) {
        return;
    }
    
    // check for empty filled
    NSString *email = selectionArray[ForgotSectionEmail][@"Email"];
    // check that all feilds are filled
    if (![CommonFunctions verifyStringForEmailAddress:email]) {
        UIAlertView *missingField = [[UIAlertView alloc] initWithTitle:@"Invalid Email Address" message:@"Please enter a valid email address" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [missingField show];
        return;
    }
    
    // call web service
    [WSCommon forgotPasswordForEmail:email delegate:self];
}

#pragma mark Server Management
- (void)updateServerSelectionUIWithServerString:(NSString *)serverString
{
    [_settingsController.selectionArray[_settingsController.selectionArray.count - 1] setObject:serverString forKey:GLOBAL_KEY_SETTINGS_SERVER_END_POINT];
    [_settingsController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:_settingsController.selectionArray.count - 1]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateServerInfoToServerString:(NSString *)serverString
{
    // split into usable chunks
    NSArray *serverInfoArray = [CommonFunctions splitStringForEndPointWebServiceURL:serverString];
    
    [[NSUserDefaults standardUserDefaults] setObject:serverInfoArray[0] forKey:GLOBAL_KEY_SERVER_HTTP];
    [[NSUserDefaults standardUserDefaults] setObject:serverInfoArray[1] forKey:GLOBAL_KEY_SERVER_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:serverInfoArray[2] forKey:GLOBAL_KEY_SERVER_API_VERSION];
    
    [_serverAddressLabel setText:[NSString stringWithFormat:@"%@%@", serverInfoArray[0], serverInfoArray[1]]];

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:GLOBAL_KEY_CURRENT_USERNAME]; // Nullify username
    [_loginLabel setTitle:@" Login" forState:UIControlStateNormal]; // Remove the name from UI
    [_loginSwitch setOn:NO animated:YES]; // Turn off Login switch
    [WSCommon updateEndPoint]; // Change end point in the WSCommon
    [WSCommon removeToken]; // Remove Auth Token (to get new one later)
    [self refreshPingAndStartTimer]; // Refresh the ping
}

- (UIAlertView *)addServerAlert
{
    UIAlertView *newServerAlert = [[UIAlertView alloc] initWithTitle:@"Enter New Server" message:@"Make sure to enter the full URL of the server, following this format 'https://" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [newServerAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[newServerAlert textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[newServerAlert textFieldAtIndex:0] setAutocorrectionType:UITextAutocorrectionTypeNo];
    [[newServerAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeURL];
    [[newServerAlert textFieldAtIndex:0] setPlaceholder:@"https://"];
    [newServerAlert setTag:ALERT_TAG_ADD_NEW_SERVER];
    return newServerAlert;
}

- (void)removeCurrentServer
{
    NSMutableArray *endPointArray = [[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_END_POINT_ARRAY] mutableCopy];
    [endPointArray removeObject:[WSCommon currentServerString]];
    [[NSUserDefaults standardUserDefaults] setObject:endPointArray forKey:GLOBAL_KEY_SERVER_END_POINT_ARRAY];
    
    [self updateServerInfoToServerString:endPointArray[0]];
    [self updateServerSelectionUIWithServerString:endPointArray[0]];
}

#pragma mark - Delegate
#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_LOGIN) {
        switch (buttonIndex) {
            case 0:
                // cancel
                [_loginSwitch setOn:NO animated:YES];
                break;
            case 1:
                // log in
                _currentUsername = [alertView textFieldAtIndex:0].text;
                if (!_currentUsername || [_currentUsername isEqualToString:@""]) {
                    UIAlertView *noUserAlert = [[UIAlertView alloc] initWithTitle:@"Empty Username Field" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                    [noUserAlert setTag:ALERT_TAG_LOGIN_FAILED];
                    [noUserAlert show];
                } else if(![alertView textFieldAtIndex:0].text || [[alertView textFieldAtIndex:1].text isEqualToString:@""]) {
                    UIAlertView *noUserAlert = [[UIAlertView alloc] initWithTitle:@"Empty Password Field" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
                    [noUserAlert setTag:ALERT_TAG_LOGIN_FAILED];
                    [noUserAlert show];
                } else {
                    [SVProgressHUD showWithStatus:@"Logging In..." maskType:SVProgressHUDMaskTypeBlack];
                    [WSCommon authenticateWithUsername:_currentUsername password:[alertView textFieldAtIndex:1].text delegate:self];
                }
                break;
            case 2:
                // register
                if (!_registerController) {
                    _registerController = [[BTFilterController alloc] initWithStyle:UITableViewStyleGrouped itemArray:[self registerItemArray] selectionArray:nil];
                    [_registerController setModalPresentationStyle:UIModalPresentationFormSheet];
                    [_registerController setDelegate:self];
                }
                [_registerController.tableView setContentOffset:CGPointZero];
                [self presentViewController:_registerController animated:YES completion:nil];
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == ALERT_TAG_LOGIN_FAILED) {
        switch (buttonIndex) {
            case 0:
                // cancel
                [_loginSwitch setOn:NO animated:YES];
                break;
            case 1:
                // try again
                [_loginAlertView show];
                break;
            case 2:
                // Forgot password
                if (!_forgotPasswordController) {
                    _forgotPasswordController = [[BTFilterController alloc] initWithStyle:UITableViewStyleGrouped itemArray:[self forgotPasswordArray] selectionArray:nil];
                    [_forgotPasswordController setModalPresentationStyle:UIModalPresentationFormSheet];
                    [_forgotPasswordController setDelegate:self];
                }
                [_forgotPasswordController.tableView setContentOffset:CGPointZero];
                [self presentViewController:_forgotPasswordController animated:YES completion:nil];
                
            default:
                break;
        }
    }
    else if (alertView.tag == ALERT_TAG_LOGOUT) {
        switch (buttonIndex) {
            case 0:
                // cancel
                [_loginSwitch setOn:YES animated:YES];
                break;
            case 1:
                // log out
                _awaitingAnonymousToken = YES;
                [SVProgressHUD showWithStatus:@"Logging Out..." maskType:SVProgressHUDMaskTypeBlack];
                [WSCommon getAnonymousTokenWithDelegate:self];
                [HospitalObject setHospitalList:nil];
            default:
                break;
        }
    }
    else if (alertView.tag == ALERT_TAG_LOGIN_SUCCESS || alertView.tag == ALERT_TAG_LOGOUT_SUCCESS) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        [self refreshEventTapped];
    }
    else if (alertView.tag == TAG_ALERT_PUSH_NOTIFICATION) {
        [SSKeychain setPassword:@"YES" forService:SERVICE_NAME account:GLOBAL_KEY_PUSH_TOKEN_STATUS];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        [WSCommon registerPushTokenToPL];
    }
    else if (alertView.tag == ALERT_TAG_NO_EVENT_LIST) {
        [self refreshEventTapped];
    }
    else if (alertView.tag == ALERT_TAG_ADD_NEW_SERVER) {
        switch (buttonIndex) {
            case 0: // Cancel
                // Reset the choice to the current one
                [self updateServerSelectionUIWithServerString:[WSCommon currentServerString]];
                break;
            case 1: // Add
            {
                // Verify
                NSString *urlString = [alertView textFieldAtIndex:0].text;
                if ([CommonFunctions verifyStringForEndPointWebServiceURL:urlString]) {
                    
                    // Add
                    NSMutableArray *endPointArray = [[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_END_POINT_ARRAY] mutableCopy];
                    [endPointArray addObject:urlString];
                    [[NSUserDefaults standardUserDefaults] setObject:endPointArray forKey:GLOBAL_KEY_SERVER_END_POINT_ARRAY];
                    
                    // Set
                    [self updateServerInfoToServerString:urlString];
                    
                    // Update UI
                    [self updateServerSelectionUIWithServerString:urlString];
                    [_settingsController removeRow:0 fromSection:(int)_settingsController.itemArray.count-1];
                    [_settingsController insertRowDict:[self serverChoiceRowDict] inPlace:0 inSection:(int)_settingsController.itemArray.count-1];
                } else {
                    UIAlertView *newServerAlert = [self addServerAlert];
                    [newServerAlert setMessage:@"The server end point you entered does not follow the format 'https://'. Please try again."];
                    [[newServerAlert textFieldAtIndex:0] setText:urlString];
                    [newServerAlert show];
                }
            }
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == ALERT_TAG_LAST_SERVER) {
        switch (buttonIndex) {
            case 0: // cancel
                break;
            case 1: // Add a new server
                [[self addServerAlert] show];
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == ALERT_TAG_REMOVE_SERVER) {
        switch (buttonIndex) {
            case 0: // cancel
                break;
            case 1: // Remove
                // remove the current server from the list
                [self removeCurrentServer];
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == ALERT_TAG_RESET_PASSWORD_SUCCESS) {
        switch (buttonIndex) {
            case 0:
                [_forgotPasswordController dismissViewControllerAnimated:YES completion:nil];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark WSCommon
- (void)wsGetAnonTokenWithSuccess:(BOOL)success error:(id)error
{
    if (!_awaitingAnonymousToken) {
        return;
    }
    
    [SVProgressHUD dismiss];
    
    _awaitingAnonymousToken = NO;
    if (success) {
        UIAlertView *logoutSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You are now logged out" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [logoutSuccessAlert show];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:GLOBAL_KEY_CURRENT_USERNAME];
        [logoutSuccessAlert setTag:ALERT_TAG_LOGOUT_SUCCESS];
        [_loginLabel setTitle:@" Login" forState:UIControlStateNormal];
    } else {
        [_loginSwitch setOn:YES animated:YES];
        UIAlertView *logoutFailureAlert = [[UIAlertView alloc] initWithTitle:@"Unable To Log Out" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [logoutFailureAlert show];
    }
}

- (void)wsAuthenticateWithSuccess:(BOOL)success error:(id)error
{
    
    [SVProgressHUD dismiss];

    if (success) {
        [[NSUserDefaults standardUserDefaults] setObject:_currentUsername forKey:GLOBAL_KEY_CURRENT_USERNAME];
        NSString *message = [NSString stringWithFormat:@"You are now logged in as %@", _currentUsername];
        UIAlertView *loginSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [loginSuccessAlert setTag:ALERT_TAG_LOGIN_SUCCESS];
        [loginSuccessAlert show];
        
        NSString *title = [NSString stringWithFormat:@" Logged in as %@", _currentUsername];
        [_loginLabel setTitle:title forState:UIControlStateNormal];
    } else {
        [_loginSwitch setOn:YES animated:YES];
        UIAlertView *loginFailureAlert = [[UIAlertView alloc] initWithTitle:@"Unable To Log In" message:error delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Try Again", @"Forgot Password", nil];
        [loginFailureAlert setTag:ALERT_TAG_LOGIN_FAILED];
        [loginFailureAlert show];
    }
}

- (void)wsRegisterWithSuccess:(BOOL)success error:(id)error
{
    [SVProgressHUD dismiss];

    if (success) {
        UIAlertView *registerSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Thank you for registering. An e-mail with an activation link will be sent to you shortly. Once you activate your account, you may log in through the app." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [registerSuccessAlert show];
        [self dismissViewControllerAnimated:YES completion:^{
            [_registerController setSelectionArray:nil];
        }];
    } else {
        UIAlertView *registerFailedAlert = [[UIAlertView alloc] initWithTitle:@"Unable To Register" message:error delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Try Again", nil];
        [registerFailedAlert show];
    }
}



- (void)wsGetEventListWithSuccess:(BOOL)success eventArray:(NSArray *)eventArray error:(id)error
{
    [self refreshPingAndStartTimer];
    if (success) {
        // Do nothing as all the storing is done over at WSCommon
        // Refresh display UI happens either way, success or not
    } else {
        DLog(@"%@",error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Update Event List" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        if ([PersonObject eventArray].count == 0) {
            NSString *jsonString = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_EVENT_ARRAY];
            [[PersonObject eventArray] removeAllObjects];
            [[PersonObject eventArray] addObjectsFromArray:[CommonFunctions deserializedDictionaryFromJSONString:jsonString]];
        }
    }
    [self refreshEventDisplay];
    [self refreshUpdateTimeDisplayAsOfNow:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_EVENT_LIST object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];

    [SVProgressHUD dismiss];
}

- (void)wsPingWithSuccess:(BOOL)success ping:(int)ping error:(id)error
{
    if (success) {
        [_statusLabel setText:@": Online"];
        [_statusLabel setTextColor:[UIColor colorWithRed:0 green:.6 blue:0 alpha:1]];
        [_latencyLabel setText:[NSString stringWithFormat:@": %i ms", ping]];
    } else {
        [_statusLabel setText:@": Offline"];
        [_statusLabel setTextColor:[UIColor colorWithRed:.6 green:0 blue:0 alpha:1]];
        [_latencyLabel setText:[NSString stringWithFormat:@": %@", error]];
    }
}

- (void)wsResetPasswordWithSuccess:(BOOL)success error:(id)error
{
    if (success) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Please check your e-mail for further instructions" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView setTag:ALERT_TAG_RESET_PASSWORD_SUCCESS];
        [alertView show];

    } else {
        DLog(@"%@",error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Reset" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark BTSubFilterController
- (void)subFilterController:(BTSubFilterController *)subFilterController didChooseDict:(NSDictionary *)itemDict
{
    if (subFilterController == _eventPickerVC) {
        [[NSUserDefaults standardUserDefaults] setObject:itemDict[KEY_3_CHOICE] forKey:GLOBAL_KEY_CURRENT_EVENT];
        [self dismissViewControllerAnimated:YES completion:^{
            [self refreshEventDisplay];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_EVENT_LIST object:nil];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];
        }];
    }
}

#pragma mark BTFilterController
- (void)filterController:(BTFilterController *)filterController didSelectAtIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict
{
    
   // NSLog(@"%ldindexPathindexPathindexPath",(long)indexPath.section);

    if ([filterController isEqual:_settingsController]) {
        if (indexPath.section == SettingsSectionReview) {
            // detect when user select Review App
            [[iRate sharedInstance] openRatingsPageInAppStore];
        }
        
        if (indexPath.section==SettingsSocial && indexPath.section == 5 && indexPath.row == 0) {
            
            NSLog(@"%ldindexPathindexPathindexPath",(long)indexPath.section);
              NSLog(@"%ldindexPathindexPathindexPath",(long)indexPath.row
                    );
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *ourPath = @"https://twitter.com/";
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            [ourApplication openURL:ourURL];
        }
        if (indexPath.section==SettingsSocial && indexPath.section == 5 && indexPath.row==1 )
        {
            
            NSLog(@"%ldindexPathindexPathindexPath",(long)indexPath.section);
            NSLog(@"%ldindexPathindexPathindexPath",(long)indexPath.row);


            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *ourPath = @"https://www.facebook.com/";
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            [ourApplication openURL:ourURL];
        }
        
        if (indexPath.section==SettingsSocial && indexPath.section == 5 && indexPath.row==2 )
        {
            
            NSLog(@"%ldindexPathindexPathindexPath",(long)indexPath.section);
            NSLog(@"%ldindexPathindexPathindexPath",(long)indexPath.row);
            
            
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *ourPath = @"https://plus.google.com/";
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            [ourApplication openURL:ourURL];
        }
        
        else if (indexPath.section == SettingsSectionServer && indexPath.row == 1) {
            // Check if there are more than 0 server to fall back on?
            NSArray *serverArray = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_END_POINT_ARRAY];
            if (serverArray.count > 1) {
                // remove server
                NSString *message = [NSString stringWithFormat:@"You are about to remove %@ from the available list. You may add the same server into the list again manually.", [WSCommon currentServerString]];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Remove" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
                [alertView setTag:ALERT_TAG_REMOVE_SERVER];
                [alertView show];
            } else {
                // needs to add a new one
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Last Server" message:@"Add another server before you delete this one" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add a Server", nil];
                [alertView setTag:ALERT_TAG_LAST_SERVER];
                [alertView show];
            }
        }
    }
    
    else if ([filterController isEqual:_registerController]) {
        if (indexPath.section == RegisterSectionButton) {
            switch (indexPath.row) {
                case 0:
                    // register
                    [self registerUserWithSelectionArray:filterController.selectionArray];
                    break;
                case 1:
                    // cancel
                    [self dismissViewControllerAnimated:YES completion:nil];
                    break;
                default:
                    break;
            }
        }
    }
    
    else if ([filterController isEqual:_forgotPasswordController]) {
        if (indexPath.section == ForgotSectionButton) {
            switch (indexPath.row) {
                case 0:
                    // forgot password
                    [self resetPassword:filterController.selectionArray];
                    break;
                case 1:
                    // cancel
                    [self dismissViewControllerAnimated:YES completion:nil];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)filterController:(BTFilterController *)filterController didFinishSelectionArray:(NSMutableArray *)selectionArray hasChangedSelection:(BOOL)hasChangedSelection
{
    if (filterController == _settingsController && hasChangedSelection) {
        // update appropriately
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[1][GLOBAL_KEY_SETTINGS_FACE_DETECTION] boolValue] forKey:GLOBAL_KEY_SETTINGS_FACE_DETECTION];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[2][GLOBAL_KEY_SETTINGS_AUTO_UPLOAD] boolValue] forKey:GLOBAL_KEY_SETTINGS_AUTO_UPLOAD];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[3][GLOBAL_KEY_SETTINGS_FAMILY_NAME] boolValue] forKey:GLOBAL_KEY_SETTINGS_FAMILY_NAME];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[3][GLOBAL_KEY_SETTINGS_STATUS] boolValue] forKey:GLOBAL_KEY_SETTINGS_STATUS];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[3][GLOBAL_KEY_SETTINGS_LOCATION] boolValue] forKey:GLOBAL_KEY_SETTINGS_LOCATION];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[4][GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND] boolValue] forKey:GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[4][GLOBAL_KEY_SETTINGS_GPS_INACCURATE] boolValue] forKey:GLOBAL_KEY_SETTINGS_GPS_INACCURATE];
    }
}

- (void)filterController:(BTFilterController *)filterController valueForIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict changedTo:(id)value
{
    if ([rowDict[KEY_2_LABEL] isEqualToString:GLOBAL_KEY_SETTINGS_SERVER_END_POINT]) {
        if ([value[KEY_3_CHOICE] isEqualToString:ADD_NEW_SERVER_STRING]) {
            [[self addServerAlert] show];
        } else {
            [self updateServerInfoToServerString:value[KEY_3_CHOICE]];
        }
    }
}

#pragma mark SplashSubScreenViewControlleriPhone
- (void)didDismissedSplashscreen
{
    [WSCommon getEventListWithDelegate:self];
    
    // There is something really tricky about handling this
    // Until Apple supports it natively, I just ask for user's permission instead of prompt
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [WSCommon registerPushTokenToPL];
    
    /*
    //Since Apple did not provide a way to check whether or not the user has accepted Push, we will have to resort to using keychain to maintain the status
    NSString *didRequestPush = [SSKeychain passwordForService:SERVICE_NAME account:GLOBAL_KEY_PUSH_TOKEN_STATUS error:nil];

    if (!didRequestPush) {
        UIAlertView *pushNotificationAlert = [[UIAlertView alloc] initWithTitle:@"Push Notification" message:@"Following this alert, the app will prompt you to accept push notifications from us. We recommend that you accept push notifications since we use them only for important messages related to disaster events or this service." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        pushNotificationAlert.tag = TAG_ALERT_PUSH_NOTIFICATION;
        [pushNotificationAlert show];
    }
     */
}

#pragma mark UINavigationController
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Check if send to edit flag is raised
    if (_sendToEdit && _personObjectToEdit != nil) {
        // First Stage, Push from Find to Home
        if (viewController == self) {
            // Go ahead and pop to Organize
            [self reportButtonTapped];
        }
        
        if (viewController == _organizeController || viewController == _reportSplitViewController) {
            // Go ahead and push to Edit
            [_organizeController editPersonObject:_personObjectToEdit];
            
            // lastly, clean up
            _personObjectToEdit = nil;
            _sendToEdit = NO;
            [navigationController setDelegate:nil];
        }
    }
}

@end
