//
//  WSCommon.m
//  ReUnite + TriagePic
//
//  Created by Krittach on 2/27/14.
//  Copyright (c) 2014 Krittach. All rights reserved.
//

#import "WSCommon.h"
#import "SVProgressHUD.h"
#import <sys/utsname.h>

#import "HospitalObject.h"

#define TOKEN_KEY @"TOKEN_KEY"

#define PARAM_USERNAME @"username"
#define PARAM_PASSWORD @"password"
#define PARAM_TOKEN @"token"

#define ERROR_CODE_TOKEN_INVALID 1
#define ERROR_CODE_OTHER_ERROR -1

@implementation WSCommon
{
    // use for ping 1-2 punch
    NSDate *_pingStart;
    BOOL *_isInitialPing;
}

// one service for everything
static PLplusWebServices *_plService;

- (id)init
{
    self = [super init];
    if (self) {
        if (!_plService) {
            _plService = [[PLplusWebServices alloc] init];
            [_plService setLogging:YES];
        }
    }
    return self;
}

+ (WSCommon *)common
{   // Need new instance all the time
    return [[WSCommon alloc] init];
}

+ (PLplusWebServices *)plService
{
    if (!_plService) {
        _plService = [[PLplusWebServices alloc] init];
    }
    return _plService;
}

+ (void)updateEndPoint
{
    _plService = nil;
    _plService = [[PLplusWebServices alloc] init];
    
    [self removeToken];
    [self getAnonymousTokenWithDelegate:nil];
}

#pragma mark - Main functions

// To develop the web service that garuntee token
// 1.) Create class function whatever you need it to be
// 2.) Create request and response and wscommon object
// 2.a) Assign all those into the common instance
// 3.) Fill all the info into the request object less the token
// 4.) If token exists, use it and fire web service call
// 5.) If it does not exist, query the common class get token make sure to set all the function name properly


+ (void)getEventListWithDelegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(getEventList:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForEventList:)];
    [thisCommon setRequest:[[PLgetEventListRequestType alloc] init]];
    [thisCommon setResponse:[[PLgetEventListResponseType alloc] init]];
    
    // Fill info
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
    
    // Handle Hospital List
    if (IS_TRIAGEPIC) {
        [WSCommon getHospitalListWithDelegate:delegate];
    }
}


+ (void)registerUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email delegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(registerUser:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForRegisterUser:)];
    [thisCommon setRequest:[[PLregisterUserRequestType alloc] init]];
    [thisCommon setResponse:[[PLregisterUserResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setUsername:username];
    [thisCommon.request setPassword:password];
    [thisCommon.request setFamilyName:lastName];
    [thisCommon.request setGivenName:firstName];
    [thisCommon.request setEmailAddress:email];
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}


+ (void)forgotPasswordForEmail:(NSString *)email delegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(forgotUsername:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForResetPassword:)];
    [thisCommon setRequest:[[PLresetUserPasswordRequestType alloc] init]];
    [thisCommon setResponse:[[PLresetUserPasswordResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setEmail:email];
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}


+ (void)searchCountWithSearchRequestType:(PLsearchRequestType *)request delegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    PLsearchRequestType *thisRequest = [request copy];
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(search:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForSearchCount:)];
    [thisRequest setCountOnly:YES]; // Set for search count
    [thisCommon setRequest:thisRequest];
    [thisCommon setResponse:[[PLsearchResponseType alloc] init]];
    
    // Fill info
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}


+ (void)searchWithSearchRequestType:(PLsearchRequestType *)request delegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(search:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForSearch:)];
    [thisCommon setRequest:request];
    [thisCommon setResponse:[[PLsearchResponseType alloc] init]];
    
    // Fill info
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}

