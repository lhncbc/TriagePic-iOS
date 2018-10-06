	//
//  ReportController.m
//  ReUnite + TriagePic
//
//  Created by Krittach on 4/1/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import "ReportController.h"
#import "PersonObject.h"
#import "SVProgressHUD.h"
#import "ImageViewer.h"
#import "HospitalObject.h"

#define CUSTOM_VIEW_LABEL_IMAGE @"ImageRow"
#define CUSTOM_VIEW_LABEL_MAP @"MapRow"
#define DEFAULT_NOTE_TEXT @"Tap to input text..."



#define TAG_ACTION_IMAGE_SOURCE 86
#define TAG_ACTION_IMAGE 88
#define TAG_ACTION_PATIENT_ID 89
#define TAG_ACTION_PATIENT_ID_MANNUAL 90

#define TAG_ALERT_SAVE_RECORD 77
#define TAG_ALERT_ENTER_PATIENT_ID 78

@interface ReportController ()

@end

@implementation ReportController
{
    // For pre loading the map cell
    // It can only reduce lag cannot eliminate it
    UITableViewCell *_mapCell;
    MKMapView *_mapView;
    
    // Store the temporary Map location
    // This contains the valid GPS coordinates, whether it be a drag/drop, longPressed, or user location
    LocationObject *_currentMapLocationObject;
    
    // For locating the user
    CLLocationManager *_locationManager;
    
    // Preventing double tap user location
    BOOL _isCurrentlyLocatingUser;
    
    // Prevent showing "save to draft?" alert
    BOOL _isSaved;
    
    // while an image is tapped, the number will reflect the index within the personObject.imageObjectArray
    int _currentImageIndex;
    
    // to scan the patient ID
    ScannerController *_scanner;
    
    // In case you need to proporgate this over to the server while re reporting
    NSMutableArray *_tempImageUrlToDelete;
}



#ifdef _IS_TRIAGEPIC
typedef enum {
    ReportSectionImage,
    ReportSectionInfo,
    ReportSectionEvent,
    ReportSectionNote,
    
    // Not used
    ReportSectionLocation
}ReportSection;

typedef enum {
    InfoRowGivenName,
    InfoRowFamilyName,
    InfoRowGender,
    InfoRowStatus,
    InfoRowAge,
    InfoRowHospitalName,
    InfoRowPatientID,
    
    // Not used
    InfoRowAgeMin,
    InfoRowAgeMax
}InfoRow;

#else
typedef enum {
    ReportSectionImage,
    ReportSectionInfo,
    ReportSectionEvent,
    ReportSectionLocation,
    ReportSectionNote,
}ReportSection;

typedef enum {
    InfoRowGivenName,
    InfoRowFamilyName,
    InfoRowGender,
    InfoRowStatus,
    InfoRowAgeMin,
    InfoRowAgeMax,
    
    // Not used
    InfoRowAge,
    InfoRowPatientID,
    InfoRowHospitalName
}InfoRow;

#endif

typedef enum {
    LocationRowMyLocation,
    LocationRowStreet1,
    LocationRowStreet2,
    LocationRowCity,
    LocationRowRegion,
    LocationRowCountry,
    LocationRowPostal,
    LocationRowTransferButtons,
    LocationRowMapView,
    LocationRowMapType
}LocationRow;

- (id)initWithPersonObject:(PersonObject *)personObject
{
    _personObject = personObject;
    NSArray *itemArray = [ReportController personItemArrayFromPersonObject:_personObject];
    self = [super initWithStyle:UITableViewStylePlain itemArray:itemArray selectionArray:nil];
    if (self) {
        _tempImageUrlToDelete = [NSMutableArray array];
        [_tempImageUrlToDelete addObjectsFromArray:_personObject.imagesURLToDelete];
        [self setDelegate:self];
        [self loadMap];
        
        // Initialize iVars
        _currentMapLocationObject = nil;
        _isSaved = NO;
        _isCurrentlyLocatingUser = NO;
        _currentImageIndex = -1;
    }
    return self;
}

- (void)fillWithPersonObject:(PersonObject *)personObject
{
    _personObject = personObject;
    NSArray *itemArray = [ReportController personItemArrayFromPersonObject:_personObject];
    [self setItemArray:itemArray];
    
    // Reset all iVars
    [_mapView removeAnnotations:_mapView.annotations];
    [_tempImageUrlToDelete addObjectsFromArray:_personObject.imagesURLToDelete];
    _currentMapLocationObject = nil;
    _isSaved = NO;
    _isCurrentlyLocatingUser = NO;
    _currentImageIndex = -1;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *uploadBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upload"] style:UIBarButtonItemStylePlain target:self action:@selector(uploadTapped)];
    UIBarButtonItem *draftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"draft"] style:UIBarButtonItemStylePlain target:self action:@selector(draftTapped)];
   
    [self.navigationItem setRightBarButtonItems:@[uploadBarButtonItem, draftBarButtonItem]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Declustered Function
- (void)loadMap
{
    _mapCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Map"];
    [_mapCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_mapCell setBackgroundColor:[UIColor greenColor]];
    
    _mapView = [[MKMapView alloc] init];
    [_mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mapView setDelegate:self];
    [_mapCell.contentView addSubview:_mapView];
    
    [_mapCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_mapView)]];
    [_mapCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mapView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_mapView)]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPressed:)];
    [_mapView addGestureRecognizer:longPress];
}


