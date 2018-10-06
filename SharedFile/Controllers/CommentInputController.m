//
//  CommentInputController.m
//  ReUnite + TriagePic
//
//  Created by Krittach on 2/24/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#define DEFAULT_INPUT_TEXT @"Tap to input text..."
#define TAG_ACTION_IMAGE_SOURCE 86
#define TAG_ACTION_IMAGE 88

#import "WSCommon.h"
#import "CommentInputController.h"
#import "SVProgressHUD.h"

@interface CommentInputController ()

@end

@implementation CommentInputController
{
    NSString *_uuid;
    
    UITableViewCell *_mapCell;
    MKMapView *_mapView;
    
    UIImage *_currentImage;
    LocationObject *_currentMapLocationObject;
    
    ImageViewer *_imageViewer;
    
    CLLocationManager *_locationManager;
    BOOL _isCurrentlyLocatingUser;
}

- (id)init
{
    NSMutableArray *choiceArray = [CommentInputController choiceArray];
    self = [super initWithStyle:UITableViewStylePlain itemArray:choiceArray selectionArray:nil];
    if (self) {
        [self setDelegate:self];
        [self setTitle:@"Add Comment"];
        [self loadMap];
        
        UIBarButtonItem *submitBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upload"] style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
        [self.navigationItem setRightBarButtonItem:submitBarButtonItem];
    }
    return self;
}

- (void)fillWithUUID:(NSString *)uuid
{
    _uuid = uuid;
    [_mapView removeAnnotations:_mapView.annotations];
    _currentMapLocationObject = nil;
    _currentImage = nil;
    NSMutableArray *choiceArray = [CommentInputController choiceArray];
    [self setItemArray:choiceArray selectionArray:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

typedef enum {
    ReportSectionComment,
    ReportSectionStatus,
    ReportSectionImage,
    ReportSectionLocation,
    
    ReportSectionCount
}ReportSection;

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

+ (NSMutableArray *)choiceArray
{
    // Comment
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:DEFAULT_INPUT_TEXT attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSFontAttributeName:[CommonFunctions normalFont]}];
    NSDictionary *commentRowDict = [BTFilterController rowInputTextBoxWithLabel:@"Comment" defaultAttrString:attrStr height:150];
    NSDictionary *commentSectionDict = [BTFilterController sectionWithRowArray:@[commentRowDict] header:@"COMMENT" footer:nil];
    
    // Suggest Status
    NSMutableArray *statusChoiceArray = [NSMutableArray array];
    for (NSString *statusStr in [[PersonObject statusDictionaryUpload] allKeys]) {
        [statusChoiceArray addObject:[BTFilterController choiceWithString:statusStr textColor:[PersonObject colorForStatus:statusStr] image:nil]];
    }
    NSDictionary *statusRowDict = [BTFilterController rowInputChoiceWithLabel:KEY_CONDITION choiceArray:statusChoiceArray lastChoice:@"Unspecified" hasColorOrImage:YES];
    NSDictionary *statusSectionDict = [BTFilterController sectionWithRowArray:@[statusRowDict] header:@"SUGGESTED CONDITION" footer:nil];
    
    // Image
    NSDictionary *imageRowDict = [BTFilterController rowActionWithLabel:@"Add an Image" defualtValue:@(TAG_ACTION_IMAGE_SOURCE).stringValue];
    NSDictionary *imageSectionDict = [BTFilterController sectionWithRowArray:@[imageRowDict] header:@"IMAGE" footer:nil];

    
    // Suggest Location
    NSDictionary *myLocationRowDict = [BTFilterController rowActionWithLabel:@"Use My Location" defualtValue:@"my location"];
    NSDictionary *street1RowDict = [BTFilterController rowInputTextWithLabel:KEY_STREET_1 defaultString:nil placeHolder:@"8600 Rockville Pike"];
    NSDictionary *street2RowDict = [BTFilterController rowInputTextWithLabel:KEY_STREET_2 defaultString:nil placeHolder:@"NLM"];
    NSDictionary *cityRowDict = [BTFilterController rowInputTextWithLabel:KEY_CITY defaultString:nil placeHolder:@"Bethesda"];
    NSDictionary *regionRowDict = [BTFilterController rowInputTextWithLabel:KEY_REGION defaultString:nil placeHolder:@"Maryland"];
    NSDictionary *countryRowDict = [BTFilterController rowInputTextWithLabel:KEY_COUNTRY defaultString:nil placeHolder:@"United States"];
    NSDictionary *postalRowDict = [BTFilterController rowInputTextWithLabel:KEY_POSTAL defaultString:nil placeHolder:@"20894"];
    NSDictionary *mapItRowDict = [BTFilterController rowCustomCellWithHeight:44 label:@"map button"];
    NSDictionary *mapRowDict = [BTFilterController rowCustomCellWithHeight:300 label:@"Map"];
    NSDictionary *mapTypeRowDict = [BTFilterController rowCustomCellWithHeight:44 label:@"map type"];
    NSDictionary *locationSectionDict = [BTFilterController sectionWithRowArray:@[myLocationRowDict, street1RowDict, street2RowDict, cityRowDict, regionRowDict, countryRowDict, postalRowDict, mapItRowDict, mapRowDict, mapTypeRowDict] header:@"SUGGESTED LOCATION" footer:nil];

    return [@[commentSectionDict, statusSectionDict, imageSectionDict, locationSectionDict] mutableCopy];
}