+ (void)uploadCommentWithCommentObject:(CommentObject *)commentObject delegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(addComment:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForComment:)];
    [thisCommon setRequest:[[PLaddCommentRequestType alloc] init]];
    [thisCommon setResponse:[[PLaddCommentResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setUuid:commentObject.uuid];
    [thisCommon.request setComment:commentObject.text];
    [thisCommon.request setSuggested_status:commentObject.status];
    [thisCommon.request setSuggested_location:[commentObject.location getLocationJSONSerializedString]];
    [thisCommon.request setSuggested_image:commentObject.image?[CommonFunctions base64EncodeStringFromImage:commentObject.image]:@""];
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}

+ (void)removeRecordFromServerWithPersonObject:(PersonObject *)personObject reason:(NSString *)reason delegate:(id<WSCommonDelegate>)delegate;
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(updateRecord:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForDelete:)];
    [thisCommon setRequest:[[PLupdateRecordRequestType alloc] init]];
    [thisCommon setResponse:[[PLupdateRecordResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setUuid:personObject.uuid];
    [thisCommon.request setShortname:[[PersonObject eventLongNameToShortNameDict] objectForKey:personObject.event]];
    if (IS_TRIAGEPIC) {
        [thisCommon.request setPayloadFormat:@"JSONPATIENT1"];
        [thisCommon.request setPayload:[personObject serializedJSONToUploadToExpire:YES]];
    } else {
        [thisCommon.request setPayloadFormat:@"REUNITE4"];
        [thisCommon.request setPayload:[personObject serializedXMLToUploadToExpire:YES]];
    }
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}


+ (void)reportAbuseWithUUID:(NSString *)uuid reason:(NSString *)reason delegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(reportAbuse:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForReportAbuse:)];
    [thisCommon setRequest:[[PLreportAbuseRequestType alloc] init]];
    [thisCommon setResponse:[[PLreportAbuseResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setUuid:uuid];
    [thisCommon.request setExplanation:reason];
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}
/*

+(void)followRecord:(NSString *)uuid sub:(int)sub delegate:(id<WSCommonDelegate>)delegate
{
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(followRecord:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForfollowRecord:)];
    [thisCommon setRequest:[[PLfollowRecordRequestType alloc] init]];
    [thisCommon setResponse:[[PLfollowRecordResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setUuid:uuid];
    [thisCommon.request setSub:sub];
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
 
}
*/
+ (void)reportPersonWithPersonObject:(PersonObject *)personObject delegate:(id<WSCommonDelegate>)delegate
{
    // This is a more involved case!
    // Given that the function can be calling reportPerson or re-reportPerson
    
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    
    // Separation starts here
    if (personObject.uuid != nil && ![personObject.uuid isEqualToString:@""]) {
        [thisCommon setWebServiceSelector:@selector(updateRecord:action:params:deserializeTo:)];
        [thisCommon setCallBackSelector:@selector(callBackForRereportPerson:)];
        [thisCommon setRequest:[[PLupdateRecordRequestType alloc] init]];
        [thisCommon setResponse:[[PLupdateRecordResponseType alloc] init]];
        
        // Fill the uuid for the re report
        [thisCommon.request setUuid:personObject.uuid];
    } else {
        [thisCommon setWebServiceSelector:@selector(report:action:params:deserializeTo:)];
        [thisCommon setCallBackSelector:@selector(callBackForReportPerson:)];
        [thisCommon setRequest:[[PLreportRequestType alloc] init]];
        [thisCommon setResponse:[[PLreportResponseType alloc] init]];
    }
    
    // Fill info
    [thisCommon.request setShortname:[[PersonObject eventLongNameToShortNameDict] objectForKey:personObject.event]];
    if (IS_TRIAGEPIC) {
        [thisCommon.request setPayloadFormat:@"JSONPATIENT1"];
        [thisCommon.request setPayload:[personObject serializedJSONToUpload]];
    } else {
        [thisCommon.request setPayloadFormat:@"REUNITE4"];
        [thisCommon.request setPayload:[personObject serializedXMLToUpload]];
    }
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}

+ (void)registerPushTokenToPL
{
    // This is a legacy function
    // Kept there because I totally forgot why it was needed in the first place o.O
    // The String is a token string that will be pushed over to the server if the user does not allow push
    [WSCommon registerPushTokenToPL:@"User-Declined-Push-Notification"];
}

+ (void)registerPushTokenToPL:(NSString *)CustomToken
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:nil]; // No need to tell user
    [thisCommon setWebServiceSelector:@selector(registerApplePushToken:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:nil];
    [thisCommon setRequest:[[PLregisterApplePushTokenRequestType alloc] init]];
    [thisCommon setResponse:[[PLregisterApplePushTokenResponseType alloc] init]];
    
    // Prepare info
    NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_PUSH_TOKEN_STRING];
    if (!pushToken){
        UIRemoteNotificationType status = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (status != UIRemoteNotificationTypeNone) {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
            return;
        }else{
            pushToken = CustomToken;
        }
    }
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_USERNAME];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = @(systemInfo.machine);
    
    NSString *deviceUserName = [ NSString stringWithFormat:@"%@ (%@) (%@) (%@) (%@)",
                                [[UIDevice currentDevice] name], deviceModel,
                                [[UIDevice currentDevice] systemVersion],
                                [[NSLocale preferredLanguages] objectAtIndex:0],
                                [[NSTimeZone localTimeZone] abbreviation] ];
    
    
    // Fill info
    [thisCommon.request setDeviceID:deviceID];
    [thisCommon.request setPushToken:pushToken];
    [thisCommon.request setUsername:username];
    [thisCommon.request setDeviceName:deviceUserName];
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}

