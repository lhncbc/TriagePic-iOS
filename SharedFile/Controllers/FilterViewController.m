//
//  FilterViewController.m
//  ReUnite + TriagePic
//
//  Created by Krittach on 3/10/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import "FilterViewController.h"
#import "PersonObject.h"
#import "HospitalObject.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!IS_IPAD) {
        UIBarButtonItem *tmpButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action: @selector(backAction)];
        self.navigationItem.leftBarButtonItem = tmpButtonItem;
    }
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEventList) name:NOTIFICATION_UPDATE_EVENT_LIST object:nil];
}
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BTFilterCell *cell = (BTFilterCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == FilterSectionCondition) {
        NSDictionary *rowDict = self.itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row];
        UIColor *color;
        
        if (IS_TRIAGEPIC) {
            color = [PersonObject colorForZone:rowDict[KEY_2_LABEL]];
        } else {
            color = [PersonObject colorForStatus:rowDict[KEY_2_LABEL]];
            
        }
        [cell.cellLabel setTextColor:color];
        [cell setBackgroundColor:[CommonFunctions addLight:.8 ToColor:color]];

    } else {
        if (cell.cellType == BTCellTypeInputBool) {
            [cell setBackgroundColor:[UIColor whiteColor]];
            [cell.cellLabel setTextColor:[UIColor blackColor]];
        }
    }

    // For Organize Page
    if (_disableEventSelection) {
        if (indexPath.section == FilterSectionEvent) {
            [cell setUserInteractionEnabled:NO];
            [cell.cellChoice setEnabled:NO];
            [cell.cellChoice setText:@"All Events"];
        }
        else if (indexPath.section == FilterSectionOther) {
            [cell.cellTextFeild setText:@"All"];
            [cell.cellTextFeild setEnabled:NO];
            [cell.cellTextFeild setTextColor:[UIColor lightGrayColor]];
        }
        else if (indexPath.section == FilterSectionSort) {
            [cell.cellChoice setEnabled:NO];
            [cell setUserInteractionEnabled:NO];
            if (indexPath.row == 0) { // Sort By
                [cell.cellChoice setText:@"Update Time"];
            } else if (indexPath.row == 1) { // Order
                [cell.cellChoice setText:@"Descending"];
            }
        }
    } else {
        [cell setUserInteractionEnabled:YES];
        [cell.cellSwitch setEnabled:YES];
    }
    
    return cell;

}


- (void)refreshEventList
{
    // reset the event list
    [self removeRow:0 fromSection:FilterSectionEvent];
    [self addRowDict:[FilterViewController eventRowDict] toSection:FilterSectionEvent];
    
    // reset the chosen one
    self.selectionArray[FilterSectionEvent] = [@{@" ": [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT]} mutableCopy];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionEvent] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (IS_TRIAGEPIC) {
        // reset the event list
        [self removeRow:0 fromSection:FilterSectionHospital];
        [self addRowDict:[FilterViewController hospitalRowDict] toSection:FilterSectionHospital];
        
        // reset the chosen hospital
        self.selectionArray[FilterSectionHospital] = [@{@" ": [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_HOSPITAL]} mutableCopy];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionHospital] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

+ (NSDictionary *)eventRowDict
{
    // Event
    NSMutableArray *eventRowChoiceArray = [NSMutableArray array];
    for (NSDictionary *dict in [PersonObject eventArray]) {
        NSString *eventName = dict[@"name"];
        if ([eventName rangeOfString:@"Google Code In"].location == NSNotFound && [eventName rangeOfString:@"GCI"].location == NSNotFound) {
            NSDictionary *eventChoiceRow = [BTFilterController choiceWithString:eventName];
            [eventRowChoiceArray addObject:eventChoiceRow];
        }
    }
    return [BTFilterController rowInputChoiceWithLabel:@" " choiceArray:eventRowChoiceArray lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT] hasColorOrImage:NO];
}

+ (NSDictionary *)hospitalRowDict
{
    NSMutableArray *hospitalRowChoiceArray = [NSMutableArray array];
    for (NSString *hospitalName in [HospitalObject hospitalNameToIdDictionary]) {
        NSDictionary *hospitalChoiceRow = [BTFilterController choiceWithString:hospitalName];
        [hospitalRowChoiceArray addObject:hospitalChoiceRow];
    }
    [hospitalRowChoiceArray addObject:[BTFilterController choiceWithString:@"All"]];
    
    return [BTFilterController rowInputChoiceWithLabel:@" " choiceArray:hospitalRowChoiceArray lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_FILTER_HOSPITAL] hasColorOrImage:NO];
}

