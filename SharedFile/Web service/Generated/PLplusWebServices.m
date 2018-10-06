/*
 PLplusWebServices.m
 The implementation classes and methods for the plusWebServices web service.
 Generated by SudzC.com
 */

#import "PLplusWebServices.h"

#import "Soap.h"

#import "PLrequestAnonTokenRequestType.h"
#import "PLgetEventListRequestType.h"
#import "PLgetGroupListRequestType.h"
#import "PLgetSessionCookieRequestType.h"
#import "PLgetImageCountsAndTokensRequestType.h"
#import "PLgetHospitalListRequestType.h"
#import "PLgetHospitalDataResponseType.h"
#import "PLrequestUserTokenRequestType.h"
#import "PLpurgeUserTokensResponseType.h"
#import "PLresetUserPasswordRequestType.h"
#import "PLforgotUsernameRequestType.h"
#import "PLupdateRecordResponseType.h"
#import "PLreportAbuseResponseType.h"
#import "PLaddCommentResponseType.h"
#import "PLappCheckRequestType.h"
#import "PLregisterApplePushTokenResponseType.h"
#import "PLgetHospitalDataRequestType.h"
#import "PLgetHospitalPolicyRequestType.h"
#import "PLgetHospitalLegaleseRequestType.h"
#import "PLgetHospitalLegaleseAnonRequestType.h"
#import "PLgetHospitalLegaleseTimestampsRequestType.h"
#import "PLreservePatientIdsRequestType.h"
#import "PLrequestAnonTokenResponseType.h"
#import "PLpurgeUserTokensRequestType.h"
#import "PLpingEchoRequestType.h"
#import "PLpingEchoResponseType.h"
#import "PLgetEventListResponseType.h"
#import "PLgetGroupListResponseType.h"
#import "PLregisterUserResponseType.h"
#import "PLchangeUserPasswordResponseType.h"
#import "PLresetUserPasswordResponseType.h"
#import "PLforgotUsernameResponseType.h"
#import "PLreportResponseType.h"
#import "PLreportAbuseRequestType.h"
#import "PLgetImageListRequestType.h"
#import "PLgetImageListResponseType.h"
#import "PLgetImageListBlockRequestType.h"
#import "PLgetImageListBlockResponseType.h"
#import "PLgetNullTokenListRequestType.h"
#import "PLgetNullTokenListResponseType.h"
#import "PLgetHospitalListResponseType.h"
#import "PLgetHospitalLegaleseResponseType.h"
#import "PLgetHospitalLegaleseAnonResponseType.h"
#import "PLgetUuidByMassCasualtyIdRequestType.h"
#import "PLgetUuidByMassCasualtyIdResponseType.h"
#import "PLreservePatientIdsResponseType.h"
#import "PLchangeUserPasswordRequestType.h"
#import "PLgetSessionCookieResponseType.h"
#import "PLreportRequestType.h"
#import "PLappCheckResponseType.h"
#import "PLgetHospitalLegaleseTimestampsResponseType.h"
#import "PLrequestUserTokenResponseType.h"
#import "PLsearchResponseType.h"
#import "PLupdateRecordRequestType.h"
#import "PLregisterApplePushTokenRequestType.h"
#import "PLregisterUserRequestType.h"
#import "PLaddCommentRequestType.h"
#import "PLgetImageCountsAndTokensResponseType.h"
#import "PLsearchRequestType.h"
#import "PLgetHospitalPolicyResponseType.h"
#import "PLfollowRecordResponseType.h"
#import "PLfollowRecordResponseType.h"

/* Implementation of the service */

@implementation PLplusWebServices

- (id) init
{
    if(self = [super init])
    {
        self.serviceUrl=@"https://";
        self.namespace = @"soap/plusWebServices";
        self.headers = nil;
        self.logging = NO;
    }
    return self;
}

- (id) initWithUsername: (NSString*) username andPassword: (NSString*) password {
    if(self = [super initWithUsername:username andPassword:password]) {
    }
    return self;
}

+ (PLplusWebServices*) service {
    return [PLplusWebServices serviceWithUsername:nil andPassword:nil];
}

+ (PLplusWebServices*) serviceWithUsername: (NSString*) username andPassword: (NSString*) password {
    return [[PLplusWebServices alloc] initWithUsername:username andPassword:password];
}


// Returns NSString*
/*  */

- (SoapRequest*)requestUserToken:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"requestUserToken" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#requestUserToken" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}


- (SoapRequest*)requestAnonToken:(id)target action:(SEL)action deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"requestAnonToken" forNamespace: self.namespace forParameters:nil withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#requestAnonToken" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)purgeUserTokens:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"purgeUserTokens" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#purgeUserTokens" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)pingEcho:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"pingEcho" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#pingEcho" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getEventList:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getEventList" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getEventList" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getGroupList:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getGroupList" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getGroupList" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)registerUser:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"registerUser" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#registerUser" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)changeUserPassword:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"changeUserPassword" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#changeUserPassword" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)resetUserPassword:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"resetUserPassword" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#resetUserPassword" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)forgotUsername:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"forgotUsername" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#forgotUsername" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getSessionCookie:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getSessionCookie" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getSessionCookie" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)search:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"search" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#search" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)report:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"report" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#report" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)updateRecord:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"updateRecord" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#updateRecord" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)reportAbuse:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"reportAbuse" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#reportAbuse" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}


- (SoapRequest*)followRecord:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"followRecord" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#followRecord" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}
- (SoapRequest*)addComment:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"addComment" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#addComment" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getImageCountsAndTokens:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getImageCountsAndTokens" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getImageCountsAndTokens" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getImageList:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getImageList" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getImageList" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getImageListBlock:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getImageListBlock" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getImageListBlock" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getNullTokenList:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getNullTokenList" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getNullTokenList" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)appCheck:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"appCheck" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#appCheck" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)registerApplePushToken:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"registerApplePushToken" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#registerApplePushToken" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getHospitalList:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getHospitalList" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getHospitalList" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getHospitalData:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getHospitalData" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getHospitalData" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getHospitalPolicy:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getHospitalPolicy" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getHospitalPolicy" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getHospitalLegalese:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getHospitalLegalese" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getHospitalLegalese" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getHospitalLegaleseAnon:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getHospitalLegaleseAnon" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getHospitalLegaleseAnon" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getHospitalLegaleseTimestamps:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getHospitalLegaleseTimestamps" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getHospitalLegaleseTimestamps" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)getUuidByMassCasualtyId:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"getUuidByMassCasualtyId" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#getUuidByMassCasualtyId" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}

- (SoapRequest*)reservePatientIds:(id)target action:(SEL)action params:(NSMutableString *)params deserializeTo:(id)deserializeTo {
    
    
    NSString* _envelope = [Soap createEnvelope: @"reservePatientIds" forNamespace: self.namespace forParameters: params withHeaders: self.headers];
    SoapRequest* _request = [SoapRequest create: target action: action service: self soapAction: @"?wsdl#reservePatientIds" postData: _envelope deserializeTo: deserializeTo];
    [_request send];
    return _request;
}
@end