+ (void)pingWithDelegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(pingEcho:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForPing:)];
    [thisCommon setRequest:[[PLpingEchoRequestType alloc] init]];
    [thisCommon setResponse:[[PLpingEchoResponseType alloc] init]];
    
    // Fill info
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}

#pragma mark - TriagePic Specific
+ (void)getHospitalListWithDelegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(getHospitalList:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForGetHospitalList:)];
    [thisCommon setRequest:[[PLgetHospitalListRequestType alloc] init]];
    [thisCommon setResponse:[[PLgetHospitalListResponseType alloc] init]];
    
    // Fill info
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}

+ (void)getAutoGenPatientForHospitalId:(int)hospitalID withDelegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(reservePatientIds:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForReserveHospitalID:)];
    [thisCommon setRequest:[[PLreservePatientIdsRequestType alloc] init]];
    [thisCommon setResponse:[[PLreservePatientIdsResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setHospital_uuid:hospitalID];
    
    // Check token
    if ([WSCommon retrieveToken] != nil) {
        // Token exists, use it and fire web service call
        [thisCommon.request setToken:[WSCommon retrieveToken]];
        [thisCommon callWebService];
    } else {
        [thisCommon requestTokenAndCallBack];
    }
}


#pragma mark Non Token Based API
+ (void)getAnonymousTokenWithDelegate:(id<WSCommonDelegate>)delegate
{
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon requestTokenAndCallBack];
}

+ (void)authenticateWithUsername:(NSString *)username password:(NSString *)password delegate:(id<WSCommonDelegate>)delegate
{
    // Create request and response and wscommon object
    WSCommon *thisCommon = [WSCommon common];
    [thisCommon setDelegate:delegate];
    [thisCommon setWebServiceSelector:@selector(requestUserToken:action:params:deserializeTo:)];
    [thisCommon setCallBackSelector:@selector(callBackForAuthenToken:)];
    [thisCommon setRequest:[[PLrequestUserTokenRequestType alloc] init]];
    [thisCommon setResponse:[[PLrequestUserTokenResponseType alloc] init]];
    
    // Fill info
    [thisCommon.request setUsername:username];
    [thisCommon.request setPassword:password];
    
    // Call
    [thisCommon callWebService];
}


#pragma mark - Invoke Web Service
- (void)callWebService
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[_plService methodSignatureForSelector:_webServiceSelector]];
    [inv setSelector:_webServiceSelector];
    [inv setTarget:_plService];
    
    WSCommon *this = self;
    NSMutableString *parameter = [_request serializeElements];
    
    [inv setArgument:&this atIndex:2]; // Passing in self (WSCommon object for call back)
    [inv setArgument:&_callBackSelector atIndex:3]; // Call back method
    [inv setArgument:&parameter atIndex:4]; // Parameter
    [inv setArgument:&_response atIndex:5]; // Parameter
    
    _pingStart = [NSDate date];
    [inv invoke];
}




#pragma mark - Tokens Management
- (void)requestTokenAndCallBack
{
    PLrequestAnonTokenResponseType *plRequestTokenResponse = [[PLrequestAnonTokenResponseType alloc] init];
    [_plService requestAnonToken:self action:@selector(didGetTokenToCallback:) deserializeTo:plRequestTokenResponse];
}