+ (NSArray *)filterItemArray
{
    // Status
    NSMutableArray *statusRowArray = [NSMutableArray array];
    if (IS_TRIAGEPIC) {
        for (NSString *key in [[PersonObject colorZoneDictionary] allKeys]) {
            if (![key isEqualToString:@"Unspecified"]) {
                NSDictionary *statusRow = [BTFilterController rowInputBoolWithLabel:key defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:key]]];
                [statusRowArray addObject:statusRow];
            }
        }
    } else {
        for (NSString *key in [[PersonObject statusDictionaryUpload] allKeys]) {
            if (![key isEqualToString:@"Unspecified"]) {
                NSDictionary *statusRow = [BTFilterController rowInputBoolWithLabel:key defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:key]]];
                [statusRowArray addObject:statusRow];
            }
        }
    }
    
    NSDictionary *statusSectionArray = [BTFilterController sectionWithRowArray:statusRowArray header:@"INCLUDES CONDITION" footer:nil];
    
    // Gender
    NSMutableArray *genderRowArray = [NSMutableArray array];
    for (NSString *key in [[PersonObject genderDictionaryUpload] allKeys]) {
        NSDictionary *genderRow = [BTFilterController rowInputBoolWithLabel:key defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForGender:key]]];
        [genderRowArray addObject:genderRow];
    }
    NSDictionary *genderSectionArray = [BTFilterController sectionWithRowArray:genderRowArray header:@"INCLUDES GENDER" footer:nil];
    
    // Age
    NSDictionary *ageAdultRow = [BTFilterController rowInputBoolWithLabel:@"Adult" defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_ADULT]];
    NSDictionary *ageChildRow = [BTFilterController rowInputBoolWithLabel:@"Child" defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_CHILD]];
    NSDictionary *ageUnknownRow = [BTFilterController rowInputBoolWithLabel:@"Unknown" defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_UNKNOWN]];
    NSDictionary *ageSectionArray = [BTFilterController sectionWithRowArray:@[ageAdultRow, ageChildRow, ageUnknownRow] header:@"INCLUDES AGE GROUP" footer:nil];
    
    // Event
    NSDictionary *eventSectionDict = [BTFilterController sectionWithRowArray:@[ [FilterViewController eventRowDict] ] header:@"CURRENT EVENT" footer:nil];
    
    // Sort By
    NSMutableArray *sortByRowChoiceArray = [NSMutableArray array];
    for (NSString *sortByKey in [[PersonObject sortByDictionary] allKeys]) {
        NSDictionary *sortByChoiceRow = [BTFilterController choiceWithString:sortByKey];
        [sortByRowChoiceArray addObject:sortByChoiceRow];
    }
    NSDictionary *sortByRowDict = [BTFilterController rowInputChoiceWithLabel:@"Sort By" choiceArray:sortByRowChoiceArray lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_BY] hasColorOrImage:NO];
    
    NSDictionary *sortOrderChoiceUpDict = [BTFilterController choiceWithString:@"Ascending"];
    NSDictionary *sortOrderChoiceDownDict = [BTFilterController choiceWithString:@"Descending"];
    NSDictionary *sortOrderRowDict = [BTFilterController rowInputChoiceWithLabel:@"Order" choiceArray:@[sortOrderChoiceUpDict, sortOrderChoiceDownDict] lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER] hasColorOrImage:NO];
    NSDictionary *sortSectionDict = [BTFilterController sectionWithRowArray:@[sortByRowDict, sortOrderRowDict] header:@"ITEM SORTING" footer:nil];
    
    
    // Has Image
    NSDictionary *hasImageRowDict = [BTFilterController rowInputBoolWithLabel:@"Contains Image" defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTAIN_IMAGE]];
    // Per Page
    NSDictionary *perPageRowDict = [BTFilterController rowInputTextWithLabel:@"Records per Request" defaultString:@([[NSUserDefaults standardUserDefaults] integerForKey:FILTER_PER_PAGE]).stringValue placeHolder:@"25" keyboardType:UIKeyboardTypeNumberPad isSecureInput:NO shouldAutoCorrect:NO];
    NSDictionary *otherSectionDict = [BTFilterController sectionWithRowArray:@[perPageRowDict, hasImageRowDict] header:@"OTHER" footer:nil];
    // Exact String
    NSDictionary *exactStringRow = [BTFilterController rowInputBoolWithLabel:@"Exact term" defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_EXACT_STRING]];
    NSDictionary *exactStringDict = [BTFilterController sectionWithRowArray:@[exactStringRow] header:nil footer:@"Only display result matching the exact search term"];

    if (IS_TRIAGEPIC) {
        // Hospital stuff
        NSDictionary *hospitalRowDict = [FilterViewController hospitalRowDict];
        NSDictionary *hospitalSectionDict = [BTFilterController sectionWithRowArray:@[hospitalRowDict] header:@"HOSPITAL FILTER" footer:nil];
        
        return @[eventSectionDict, sortSectionDict, statusSectionArray, genderSectionArray, ageSectionArray, hospitalSectionDict, otherSectionDict, exactStringDict];
    } else {
        return @[eventSectionDict, sortSectionDict, statusSectionArray, genderSectionArray, ageSectionArray, otherSectionDict, exactStringDict];
    }
}