+ (NSMutableArray *)personItemArrayFromPersonObject:(PersonObject *)personObject
{
    NSMutableArray *array = [NSMutableArray array];
    if (!personObject) {
        return array;
    }
    
    // image
    NSMutableArray *imageRowsArray = [NSMutableArray array];
    for (ImageObject *imageObject in personObject.imageObjectArray) {
        NSDictionary *imageRowDict = [BTFilterController rowDisplayImageWithImage:imageObject.image height:200 defualtValue:@(TAG_ACTION_IMAGE)];
        [imageRowsArray addObject:imageRowDict];
    }
    NSDictionary *imageRowDict = [BTFilterController rowActionWithLabel:@"Add an Image" defualtValue:@(TAG_ACTION_IMAGE_SOURCE)];
    [imageRowsArray addObject:imageRowDict];
    NSDictionary *imageSectionDict = [BTFilterController sectionWithRowArray:imageRowsArray header:@"IMAGE" footer:nil];

    // info
    NSMutableArray *statusChoiceArray = [NSMutableArray array];
    NSDictionary *statusRowDict;
    if (IS_TRIAGEPIC) {
        for (NSString *zoneStr in [[PersonObject colorZoneDictionary] allKeys]) {
            [statusChoiceArray addObject:[BTFilterController choiceWithString:zoneStr textColor:[PersonObject colorForZone:zoneStr] image:nil]];
        }
        statusRowDict = [BTFilterController rowInputChoiceWithLabel:KEY_ZONE choiceArray:statusChoiceArray lastChoice:personObject.zone hasColorOrImage:YES];
    } else {
        for (NSString *statusStr in [[PersonObject statusDictionaryUpload] allKeys]) {
            if (![statusStr isEqualToString:@"Unspecified"]) {
                [statusChoiceArray addObject:[BTFilterController choiceWithString:statusStr textColor:[PersonObject colorForStatus:statusStr] image:nil]];
            }
        }
        statusRowDict = [BTFilterController rowInputChoiceWithLabel:KEY_CONDITION choiceArray:statusChoiceArray lastChoice:personObject.status hasColorOrImage:YES];
    }
    
    NSDictionary *givenNameRowDict = [BTFilterController rowInputTextWithLabel:KEY_GIVEN_NAME defaultString:personObject.givenName placeHolder:@"John"];
    NSDictionary *familyNameRowDict = [BTFilterController rowInputTextWithLabel:KEY_FAMILY_NAME defaultString:personObject.familyName placeHolder:@"Smith"];
    
    NSMutableArray *genderChoiceArray = [NSMutableArray array];
    for (NSString *genderString in [[PersonObject genderDictionaryUpload] allKeys]) {
        if (![genderString isEqualToString:@"Complex"]) {
            [genderChoiceArray addObject:[BTFilterController choiceWithString:genderString]];
        }
    }
    NSDictionary *genderRowDict = [BTFilterController rowInputChoiceWithLabel:KEY_GENDER choiceArray:genderChoiceArray lastChoice:personObject.gender hasColorOrImage:NO];
    
    
    NSDictionary *infoSectionDict;
    if (IS_TRIAGEPIC) {
        NSMutableArray *hospitalArray = [NSMutableArray array];
        for (NSString *hospitalName in [[HospitalObject hospitalNameToIdDictionary] allKeys]) {
            [hospitalArray addObject:[BTFilterController choiceWithString:hospitalName]];
        }
        
        NSDictionary *isAdultRowDict = [BTFilterController rowInputBoolWithLabel:KEY_ABOVE_18 defaultBoolean:personObject.ageMax.intValue >= 18];
        NSDictionary *hospitalNameRowDict = [BTFilterController rowInputChoiceWithLabel:KEY_HOSPITAL_NAME choiceArray:hospitalArray lastChoice:personObject.hospitalName hasColorOrImage:NO];
        NSDictionary *patientIDRowDict = [BTFilterController rowActionWithLabel:personObject.patientId defualtValue:@(TAG_ACTION_PATIENT_ID)];

        infoSectionDict = [BTFilterController sectionWithRowArray:@[givenNameRowDict, familyNameRowDict, genderRowDict, statusRowDict, isAdultRowDict, hospitalNameRowDict, patientIDRowDict] header:@"INFORMATION" footer:nil];
    } else {
        NSDictionary *ageMinRowDict = [BTFilterController rowInputTextWithLabel:KEY_AGE_MINIMUM defaultString:personObject.ageMin placeHolder:@"30" keyboardType:UIKeyboardTypeNumberPad isSecureInput:NO shouldAutoCorrect:NO];
        NSDictionary *ageMaxRowDict = [BTFilterController rowInputTextWithLabel:KEY_AGE_MAXIMUM defaultString:personObject.ageMax placeHolder:@"40" keyboardType:UIKeyboardTypeNumberPad isSecureInput:NO shouldAutoCorrect:NO];
        
        infoSectionDict = [BTFilterController sectionWithRowArray:@[givenNameRowDict, familyNameRowDict, genderRowDict, statusRowDict, ageMinRowDict, ageMaxRowDict] header:@"INFORMATION" footer:nil];
    }
   
    // event
    NSMutableArray *eventRowChoiceArray = [NSMutableArray array];
    for (NSDictionary *dict in [PersonObject eventArray]) {
        NSString *eventName = dict[@"name"];
        if ([eventName rangeOfString:@"Google Code In"].location == NSNotFound && [eventName rangeOfString:@"GCI"].location == NSNotFound) {
            NSDictionary *eventChoiceRow = [BTFilterController choiceWithString:eventName];
            [eventRowChoiceArray addObject:eventChoiceRow];
        }
    }
    NSDictionary *eventRowDict = [BTFilterController rowInputChoiceWithLabel:@" " choiceArray:eventRowChoiceArray lastChoice:personObject.event hasColorOrImage:NO];
    NSDictionary *eventSectionDict = [BTFilterController sectionWithRowArray:@[eventRowDict] header:@"EVENT" footer:nil];
   
    // Location
    NSDictionary *myLocationRowDict = [BTFilterController rowActionWithLabel:@"Use My Location" defualtValue:@"my location"];
    NSDictionary *street1RowDict = [BTFilterController rowInputTextWithLabel:KEY_STREET_1 defaultString:personObject.location.street1 placeHolder:@"8600 Rockville Pike"];
    NSDictionary *street2RowDict = [BTFilterController rowInputTextWithLabel:KEY_STREET_2 defaultString:personObject.location.street2 placeHolder:@"NLM"];
    NSDictionary *cityRowDict = [BTFilterController rowInputTextWithLabel:KEY_CITY defaultString:personObject.location.city placeHolder:@"Bethesda"];
    NSDictionary *regionRowDict = [BTFilterController rowInputTextWithLabel:KEY_REGION defaultString:personObject.location.region placeHolder:@"Maryland"];
    NSDictionary *countryRowDict = [BTFilterController rowInputTextWithLabel:KEY_COUNTRY defaultString:personObject.location.country placeHolder:@"United States"];
    NSDictionary *postalRowDict = [BTFilterController rowInputTextWithLabel:KEY_POSTAL defaultString:personObject.location.zip placeHolder:@"20894"];
    NSDictionary *mapItRowDict = [BTFilterController rowCustomCellWithHeight:44 label:@"map button"];
    NSDictionary *mapRowDict = [BTFilterController rowCustomCellWithHeight:300 label:@"Map"];
    NSDictionary *mapTypeRowDict = [BTFilterController rowCustomCellWithHeight:44 label:@"map type"];
    NSDictionary *locationSectionDict = [BTFilterController sectionWithRowArray:@[myLocationRowDict, street1RowDict, street2RowDict, cityRowDict, regionRowDict, countryRowDict, postalRowDict, mapItRowDict, mapRowDict, mapTypeRowDict] header:@"LOCATION" footer:nil];
   // locationSectionDict=nil;
    // Note
    NSAttributedString *attrStr;
    if (!personObject.additionalDetail || [personObject.additionalDetail isEqualToString:@""]) {
        attrStr = [[NSAttributedString alloc] initWithString:DEFAULT_NOTE_TEXT attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSFontAttributeName:[CommonFunctions normalFont]}];
    } else {
        attrStr = [[NSAttributedString alloc] initWithString:personObject.additionalDetail attributes:@{NSFontAttributeName:[CommonFunctions normalFont]}];
    }
    NSDictionary *noteRowDict = [BTFilterController rowInputTextBoxWithLabel:KEY_NOTE defaultAttrString:attrStr height:150];
    NSDictionary *noteSectionDict = [BTFilterController sectionWithRowArray:@[noteRowDict] header:@"NOTE" footer:nil];
    
    if (IS_TRIAGEPIC) {
        return [@[imageSectionDict, infoSectionDict, eventSectionDict, noteSectionDict] mutableCopy];
    } else {
        return [@[imageSectionDict, infoSectionDict, eventSectionDict, locationSectionDict, noteSectionDict] mutableCopy];
    }
}