#pragma mark - Callbacks
#pragma mark Token
- (void)didGetTokenToCallback:(id)value
{
    // Check integrity of the response
    PLrequestAnonTokenResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    if (success) {
        if (![WSCommon storeToken:response.token]) {
            //return;
        }
        [_request setToken:response.token];
    } else {
        // Just call the web service without the token since clearly the net is down
        // This is to invoke the correct delegate without knowing what the delegate is
    }
    
    // Check if this is a part of another call
    // If yes, go and call that web service
    if (self.request && self.response) {
        [self callWebService];
        
        // Clean up, if there is a mistake during the call
        // User authenticated token could have been erased
        // Tell Home Screen to switch the log in off
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_OUT object:nil];
        
        return;
    }
    
    // If standalone call, check and call back its delegate
    if (_delegate && [_delegate respondsToSelector:@selector(wsGetAnonTokenWithSuccess:error:)]) {
        [_delegate wsGetAnonTokenWithSuccess:success error:response.errorMessage];
    }
}

- (void)callBackForAuthenToken:(id)value
{
    // This is a special case, thus has to be done manually,
    // Because we do not want to get anonymous token if user/pass failed
    
    PLrequestUserTokenResponseType *response;
    if([value isKindOfClass:[NSError class]]) {
        // Handle errors
        response = [[PLrequestUserTokenResponseType alloc] init];
        response.errorMessage = [value localizedDescription];
        response.errorCode = ERROR_CODE_OTHER_ERROR;
    } else if([value isKindOfClass:[SoapFault class]]) {
        // Handle faults
        response.errorMessage = ((SoapFault *)value).faultString;
        response.errorCode = ERROR_CODE_OTHER_ERROR;
    } else if (![value isKindOfClass:[SoapObject class]]) {
        response.errorMessage = @"Check Log";
        response.errorCode = ERROR_CODE_OTHER_ERROR;
        DLog(@"Some error at verifyResponse. value class is %@", [[value class] description]);
    } else {
        // store proper response
        response = value;
    }
    
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
   
    if (success) {
        if (![WSCommon storeToken:response.token]) {
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsAuthenticateWithSuccess:error:)]) {
        [_delegate wsAuthenticateWithSuccess:success error:response.errorMessage];
    }
}

#pragma mark Account Management
- (void)callBackForRegisterUser:(id)value
{
    // Check integrity of the response
    PLregisterUserResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }

    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        if (response.registered) {
            success = YES;
        } else {
            response.errorMessage = @"Unable to register. Please try again or contact us in the About page.";
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsRegisterWithSuccess:error:)]) {
        [_delegate wsRegisterWithSuccess:success error:response.errorMessage];
    }
}

- (void)callBackForResetPassword:(id)value
{
    // Check integrity of the response
    PLresetUserPasswordResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        if (response.sent) {
            success = YES;
        } else {
            response.errorMessage = @"No user with the email address was found";
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsResetPasswordWithSuccess:error:)]) {
        [_delegate wsResetPasswordWithSuccess:success error:response.errorMessage];
    }
}

#pragma mark EventList
- (void)callBackForEventList:(id)value
{
    // Check integrity of the response
    PLgetEventListResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    NSArray *eventArray;
    if (success) {
        [[NSUserDefaults standardUserDefaults] setObject:response.eventList forKey:GLOBAL_KEY_EVENT_ARRAY];
        eventArray = [CommonFunctions deserializedDictionaryFromJSONString:response.eventList];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:GLOBAL_KEY_EVENT_UPDATE_TIME];
        [[PersonObject eventArray] removeAllObjects];
        [[PersonObject eventArray] addObjectsFromArray:eventArray];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsGetEventListWithSuccess:eventArray:error:)]) {
        [_delegate wsGetEventListWithSuccess:success eventArray:eventArray error:response.errorMessage];
    }
}

#pragma mark Search
- (void)callBackForSearchCount:(id)value
{
    // Check integrity of the response
    PLsearchResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    int count = 0;
    if (success) {
        count = response.recordsFound;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsGetSearchCountResultWithSuccess:count:error:)]) {
        [_delegate wsGetSearchCountResultWithSuccess:success count:count error:response.errorMessage];
    }
}