+ (NSString *)keyForStatus:(NSString *)status
{
    return [NSString stringWithFormat:@"%@%@", FILTER_STATUS_LEAD , status];
}

+ (NSString *)keyForGender:(NSString *)gender
{
    return [NSString stringWithFormat:@"%@%@", FILTER_GENDER_LEAD , gender];
}

+ (void)turnOffAllTheFilters
{
    if (IS_TRIAGEPIC) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"All" forKey:GLOBAL_KEY_FILTER_HOSPITAL];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Green"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"BH Green"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Yellow"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Red"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Gray"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Black"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Unknown"]];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Alive and Well"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Deceased"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Found (no status)"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Injured"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Missing"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:@"Unknown"]];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:@"Others"]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:@"Female"]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:@"Male"]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:@"Unknown"]];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_CHILD];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_ADULT];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_UNKNOWN];

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FILTER_CONTAIN_IMAGE];
    
}

+ (void)saveSettingIntoUserDefualt:(NSArray *)selectionArray
{
    if (IS_TRIAGEPIC) {
        [[NSUserDefaults standardUserDefaults] setObject:selectionArray[FilterSectionHospital][@" "] forKey:GLOBAL_KEY_FILTER_HOSPITAL];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Green"] boolValue] forKey:[FilterViewController keyForStatus:@"Green"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"BH Green"] boolValue] forKey:[FilterViewController keyForStatus:@"BH Green"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Yellow"] boolValue] forKey:[FilterViewController keyForStatus:@"Yellow"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Red"] boolValue] forKey:[FilterViewController keyForStatus:@"Red"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Gray"] boolValue] forKey:[FilterViewController keyForStatus:@"Gray"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Black"] boolValue] forKey:[FilterViewController keyForStatus:@"Black"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Unknown"] boolValue] forKey:[FilterViewController keyForStatus:@"Unknown"]];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Alive and Well"] boolValue] forKey:[FilterViewController keyForStatus:@"Alive and Well"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Deceased"] boolValue] forKey:[FilterViewController keyForStatus:@"Deceased"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Found (no status)"] boolValue] forKey:[FilterViewController keyForStatus:@"Found (no status)"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Injured"] boolValue] forKey:[FilterViewController keyForStatus:@"Injured"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Missing"] boolValue] forKey:[FilterViewController keyForStatus:@"Missing"]];
        [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][@"Unknown"] boolValue] forKey:[FilterViewController keyForStatus:@"Unknown"]];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][@"Complex"] boolValue] forKey:[FilterViewController keyForGender:@"Complex"]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][@"Female"] boolValue] forKey:[FilterViewController keyForGender:@"Female"]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][@"Male"] boolValue] forKey:[FilterViewController keyForGender:@"Male"]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][@"Unknown"] boolValue] forKey:[FilterViewController keyForGender:@"Unknown"]];
    
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionAge][@"Child"] boolValue] forKey:FILTER_AGE_CHILD];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionAge][@"Adult"] boolValue] forKey:FILTER_AGE_ADULT];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionAge][@"Unknown"] boolValue] forKey:FILTER_AGE_UNKNOWN];
    
    int perPage = [selectionArray[FilterSectionOther][@"Records per Request"] intValue];
    if (perPage <= 0) {
        perPage = 25;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:perPage forKey:FILTER_PER_PAGE];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionOther][@"Contains Image"] boolValue] forKey:FILTER_CONTAIN_IMAGE];
    
    [[NSUserDefaults standardUserDefaults] setObject:selectionArray[FilterSectionEvent][@" "] forKey:GLOBAL_KEY_CURRENT_EVENT];
    [[NSUserDefaults standardUserDefaults] setObject:selectionArray[FilterSectionSort][@"Order"] forKey:FILTER_SORT_ORDER];
    [[NSUserDefaults standardUserDefaults] setObject:selectionArray[FilterSectionSort][@"Sort By"] forKey:FILTER_SORT_BY];
    
    
}