- (void)saveAsDraftWithCompletionAction:(dispatch_block_t)completion
{
        [_personObject setType:PERSON_TYPE_DRAFT];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
}

// Return NO if there are invalid stuff in there
- (BOOL)refreshPersonObject
{
    [self.view endEditing:YES];
     
    PersonObject *tempPersonObject = [_personObject copy];
    [tempPersonObject removeSmallImage];

    [self setEditing:NO animated:YES];
    // info
    NSDictionary *infoDict = self.selectionArray[ReportSectionInfo];
    [tempPersonObject setGivenName:infoDict[KEY_GIVEN_NAME]];
    [tempPersonObject setFamilyName:infoDict[KEY_FAMILY_NAME]];
    if (IS_TRIAGEPIC) {
        // Zone
        [tempPersonObject setZone:infoDict[KEY_ZONE]];
        
        // Patient ID
        NSString *patientID = infoDict[KEY_PATIENT_ID];
        patientID = [patientID isEqual:@(TAG_ACTION_PATIENT_ID)]? KEY_PATIENT_ID: patientID;
        patientID = [patientID isEqualToString:KEY_PATIENT_ID]? @"": patientID;
        if (patientID == nil) {
            // Make sure that patientID has something in it!
            patientID = tempPersonObject.patientId;
        }
        [tempPersonObject setPatientId:patientID];
        
        // Hospital ID
        [tempPersonObject setHospitalName:infoDict[KEY_HOSPITAL_NAME]];
        
        // Age
        if ([infoDict[KEY_ABOVE_18] boolValue]) {
            [tempPersonObject setAgeMax:@(150).stringValue];
            [tempPersonObject setAgeMin:@(18).stringValue];
        } else {
            [tempPersonObject setAgeMax:@(17).stringValue];
            [tempPersonObject setAgeMin:@(0).stringValue];
        }
        
    } else {
        // status
        [tempPersonObject setStatus:infoDict[KEY_CONDITION]];
        
        // Location
        NSDictionary *locationDict = self.selectionArray[ReportSectionLocation];
        LocationObject *locationObject;
        if (_currentMapLocationObject) {
            locationObject = _currentMapLocationObject;
            
            // any of the following could have been edited, thus, we need to input them again
            [locationObject setStreet1:locationDict[KEY_STREET_1]];
            [locationObject setStreet2:locationDict[KEY_STREET_2]];
            [locationObject setCity:locationDict[KEY_CITY]];
            [locationObject setRegion:locationDict[KEY_REGION]];
            [locationObject setZip:locationDict[KEY_POSTAL]];
            [locationObject setCountry:locationDict[KEY_COUNTRY]];
            
            [locationObject setHasAddress:![[locationObject getLocationString] isEqualToString:@""]];
        } else {
            locationObject = [[LocationObject alloc] initWithStreet:locationDict[KEY_STREET_1]
                                                            street2:locationDict[KEY_STREET_2]
                                                               city:locationDict[KEY_CITY]
                                                             region:locationDict[KEY_REGION]
                                                                zip:locationDict[KEY_POSTAL]
                                                            country:locationDict[KEY_COUNTRY]
                                                             hasGPS:NO
                                                     gpsCoordinates:CLLocationCoordinate2DMake(0, 0)
                                                               span:MKCoordinateSpanMake(0.05, 0.05)];
        }
        [tempPersonObject setLocation:locationObject];
        
        // Age
        [tempPersonObject setAgeMax:infoDict[KEY_AGE_MAXIMUM]];
        [tempPersonObject setAgeMin:infoDict[KEY_AGE_MINIMUM]];
        
        
        // Verification
        if (tempPersonObject.ageMin == nil) {
            tempPersonObject.ageMin = @"";
        }
        
        if (tempPersonObject.ageMax == nil) {
            tempPersonObject.ageMax = @"";
        }
        
        if ([tempPersonObject.ageMin isEqualToString:@""] && ![tempPersonObject.ageMax isEqualToString:@""]) {
            tempPersonObject.ageMin = tempPersonObject.ageMax;
        }
        
        if ([tempPersonObject.ageMax isEqualToString:@""] && ![tempPersonObject.ageMin isEqualToString:@""]) {
            tempPersonObject.ageMax = tempPersonObject.ageMin;
        }
        
        if ([tempPersonObject.ageMin intValue] > [tempPersonObject.ageMax intValue]) {
            // If the age range does not make sense
            // Show Alert
            [[[UIAlertView alloc] initWithTitle:@"Invalid Age Range" message:@"Minimum age needs to be lesser than or equal to the Maximum age" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
        }
        
        if ([tempPersonObject.ageMax intValue] > 120 || [tempPersonObject.ageMin intValue] > 120) {
            [[[UIAlertView alloc] initWithTitle:@"Invalid Age" message:@"Valid Age is between 0 to 120" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
        }
    }
    
    // Gender
    [tempPersonObject setGender:infoDict[KEY_GENDER]];
    
    // Events
    NSDictionary *eventDict = self.selectionArray[ReportSectionEvent];
    [tempPersonObject setEvent:eventDict[eventDict.allKeys[0]]];
    
    // note
    NSAttributedString *noteAttrString = self.selectionArray[ReportSectionNote][KEY_NOTE];
    NSString *noteString = [noteAttrString.string isEqualToString:DEFAULT_NOTE_TEXT]?@"":noteAttrString.string;
    [tempPersonObject setAdditionalDetail:noteString];
    
    // Delete Images
    [tempPersonObject.imagesURLToDelete addObjectsFromArray:_tempImageUrlToDelete];
    [_tempImageUrlToDelete removeAllObjects];
    
    
    
    
    _personObject = tempPersonObject;
    return YES;
}

#pragma mark - User Interaction
#pragma mark Bar Button
- (void)uploadTapped
{
    if ([self refreshPersonObject]) {
        _isSaved = YES;
        
        // Save the progress in case anything happened
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        
        if ([CommonFunctions hasConnectivity]) {
            [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeBlack];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [WSCommon reportPersonWithPersonObject:_personObject delegate:self];
            });
            
        } else {
            [_personObject setType:PERSON_TYPE_OUTBOX];
            [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
            
            [self.navigationController popViewControllerAnimated:YES];
            [[[UIAlertView alloc] initWithTitle:@"No Connection" message:@"The record has been saved in the outbox and will get uploaded to the server when the Internet connectivity has been restored" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            if (_reportDelegate && [_reportDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
                [_reportDelegate refreshRecordsForType:TAG_OUTBOX];
            }
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];

    self.view.frame = CGRectMake(0, 20, 768, 1004);
   [self.view setNeedsDisplay];

    [super viewWillAppear:animated];
    [self.view setNeedsDisplay];


}
- (void)draftTapped
{
    if ([self refreshPersonObject]) {
        _isSaved = YES;
        [self saveAsDraftWithCompletionAction:^{
            [self.navigationController popViewControllerAnimated:YES];
            if (_reportDelegate && [_reportDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
                [_reportDelegate refreshRecordsForType:TAG_DRAFT];
            }
        }];
    }
}

- (void)userLocationTapped
{
    if (_isCurrentlyLocatingUser) {
        return;
    }
    _isCurrentlyLocatingUser = YES;
    
    if (![CLLocationManager locationServicesEnabled]) {
        //the phone's gps is not enabled
        UIAlertView *gpsDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Please enable your phone's Location Services. This can be located in Settings > Privacy > Location Services" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [gpsDisabledAlert show];
        _isCurrentlyLocatingUser = NO;
        return;
    }
    
    UIAlertView *noGPSAlert;
    switch ([CLLocationManager authorizationStatus]) {//find out the autherization
        case kCLAuthorizationStatusAuthorized:
        case kCLAuthorizationStatusNotDetermined:
            // start updating to request for location access
            [[self locationManager] startUpdatingLocation];
            [SVProgressHUD showWithStatus:@"Locating your location..." maskType:SVProgressHUDMaskTypeBlack];
            break;
        case kCLAuthorizationStatusDenied:
            noGPSAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Not Allowed" message:@"Please allow this application to access your Location Services. This can be located in Settings > Privacy > Location Services" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [noGPSAlert show];
            _isCurrentlyLocatingUser = NO;
            break;
        case kCLAuthorizationStatusRestricted:
            noGPSAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Restricted" message:@"Your Location Services is Restricted. Restrictions settings can be located in Settings > General > Restriction > Location Services" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [noGPSAlert show];
            _isCurrentlyLocatingUser = NO;
            break;
        default:
            break;
    }
}

- (void)mapTypeChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            // standard
            [_mapView setMapType:MKMapTypeStandard];
            break;
        case 1:
            // statellite
            [_mapView setMapType:MKMapTypeSatellite];
            break;
        case 2:
            // hybrid
            [_mapView setMapType:MKMapTypeHybrid];
            break;
        default:
            break;
    }
    [self.view endEditing:YES];
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:LocationRowMapView inSection:ReportSectionLocation] animated:YES scrollPosition:UITableViewScrollPositionTop];
}
/*
- (void)submit
{
    [self.view endEditing:YES];
 
    DLog(@"%@",self.selectionArray);
    
    CommentObject *commentObject = [[CommentObject alloc] init];
    
    // comment
    NSAttributedString *commentAttText = self.selectionArray[ReportSectionComment][@"Comment"];
    if (![commentAttText.string isEqual:DEFAULT_INPUT_TEXT]) {
        commentObject.text = commentAttText.string? commentAttText.string:@"";
    } else {
        commentObject.text = @"";
    }
    
    // status
    NSString *status = self.selectionArray[ReportSectionStatus][@"Condition"];
    if (![status isEqual:@"Unspecified"]) {
        commentObject.status = [PersonObject statusDictionaryUpload][status];
    } else {
        commentObject.status = @"";
    }
    
    // image
    commentObject.image = _currentImage;
    
    // location
    NSMutableDictionary *selectionDict = self.selectionArray[ReportSectionLocation];
    commentObject.location = [[LocationObject alloc] init];
    commentObject.location.street1 = selectionDict[KEY_STREET_1];
    commentObject.location.street2 = selectionDict[KEY_STREET_2];
    commentObject.location.city = selectionDict[KEY_CITY];
    commentObject.location.region = selectionDict[KEY_REGION];
    commentObject.location.country = selectionDict[KEY_COUNTRY];
    commentObject.location.hasAddress = ![[commentObject.location getLocationString] isEqualToString:@""];
    commentObject.location.zip = selectionDict[KEY_POSTAL];
    if (_currentMapLocationObject) {
        commentObject.location.hasGPS = YES;
        commentObject.location.gpsCoordinates = _currentMapLocationObject.gpsCoordinates;
        commentObject.location.span = _currentMapLocationObject.span;
    }
    
    [commentObject.location removeNulls];
    [commentObject.location removeNSNulls];
    
    // uuid
    commentObject.uuid = _uuid;
    
    [WSCommon uploadCommentWithCommentObject:commentObject delegate:self];
}
*/
#pragma mark Reverse Geocoding
- (void)mapLongPressed:(UILongPressGestureRecognizer *)sender
{
    [self.view endEditing:YES];

    
    if (sender.state == UIGestureRecognizerStateBegan) {
        //remove previous annotation
        [_mapView removeAnnotations:_mapView.annotations];
        
        // get point
        CGPoint pressedPoint = [sender locationInView:_mapView];
        CLLocationCoordinate2D pressedCoor = [_mapView convertPoint:pressedPoint toCoordinateFromView:_mapView];
        MKPointAnnotation *mapAnnotation = [[MKPointAnnotation alloc] init];
        [mapAnnotation setCoordinate:pressedCoor];
        [mapAnnotation setTitle:@"Loading Address..."];
        [_mapView setRegion:MKCoordinateRegionMake(pressedCoor, MKCoordinateSpanMake(.05, .05)) animated:YES];
        [_mapView addAnnotation:mapAnnotation];
        [_mapView selectAnnotation:mapAnnotation animated:YES];
        
        //load address
        [LocationObject getpossibleLocationFromGPS:pressedCoor target:self selector:@selector(geoReverseResult:)];
    }
}

- (void)geoReverseResult:(NSArray *)locationArray
{
    // check if found
    MKPointAnnotation *mapAnnotation = _mapView.annotations[0];
    if (locationArray.count == 0) {
        // update pin
        [mapAnnotation setTitle:@"Address not found"];
        _currentMapLocationObject = nil;
        return;
    }
    
    // update the title
    [mapAnnotation setTitle:@"Match Address"];
    LocationObject *locationObject = locationArray[0];
    [mapAnnotation setSubtitle:[locationObject getLocationString]];
    [_mapView selectAnnotation:_mapView.annotations[0] animated:YES];
    
    //save location
    _currentMapLocationObject = locationObject;
    
    // update the cells
    [self updateGPSLocation:locationObject];
}

- (void)updateGPSLocation
{
    [self.view endEditing:YES];

    if (!_currentMapLocationObject) {
        [[[UIAlertView alloc] initWithTitle:@"Unpinned Map" message:@"Please long press the map to drop a pin on the disire location, in order to obtain the address." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:LocationRowMapView inSection:ReportSectionLocation] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } else {
        [self updateGPSLocation:_currentMapLocationObject];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:LocationRowStreet1 inSection:ReportSectionLocation] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)updateGPSLocation:(LocationObject *)locationObject
{
    NSMutableDictionary *selectionDict = self.selectionArray[ReportSectionLocation];
    
    selectionDict[KEY_STREET_1] = locationObject.street1;
    selectionDict[KEY_STREET_2] = locationObject.street2;
    selectionDict[KEY_CITY] = locationObject.city;
    selectionDict[KEY_REGION] = locationObject.region;
    selectionDict[KEY_COUNTRY] = locationObject.country;
    selectionDict[KEY_POSTAL] = locationObject.zip;
    
    NSArray *refreshIndexArray = @[[NSIndexPath indexPathForRow:LocationRowStreet1 inSection:ReportSectionLocation],
                                   [NSIndexPath indexPathForRow:LocationRowStreet2 inSection:ReportSectionLocation],
                                   [NSIndexPath indexPathForRow:LocationRowCity inSection:ReportSectionLocation],
                                   [NSIndexPath indexPathForRow:LocationRowRegion inSection:ReportSectionLocation],
                                   [NSIndexPath indexPathForRow:LocationRowCountry inSection:ReportSectionLocation],
                                   [NSIndexPath indexPathForRow:LocationRowPostal inSection:ReportSectionLocation]];
    
    [self.tableView reloadRowsAtIndexPaths:refreshIndexArray withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark Forward Geocoding
- (void)mapsGPSFromFields
{
    [self.view endEditing:YES];

    NSDictionary *locationDict = self.selectionArray[ReportSectionLocation];
    
    NSString *locationString = @"";
    locationString = [locationString stringByAppendingString:[self getStringFromAddressPart:locationDict[KEY_STREET_1]]];
    locationString = [locationString stringByAppendingString:[self getStringFromAddressPart:locationDict[KEY_STREET_2]]];
    locationString = [locationString stringByAppendingString:[self getStringFromAddressPart:locationDict[KEY_CITY]]];
    locationString = [locationString stringByAppendingString:[self getStringFromAddressPart:locationDict[KEY_REGION]]];
    locationString = [locationString stringByAppendingString:[self getStringFromAddressPart:locationDict[KEY_COUNTRY]]];
    locationString = [locationString stringByAppendingString:[self getStringFromAddressPart:locationDict[KEY_POSTAL]]];
    
    
    if ([locationString isEqualToString:@""]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:LocationRowStreet1 inSection:ReportSectionLocation] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Empty Address" message:@"Please fill the address with full or partial infomation, in order to obtain the possible GPS coordinates." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    } else {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:LocationRowMapView inSection:ReportSectionLocation] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [LocationObject getpossibleLocationFromString:locationString target:self selector:@selector(geoForwardResult:)];
    }
}

- (NSString *)getStringFromAddressPart:(NSString *)string
{
    if (!string) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@, ",string];
}

- (void)geoForwardResult:(NSArray *)locationArray
{
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    // check if found
    [_mapView removeAnnotations:_mapView.annotations];
    if (locationArray.count == 0) {
        // update pin
        _currentMapLocationObject = nil;
        [[[UIAlertView alloc] initWithTitle:@"Not Found" message:@"Unable to locate the coordinates with the given address" delegate:Nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        return;
    }
    
    // update the title
    LocationObject *locationObject = locationArray[0];
    _currentMapLocationObject = locationObject;
    
    MKPointAnnotation *mapAnnotation = [[MKPointAnnotation alloc] init];
    [mapAnnotation setTitle:@"Match Location"];
    [mapAnnotation setSubtitle:[locationObject getLocationString]];
    [mapAnnotation setCoordinate:locationObject.gpsCoordinates];
    [_mapView addAnnotation:mapAnnotation];
    [_mapView setRegion:MKCoordinateRegionMake(locationObject.gpsCoordinates, locationObject.span) animated:YES];
    [_mapView selectAnnotation:_mapView.annotations[0] animated:YES];
}

#pragma mark Image Update
- (void)addImageObject:(ImageObject *)imageObject
{
    [_personObject.imageObjectArray addObject:imageObject];
    NSDictionary *imageRowDict = [BTFilterController rowDisplayImageWithImage:imageObject.image height:200 defualtValue:@(TAG_ACTION_IMAGE)];
    [self insertRowDict:imageRowDict inPlace:(int)_personObject.imageObjectArray.count - 1 inSection:ReportSectionImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_personObject.imageObjectArray.count - 1 inSection:ReportSectionImage] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

- (void)removeImageAtIndex:(int)index
{
    //NSLog(@"BREAK POINT");
    // First check if this is a record that exists on PL
    if (_personObject.uuid != nil && ![_personObject.uuid isEqualToString:@""]){
        // It is, then the image that was deleted might exist on the server
        ImageObject *imageObject = _personObject.imageObjectArray[index];
        if (imageObject.imageURL != nil && ![imageObject.imageURL isEqualToString:@""]) {
            [_tempImageUrlToDelete addObject:imageObject.imageURL];
            /*
            // Go ahead and retreive the delete dictionary to sync up to server
            NSMutableDictionary *tempDeleteQueDict = [[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_QUE_DELETE_DICT] mutableCopy];
            if (!tempDeleteQueDict) {
                tempDeleteQueDict = [NSMutableDictionary dictionary];
            }
            
            // Retrieve the previous order to sync if exists
            NSString* tempString = tempDeleteQueDict[_personObject.uuid];
            if (!tempString){
                tempString = @"";
            }
#warning could be improve with array, check it again
            
            // Add the Delete to the Queue
            tempString = [tempString stringByAppendingFormat:@"%@,",imageObject.imageURL];

            // Add it back into the dictionary
            tempDeleteQueDict[_personObject.uuid] = tempString;

            // Add dictionary back to the UserDefualt
            [[NSUserDefaults standardUserDefaults] setObject:tempDeleteQueDict forKey:GLOBAL_KEY_QUE_DELETE_DICT];*/
        }
    }

    // Remove it from local storage
    [_personObject.imageObjectArray removeObjectAtIndex:index];
    [self removeRow:index fromSection:ReportSectionImage];
}

#pragma mark - User Location
- (CLLocationManager *)locationManager{
    if (_locationManager != nil){
		return _locationManager;
	}
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[_locationManager setDelegate:self];
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
	return _locationManager;
}

#pragma mark - Delegate
#pragma mark BTFilterController
- (void)filterController:(BTFilterController *)filterController setDelegateForIndexPath:(NSIndexPath *)indexPath cell:(BTFilterCell *)cell label:(NSString *)label
{
    if ([label isEqualToString:@"Note"]) {
        [cell.cellTextView setDelegate:self];
    }
}

- (UITableViewCell *)filterController:(BTFilterController *)filterController cellForIndexPath:(NSIndexPath *)indexPath label:(NSString *)label height:(CGFloat)height
{
    if ([label isEqualToString:@"Map"]) {
        if (_mapView.annotations.count == 0 && _personObject.location.hasGPS) {
            MKPointAnnotation *mapAnnotation = [[MKPointAnnotation alloc] init];
            [mapAnnotation setTitle:_personObject.location.hasGPS?@"GPS reported by the user":@"Possible GPS from the address"];
            [mapAnnotation setCoordinate:_personObject.location.gpsCoordinates];
            [_mapView addAnnotation:mapAnnotation];
            
            [_mapView selectAnnotation:mapAnnotation animated:NO];
            [_mapView setRegion:MKCoordinateRegionMake(_personObject.location.gpsCoordinates, _personObject.location.span) animated:YES];
        }
        return _mapCell;
    }
    
    if ([label isEqualToString:@"map button"]) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:label];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:label];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UIButton *downButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [downButton setTitle:@"⇊" forState:UIControlStateNormal];
            [downButton.titleLabel setFont:[CommonFunctions normalFont]];
            [downButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [downButton addTarget:self action:@selector(mapsGPSFromFields) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:downButton];
            
            UIView *placeSeparator = [[UIView alloc] init];
            [placeSeparator setTranslatesAutoresizingMaskIntoConstraints:NO];
            [placeSeparator setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
            [cell.contentView addSubview:placeSeparator];
            
            UIButton *upButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [upButton setTitle:@"⇈" forState:UIControlStateNormal];
            [upButton.titleLabel setFont:[CommonFunctions normalFont]];
            [upButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [upButton addTarget:self action:@selector(updateGPSLocation) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:upButton];
            
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[downButton]-(10)-[upButton(downButton)]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(downButton, upButton)]];
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[placeSeparator(1)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(placeSeparator)]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:placeSeparator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[downButton]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(downButton)]];
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[placeSeparator]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(placeSeparator)]];
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[upButton]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(upButton)]];
            
        }
        return cell;
    }
    
    if ([label isEqualToString:@"map type"]) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:label];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:label];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Standard", @"Satellite", @"Hybrid"]];
            [segmentControl setSelectedSegmentIndex:0];
            [segmentControl setTranslatesAutoresizingMaskIntoConstraints:NO];
            [segmentControl addTarget:self action:@selector(mapTypeChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:segmentControl];

            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[segmentControl]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(segmentControl)]];
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[segmentControl]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(segmentControl)]];
        }
        return cell;
    }
    return nil;
}