- (void)callBackForSearch:(id)value
{
    // Check integrity of the response
    PLsearchResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    NSArray *resultArray;
    if (success) {
        resultArray = [CommonFunctions deserializedDictionaryFromJSONString:response.resultSet];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsGetSearchResultWithSuccess:resultArray:error:)]) {
        [_delegate wsGetSearchResultWithSuccess:success resultArray:resultArray error:response.errorMessage];
    }
}

#pragma mark Comment Upload
- (void)callBackForComment:(id)value
{
    // Check integrity of the response
    PLaddCommentResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    if (success) {
        // Set Find to refresh
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsAddCommentWithSuccess:error:)]) {
        [_delegate wsAddCommentWithSuccess:success error:response.errorMessage];
    }
}

#pragma mark Delete and Report Abuse
- (void)callBackForDelete:(id)value
{
    // Check integrity of the response
    PLupdateRecordResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsRemoveRecordWithSuccess:error:)]) {
        [_delegate wsRemoveRecordWithSuccess:success error:response.errorMessage];
    }
}

- (void)callBackForReportAbuse:(id)value
{
    // Check integrity of the response
    PLreportAbuseResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsReportAbuseWithSuccess:error:)]) {
        [_delegate wsReportAbuseWithSuccess:success error:response.errorMessage];
    }
}



//- (void)callBackForfollowRecord:(id)value
//{
//    // Check integrity of the response
//    PLfollowRecordResponseType *response = [self verifyResponse:value];
//    
//    // Check if the token is a problem
//    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
//        //It is? The verifyResponse will take care of it, just wait for that
//        return;
//    }
//    
//    // Function directly manipulate the response
//    BOOL success = NO;
//    if (response.errorCode == 0) {
//        success = YES;
//    }
//    
//    if (_delegate && [_delegate respondsToSelector:@selector(wsfollowRecordWithSuccess:error:)]) {
//        [_delegate wsfollowRecordWithSuccess:success error:response.errorMessage];
//    }
//}
#pragma mark Ping
     
- (void)callBackForPing:(id)value
{
    // Get latency asap
    float latency = -[_pingStart timeIntervalSinceNow];
    latency /= 2; // Why? because the async is messing it up the right latency
    
    // Check integrity of the response
    PLpingEchoResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    // To verify if this is the second call
    int latencyInt = [(PLpingEchoRequestType *)self.request latency];
    if (success && latencyInt == 0) {
        latencyInt = (int) floor(latency * 1000);
        [self.request setLatency:latencyInt];
        [self callWebService];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsPingWithSuccess:ping:error:)]) {
        [_delegate wsPingWithSuccess:success ping:latencyInt error:response.errorMessage];
    }
}

#pragma mark Report

- (void)callBackForReportPerson:(id)value
{
    // Check integrity of the response
    PLreportResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    NSString *uuid = @"";
    if (success) {
        uuid = response.uuid;
        
        // Set Find to refresh
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsReportPersonWithSuccess:uuid:error:)]) {
        [_delegate wsReportPersonWithSuccess:success uuid:uuid error:response.errorMessage];
    }
}

- (void)callBackForRereportPerson:(id)value
{
    // Check integrity of the response
    PLupdateRecordResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
        
        // Set Find to refresh
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];
    }
    
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsReReportPersonWithSuccess:error:)]) {
        [_delegate wsReReportPersonWithSuccess:success error:response.errorMessage];
    }
}

#pragma mark TriagePic
- (void)callBackForGetHospitalList:(id)value
{
    // Check integrity of the response
    PLgetHospitalListResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    NSArray *hospitalArray;
    if (success) {
        [HospitalObject setHospitalList:response.hospitalList];
        hospitalArray = [CommonFunctions deserializedDictionaryFromJSONString:response.hospitalList];
        //[[PersonObject hospitalArray] addObjectsFromArray:hospitalArray];
    } else {
        [HospitalObject setHospitalList:nil];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsGetHospitalListWithSuccess:hospitalList:error:)]) {
        [_delegate wsGetHospitalListWithSuccess:success hospitalList:hospitalArray error:response.errorMessage];
    }
}