+ (PLsearchRequestType *)requestFromUserDefualt
{
    NSString *sortBy = [PersonObject sortByDictionary][[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_BY]];
    NSString *sortOrder = [[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER] isEqualToString:@"Ascending"]?@"asc":@"desc";
    NSString *sortString = [NSString stringWithFormat:@"%@ %@",sortBy, sortOrder];
    
    NSString *eventFullName = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT];
    NSString *eventShortName = [[PersonObject eventLongNameToShortNameDict] objectForKey:eventFullName];
    
    // get a reqest type
    PLsearchRequestType *request = [[PLsearchRequestType alloc] init];
    request.eventShortname = eventShortName;
    request.filters = [self filterJsonString];
    request.sortBy = sortString;
    request.perPage = (int)[[NSUserDefaults standardUserDefaults] integerForKey:FILTER_PER_PAGE];

    return request;
}

+ (PLsearchRequestType *)requestForRefreshWithEvent:(NSString *)event UUID:(NSString *)uuid
{
    NSString *sortBy = [PersonObject sortByDictionary][[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_BY]];
    NSString *sortOrder = [[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER] isEqualToString:@"Ascending"]?@"asc":@"desc";
    NSString *sortString = [NSString stringWithFormat:@"%@ %@",sortBy, sortOrder];
    
    NSString *eventShortName = [[PersonObject eventLongNameToShortNameDict] objectForKey:event];
    
    // get a reqest type
    PLsearchRequestType *request = [[PLsearchRequestType alloc] init];
    request.eventShortname = eventShortName;
    request.perPage = 1;
    request.sortBy = sortString;
    [request setPageStart:0];
    [request setQuery:[NSString stringWithFormat:@"p_uuid:\"%@\"", uuid]];

    return request;
}

+ (NSValue *)boolForStatus:(NSString *)status
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:status]]? @YES : @NO;
}

+ (NSValue *)boolForGender:(NSString *)gender
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForGender:gender]]? @YES : @NO;
}

+ (NSString *)filterJsonString {
    NSMutableDictionary *filterDict = [@{
                                 @"genderMale" : [self boolForGender:@"Male"],
                                 @"genderFemale" : [self boolForGender:@"Female"],
                                 @"genderComplex" : [self boolForGender:@"Complex"],
                                 @"genderUnknown" : [self boolForGender:@"Unknown"],

                                 @"ageChild" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_CHILD]? @YES: @NO,
                                 @"ageAdult" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_ADULT]?  @YES: @NO,
                                 @"ageUnknown" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_UNKNOWN]?  @YES: @NO,
                                 
                                 @"hasImage" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTAIN_IMAGE]?  @YES: @NO} mutableCopy];
    
    [filterDict addEntriesFromDictionary:[self statusOrZoneDictionary]];
    return [CommonFunctions serializedJSONStringFromDictionaryOrArray:filterDict];
}

+ (NSDictionary *)statusOrZoneDictionary
{
    NSDictionary *dictionary;
    
    if (IS_TRIAGEPIC) {
        dictionary = @{@"Green" : [self boolForStatus:@"Green"],
                       @"BH Green" : [self boolForStatus:@"BH Green"],
                       @"Yellow" : [self boolForStatus:@"Yellow"],
                       @"Red" : [self boolForStatus:@"Red"],
                       @"Gray" : [self boolForStatus:@"Gray"],
                       @"Black" : [self boolForStatus:@"Black"],
                       @"Unknown" : [self boolForStatus:@"Unknown"],
                       @"hospital" : [self hospitalFilter]};
    } else {
        dictionary = @{@"statusMissing" : [self boolForStatus:@"Missing"],
                       @"statusAlive" : [self boolForStatus:@"Alive and Well"],
                       @"statusInjured" : [self boolForStatus:@"Injured"],
                       @"statusDeceased" : [self boolForStatus:@"Deceased"],
                       @"statusUnknown" : [self boolForStatus:@"Unknown"],
                       @"statusFound" : [self boolForStatus:@"Found (no status)"]};
    }
    
    return dictionary;
}

+ (NSString *)hospitalFilter
{
    if (!IS_TRIAGEPIC) {
        return @"";
    }
    
    NSString *currentHospital = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_FILTER_HOSPITAL];
    if ([currentHospital isEqualToString:@"All"]) {
        return @"all";
    }
    
    return [HospitalObject hospitalNameToIdDictionary][currentHospital];
}

@end