- (void)filterController:(BTFilterController *)filterController didSelectAtIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict
{
    if ([rowDict[KEY_2X_DEFAULT] isEqual:@(TAG_ACTION_IMAGE_SOURCE)]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet *imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
        [imageActionSheet setTag:TAG_ACTION_IMAGE_SOURCE];
        [imageActionSheet showFromRect:cell.frame inView:self.tableView animated:YES];
        _currentImageIndex = (int)indexPath.row;
    }
    
    if ([rowDict[KEY_2X_DEFAULT] isEqual:@(TAG_ACTION_IMAGE)]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet *imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:@"View", nil];
        [imageActionSheet setTag:TAG_ACTION_IMAGE];
        [imageActionSheet showFromRect:cell.frame inView:self.tableView animated:YES];
        _currentImageIndex = (int)indexPath.row;
    }
    
    if ([rowDict[KEY_2X_DEFAULT] isEqual:@(TAG_ACTION_PATIENT_ID)]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet *imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Input Method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Scan Barcode", @"Keyboard", @"Auto Generate", nil];
        [imageActionSheet setTag:TAG_ACTION_PATIENT_ID];
        [imageActionSheet showFromRect:cell.frame inView:self.tableView animated:YES];
    }
    
    if (indexPath.section == ReportSectionLocation && indexPath.row == LocationRowMyLocation) {
        [self userLocationTapped];
    }
}