#pragma mark - User Interaction
#pragma mark Bar Button
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
    NSString *status = self.selectionArray[ReportSectionStatus][KEY_CONDITION];
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
            [[self _locationManager] startUpdatingLocation];
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

#pragma mark Reverse Geocoding
- (void)mapLongPressed:(UILongPressGestureRecognizer *)sender
{
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
- (void)addOrReplaceImageWithImageObject:(UIImage *)image
{
    // remove button/image
    [self removeRow:0 fromSection:ReportSectionImage];
    _currentImage = image;

    NSDictionary *imageRowDict;
    if (!_currentImage) {
        imageRowDict = [BTFilterController rowActionWithLabel:@"Add an Image" defualtValue:@(TAG_ACTION_IMAGE_SOURCE).stringValue];
    } else {
        imageRowDict = [BTFilterController rowDisplayImageWithImage:_currentImage height:200 defualtValue:@(TAG_ACTION_IMAGE).stringValue];
    }
    
    [self addRowDict:imageRowDict toSection:ReportSectionImage];
}

#pragma mark - User Location
- (CLLocationManager *)_locationManager{
    if (_locationManager != nil){
		return _locationManager;
	}
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[_locationManager setDelegate:self];
	
	return _locationManager;
}


#pragma mark - Delegate
#pragma mark BTFilterController
- (void)filterController:(BTFilterController *)filterController setDelegateForIndexPath:(NSIndexPath *)indexPath cell:(BTFilterCell *)cell label:(NSString *)label
{
    if ([label isEqualToString:@"Comment"]) {
        [cell.cellTextView setDelegate:self];
    }
}

- (void)filterController:(BTFilterController *)filterController didSelectAtIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict
{
    if ([rowDict[KEY_2X_DEFAULT] isEqualToString:@(TAG_ACTION_IMAGE_SOURCE).stringValue]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet *imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
        [imageActionSheet setTag:TAG_ACTION_IMAGE_SOURCE];
        [imageActionSheet showFromRect:cell.frame inView:self.tableView animated:YES];
    }
    
    if ([rowDict[KEY_2X_DEFAULT] isEqualToString:@(TAG_ACTION_IMAGE).stringValue]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet *imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:@"View", nil];
        [imageActionSheet setTag:TAG_ACTION_IMAGE];
        [imageActionSheet showFromRect:cell.frame inView:self.tableView animated:YES];
    }
    
    if (indexPath.section == ReportSectionLocation && indexPath.row == LocationRowMyLocation) {
        [self userLocationTapped];
    }
}

- (UITableViewCell *)filterController:(BTFilterController *)filterController cellForIndexPath:(NSIndexPath *)indexPath label:(NSString *)label height:(CGFloat)height
{
    if ([label isEqualToString:@"Map"]) {
        return _mapCell;
    }
    
    if ([label isEqualToString:@"map button"]) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"map button"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"map button"];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            HighlightButton *downButton = [HighlightButton buttonWithType:UIButtonTypeRoundedRect];
            [downButton setTitle:@"⇊" forState:UIControlStateNormal];
            [downButton.titleLabel setFont:[CommonFunctions normalFont]];
            [downButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [downButton addTarget:self action:@selector(mapsGPSFromFields) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:downButton];
            
            UIView *placeSeparator = [[UIView alloc] init];
            [placeSeparator setTranslatesAutoresizingMaskIntoConstraints:NO];
            [placeSeparator setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
            [cell.contentView addSubview:placeSeparator];
            
            HighlightButton *upButton = [HighlightButton buttonWithType:UIButtonTypeRoundedRect];
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

#pragma mark UITextView
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:DEFAULT_INPUT_TEXT]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = DEFAULT_INPUT_TEXT;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.selectionArray[ReportSectionComment][@"Comment"] = textView.attributedText;
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

#pragma mark UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
                [self addOrReplaceImageWithImageObject:nil];
                break;
            case 1:
                // View
                if (!_imageViewer) {
                    _imageViewer = [[ImageViewer alloc] initWithImage:_currentImage];
                    [_imageViewer setTitle:@"Comment Image"];
                } else {
                    [_imageViewer setImage:_currentImage];
                }
                [self.navigationController pushViewController:_imageViewer animated:YES];
                break;
            default:
                break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    image = [ImageObject fixOrientation:image toSize:CGSizeMake(1280, 1280)];
    
    //ImageObject *imageObject = [[ImageObject alloc] initWithImage:image imageURL:@"" faceRect:CGRectZero faceRectAvailable:NO primary:NO delegate:self];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self addOrReplaceImageWithImageObject:image];
    }];
}

#pragma mark WSCommon
- (void)wsAddCommentWithSuccess:(BOOL)success error:(id)error
{
    if (success) {
        [[[UIAlertView alloc] initWithTitle:@"Successfully Submitted" message:@"Thank you for your report" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Unable To Submit" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}
@end

@implementation HighlightButton
- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        [self setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    [super setHighlighted:highlighted];
}

@end