- (void)callBackForReserveHospitalID:(id)value
{
    // Check integrity of the response
    PLreservePatientIdsResponseType *response = [self verifyResponse:value];
    
    // Check if the token is a problem
    if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
        //It is? The verifyResponse will take care of it, just wait for that
        return;
    }
    
    // Function directly manipulate the response
    BOOL success = NO;
    if (response.errorCode == 0) {
        success = YES;
    }
    
    NSMutableArray *autoGenIdArray;
    if (success) {
        autoGenIdArray = [CommonFunctions deserializedDictionaryFromJSONString:response.idList];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wsGetReservedIdListWithSuccess:hospitalID:patientIDList:error:)]) {
        [_delegate wsGetReservedIdListWithSuccess:success hospitalID:((PLreservePatientIdsRequestType *)_request).hospital_uuid patientIDList:autoGenIdArray error:response.errorMessage];
    }
}

#pragma mark - Error Handling
- (id)verifyResponse:(id)value
{
    PLResponseClass *response;
    if([value isKindOfClass:[NSError class]]) {
        // Handle errors
        response = [[PLResponseClass alloc] init];
        response.errorMessage = [value localizedDescription];
        response.errorCode = ERROR_CODE_OTHER_ERROR;
    } else if([value isKindOfClass:[SoapFault class]]) {
        // Handle faults
        response.errorMessage = ((SoapFault *)value).faultString;
        response.errorCode = ERROR_CODE_OTHER_ERROR;
    } else if (![value isKindOfClass:[SoapObject class]]) {
        response.errorMessage = @"Check Log";
        response.errorCode = ERROR_CODE_OTHER_ERROR;
        DLog(@"Some error at verifyResponse. value class is %@", [[value class] description]);
    } else {
        // store proper response
        response = value;
        
        // Check if token error (errorCode == 1)
        if (response.errorCode == ERROR_CODE_TOKEN_INVALID) {
            // if it is, do not panic! just run code to get token from the server!
            [self requestTokenAndCallBack];
        }
    }
    
    // return to the specific function to get the proper parse and delegate!
    return response;
}


#pragma mark - KeyChain Token Management
+ (BOOL)storeToken:(NSString *)token
{
    NSError *error;
    [SSKeychain setPassword:token forService:SERVICE_NAME account:TOKEN_KEY error:&error];
    if (error) DLog(@"%@", error.localizedDescription);
    return !error;
}

+ (NSString *)retrieveToken
{
    return [SSKeychain passwordForService:SERVICE_NAME account:TOKEN_KEY];
}

+ (BOOL)removeToken
{
    NSError *error;
    [SSKeychain deletePasswordForService:SERVICE_NAME account:TOKEN_KEY error:&error];
    if (error) DLog(@"%@", error.localizedDescription);
    return !error;
}

/*
#pragma mark - TEST

- (void)testOutput:(id)value
{
    BOOL success = NO;
    NSError *error;
    SoapFault *soapFualt;
    
    if([value isKindOfClass:[NSError class]]) {
        // Handle errors
        error = value;
    } else if([value isKindOfClass:[SoapFault class]]) {
        // Handle faults
        soapFualt = value;
    } else if ([value isKindOfClass:[SoapObject class]]) {
        // Handle result
        success = YES;
        DLog(@"%@",value);
    } else {
        DLog(@"Some error at testOutput. value class is %@", [[value class] description]);
    }
}*/

#pragma mark - Decluster Functions
+ (NSString *)getPingString
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = @(systemInfo.machine);
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = infoDictionary[@"CFBundleDisplayName"];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *osVersion =  [[UIDevice currentDevice] systemVersion];
    NSString *deviceUserName = [[UIDevice currentDevice] name];
    NSString *plUserName = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_USERNAME];
    NSString *deviceIdentifier = [NSString stringWithFormat:@"%@;%@;%@;%@;iOS-%@;%@;%@",deviceModel,deviceID,appName,appVersion,osVersion,deviceUserName,plUserName];
    
    return deviceIdentifier;
}

+ (NSString *)currentServerString
{
    return [NSString stringWithFormat:@"%@%@/?wsdl&api=%@",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_HTTP], [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_NAME], [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_API_VERSION]];
}


@end