- (void)filterController:(BTFilterController *)filterController valueForIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict changedTo:(id)value
{
    /*if ([rowDict[KEY_2_LABEL] isEqualToString:KEY_AGE_MAXIMUM]) {
        int ageMin = [self.selectionArray[ReportSectionInfo][KEY_AGE_MINIMUM] intValue];
        int ageMax = [value intValue];
        if (ageMin > ageMax || [value isEqualToString:@""]) {
            [self setValue:value forIndexPath:[NSIndexPath indexPathForRow:InfoRowAgeMin inSection:indexPath.section]];
        }
    } else if ([rowDict[KEY_2_LABEL] isEqualToString:KEY_AGE_MINIMUM]) {
        int ageMax = [self.selectionArray[ReportSectionInfo][KEY_AGE_MAXIMUM] intValue];
        int ageMin = [value intValue];
        if (ageMin > ageMax || [value isEqualToString:@""]) {
            [self setValue:value forIndexPath:[NSIndexPath indexPathForRow:InfoRowAgeMax inSection:indexPath.section]];
        }
    }*/
    
    if ([rowDict[KEY_2_LABEL] isEqualToString:KEY_HOSPITAL_NAME]) {
        [[NSUserDefaults standardUserDefaults] setObject:value[KEY_3_CHOICE] forKey:GLOBAL_KEY_CURRENT_HOSPITAL];
    }
    
    // Make sure this change propergates to the other filters
    if (indexPath.section == ReportSectionEvent) {
        [[NSUserDefaults standardUserDefaults] setObject:value[KEY_3_CHOICE] forKey:GLOBAL_KEY_CURRENT_EVENT];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_EVENT_LIST object:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];
    }
}

