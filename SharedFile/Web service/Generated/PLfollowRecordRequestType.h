//
//  PLfollowRecordRequestType.h
//  Reunite
//
//  Created by Sathishkumar on 6/4/15.
//  Copyright (c) 2015 Krittach. All rights reserved.
//

//#import <Foundation/Foundation.h>
//
//@interface PLfollowRecordRequestType : NSObject
//
//@end


#import "Soap.h"


@interface PLfollowRecordRequestType : SoapObject
{
    NSString* _token;
    NSString* _uuid;
   int _sub;
    
}

@property (retain, nonatomic) NSString* token;
@property (retain, nonatomic) NSString* uuid;
@property  int sub;

+ (PLfollowRecordRequestType*) createWithNode: (CXMLNode*) node;
- (id) initWithNode: (CXMLNode*) node;
- (NSMutableString*) serialize;
- (NSMutableString*) serialize: (NSString*) nodeName;
- (NSMutableString*) serializeAttributes;
- (NSMutableString*) serializeElements;

@end