- (void)filterController:(BTFilterController *)filterController didFinishSelectionArray:(NSMutableArray *)selectionArray hasChangedSelection:(BOOL)hasChangedSelection
{
    if (hasChangedSelection) {
        if (self.navigationController.viewControllers == nil && !_isSaved) {
            // It has been popped!
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Save draft" message:@"Would you like to save the earlier report as a draft? Drafts are accessible by tapping the \"Draft\" tab at the bottom of the screen." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [saveAlert setTag:TAG_ALERT_SAVE_RECORD];
            [saveAlert show];
        }
    }
}

#pragma mark CLLocationManager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if ([locations count]) {
        [manager stopUpdatingLocation];
        CLLocation *location = locations[0];
        [SVProgressHUD setStatus:@"Looking up the address..."];
        
        [_mapView removeAnnotations:_mapView.annotations];
        MKPointAnnotation *mapAnnotation = [[MKPointAnnotation alloc] init];
        [mapAnnotation setCoordinate:location.coordinate];
        [mapAnnotation setTitle:@"Address Not Found"];
        [_mapView addAnnotation:mapAnnotation];
        [_mapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.05, .05)) animated:YES];
        [_mapView selectAnnotation:_mapView.annotations[0] animated:YES];
        
        NSArray *possibleLocationArray = [LocationObject getpossibleLocationFromGPS:location.coordinate];
        [self geoReverseResult:possibleLocationArray];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:LocationRowMapView inSection:ReportSectionLocation] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [SVProgressHUD dismiss];
        _isCurrentlyLocatingUser = NO;
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied && [SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
        
        UIAlertView *noGPSAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Not Allowed" message:@"Please allow this application to access your Location Services. This can be located in Settings > Privacy > Location Services" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [noGPSAlert show];
        
        _isCurrentlyLocatingUser = NO;
    }
}

#pragma mark MKMapView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }else{
        DLog(@"\nCall out for annotation view called having title: %@ and subtitle: %@ at cordinate: %@", annotation.title, annotation.subtitle, [NSString stringWithFormat:@"{Latitude: %f, Longitude: %f}", annotation.coordinate.latitude, annotation.coordinate.longitude]);
        
        static NSString *annotationViewIdentifier = @"annotationView";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
        
        if (!pinView){
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
            pinView.animatesDrop = YES;
            pinView.draggable = YES;
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.canShowCallout = YES;
        }else{
            pinView.annotation = annotation;
        }
        return pinView;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    if (newState == MKAnnotationViewDragStateEnding){
        MKPointAnnotation *mapAnnotation = mapView.annotations[0];
        [mapAnnotation setTitle:@"Loading Address..."];
        
        CLLocationCoordinate2D coor =  [view.annotation coordinate];
        //[_mapView setRegion:MKCoordinateRegionMake(coor, mapView.region.span) animated:YES];
        
        //load address
        [LocationObject getpossibleLocationFromGPS:coor target:self selector:@selector(geoReverseResult:)];
    }
}

#pragma mark UITextView
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:DEFAULT_NOTE_TEXT]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = DEFAULT_NOTE_TEXT;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.selectionArray[ReportSectionNote][KEY_NOTE] = textView.attributedText;
}

#pragma mark UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == TAG_ACTION_IMAGE_SOURCE) {
        switch (buttonIndex) {
            case 0:
                //check if camera exists, if it does go ahead and use it
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                    UIImagePickerController* cameraPickerController = [[UIImagePickerController alloc] init];
                    [cameraPickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
                    [cameraPickerController setDelegate:self];
                    cameraPickerController.modalPresentationStyle=UIModalPresentationCustom;
                    
                                   [self presentViewController:cameraPickerController animated:YES completion:nil];
                    //[[NSOperationQueue mainQueue] addOperationWithBlock:^{[self presentViewController:cameraPickerController animated:YES completion:nil];}];

                    
                } else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Unavailable" message:@"Your Device does not support Cameras" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                }
                break;
            case 1:
            {
                UIImagePickerController *galleryPickerController = [[UIImagePickerController alloc] init];
                [galleryPickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [galleryPickerController setDelegate:self];
                galleryPickerController.modalPresentationStyle=UIModalPresentationCustom;

                [self presentViewController:galleryPickerController animated:YES completion:nil];
                
                
            }
                break;
            default:
                break;
        }
    }
    
    if (actionSheet.tag == TAG_ACTION_IMAGE) {
        
        switch (buttonIndex) {
            case 0:
                // Remove
                [self removeImageAtIndex:_currentImageIndex];
                break;
            case 1:
                // View
            {
                ImageObject *imageObject = _personObject.imageObjectArray[_currentImageIndex];
                ImageViewer *imageViewer = [[ImageViewer alloc] initWithImage:imageObject.image];
                [imageViewer setTitle:[NSString stringWithFormat:@"Image #%i", _currentImageIndex + 1]];
                [self.navigationController pushViewController:imageViewer animated:YES];
                //PhotoEditViewController *photoEditViewController = [[PhotoEditViewController alloc] initWithImageObject:_personObject.imageObjectArray[_currentImageIndex] editableValue:NO delegate:self];
                //[self.navigationController pushVisdewController:photoEditViewController animated:YES];
            }
                break;
            default:
                break;
        }
    }
    
    if (actionSheet.tag == TAG_ACTION_PATIENT_ID) {
        switch (buttonIndex) {
            case 0:
                //Scan
                if (!_scanner) {
                    _scanner = [[ScannerController alloc] init];
                }
                [_scanner setDelegate:self];
                [self.navigationController pushViewController:_scanner animated:YES];
                break;
            case 1:
                //Keyboard
            {
                UIAlertView *patientIdInputAlert = [[UIAlertView alloc] initWithTitle:@"Enter Patient ID" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Set", nil];
                [patientIdInputAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [[patientIdInputAlert textFieldAtIndex:0] setPlaceholder:@"MD123456"];
                [[patientIdInputAlert textFieldAtIndex:0] setText:@""];
                [[patientIdInputAlert textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
                [[patientIdInputAlert textFieldAtIndex:0] setAutocorrectionType:UITextAutocorrectionTypeNo];
                [patientIdInputAlert setTag:TAG_ALERT_ENTER_PATIENT_ID];
                [patientIdInputAlert show];
            }
                break;
            case 2:
                // Auto generated
            {
                NSDictionary *infoDict = self.selectionArray[ReportSectionInfo];
                NSString *hospitalName = infoDict[KEY_HOSPITAL_NAME];
                int hospitalId = [[HospitalObject hospitalNameToIdDictionary][hospitalName] intValue];
                NSMutableArray *patientIds = [HospitalObject patientIdForHospitalId:hospitalId];
                
                if (patientIds.count == 0) {
                    [SVProgressHUD showWithStatus:@"Generating IDs" maskType:SVProgressHUDMaskTypeBlack];
                    int hospitalId = [[HospitalObject hospitalNameToIdDictionary][hospitalName] intValue];
                    [WSCommon getAutoGenPatientForHospitalId:hospitalId withDelegate:self];

                    return;
                }
                NSString *patientId = [patientIds firstObject];
                [patientIds removeObjectAtIndex:0];
                [self setPatientId:patientId];
            }
            default:
                break;
        }
    }
    
   // [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)setPatientId:(NSString *)patientId
{
    [self removeRow:InfoRowPatientID fromSection:ReportSectionInfo];
    // pop the first PatientID
    
    NSDictionary *patientIDRowDict = [BTFilterController rowActionWithLabel:patientId defualtValue:@(TAG_ACTION_PATIENT_ID)];
    [self insertRowDict:patientIDRowDict inPlace:InfoRowPatientID inSection:ReportSectionInfo];
    self.selectionArray[ReportSectionInfo][KEY_PATIENT_ID] = patientId;
    
}

#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    /*
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self addImageObject:imageObject];
    }];*/
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    image = [ImageObject fixOrientation:image toSize:CGSizeMake(1280, 1280)];
    
    DLog(@"%f,%f",image.size.width,image.size.height);
    ImageObject *imageObject = [[ImageObject alloc] initWithImage:image imageURL:@"" faceRect:CGRectZero faceRectAvailable:NO primary:NO delegate:self];
    PhotoEditViewController *photoEditViewController = [[PhotoEditViewController alloc] initWithImageObject:imageObject editableValue:YES delegate:self];
    photoEditViewController.modalPresentationStyle=UIModalPresentationCustom;

    [picker dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:photoEditViewController animated:YES completion:nil];
        
    }];




}


#pragma mark PhotoEditViewController delegate
- (void)photoEditDonePickingWithImageObject:(ImageObject *)imageObject{
    [_personObject removeSmallImage];
    _isSaved = NO;
    
    if (_currentImageIndex == _personObject.imageObjectArray.count) {
        [self addImageObject:imageObject];
    } else {
        _personObject.imageObjectArray[_currentImageIndex] = imageObject;
    }
    

    /*[self addImageObject:imageObject position:photoIndex];
    //add empty frame and update person object
    if (photoIndex+1 == [photoButtonArray count]) {
        [self addEmptyImageFrame];
        [_personObject.imageObjectArray addObject:imageObject];
    }else{
        (_personObject.imageObjectArray)[photoIndex] = imageObject;
    }*/
}

#pragma mark WSCommon
- (void)wsReportPersonWithSuccess:(BOOL)success uuid:(NSString *)uuid error:(id)error
{
    if (success) {
        // save it in sent
        [_personObject setType:PERSON_TYPE_SENT];
        [_personObject setUuid:uuid];
        [_personObject setWebLink:[NSString stringWithFormat:@"%@%@/edit?puuid=%@",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_HTTP],[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_NAME], uuid]];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        
        
        [self.navigationController popViewControllerAnimated:YES];
        if (_reportDelegate && [_reportDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
            [_reportDelegate refreshRecordsForType:TAG_SENT];
        }
    } else {
       // [self performSelector:@selector(presentModalViewController) withObject:nil afterDelay:1.0];

        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Upload " message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alertView show];
    }
    
    [SVProgressHUD dismiss];
}

- (void)wsReReportPersonWithSuccess:(BOOL)success error:(id)error
{
    if (success) {
        // save it in sent
        [_personObject setType:PERSON_TYPE_SENT];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        
        
        [self.navigationController popViewControllerAnimated:YES];
        if (_reportDelegate && [_reportDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
            [_reportDelegate refreshRecordsForType:TAG_SENT];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Upload" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
    }
    
    [SVProgressHUD dismiss];
}

- (void)wsGetReservedIdListWithSuccess:(BOOL)success hospitalID:(int)hospitalId patientIDList:(NSArray *)patientIDList error:(id)error
{
    if (success) {
        NSMutableArray *patientIds = [HospitalObject patientIdForHospitalId:hospitalId];
        [patientIds removeAllObjects];
        [patientIds addObjectsFromArray:patientIDList];
        
        // go on and add it to the field
        NSString *patientId = [patientIds firstObject];
        [patientIds removeObjectAtIndex:0];
        [self setPatientId:patientId];
    } else {
        // in case it does not work,
        [[[UIAlertView alloc] initWithTitle:@"Unable to Generate" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
    [SVProgressHUD dismiss];
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_SAVE_RECORD) {
        // alert for saving as draft
        switch (buttonIndex) {
            case 0: // NO
                break;
            case 1: // YES
                [self draftTapped];
                break;
            default:
                break;
        }
    } else if (alertView.tag == TAG_ALERT_ENTER_PATIENT_ID) {
        switch (buttonIndex) {
            case 0: // cancel
                break;
            case 1: // set
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self successScanWithString:[alertView textFieldAtIndex:0].text];
                    });
                }
            default:
                break;
        }
    }
    
}

#pragma mark ScannerController
- (void)successScanWithString:(NSString *)string
{
    if (!string || [string isEqualToString:@""]) {
        string = KEY_PATIENT_ID;
    }
    [self removeRow:InfoRowPatientID fromSection:ReportSectionInfo];
    NSDictionary *patientIDRowDict = [BTFilterController rowActionWithLabel:string defualtValue:@(TAG_ACTION_PATIENT_ID)];
    [self insertRowDict:patientIDRowDict inPlace:InfoRowPatientID inSection:ReportSectionInfo];
    
    self.selectionArray[ReportSectionInfo][KEY_PATIENT_ID] = string;
}



@end
