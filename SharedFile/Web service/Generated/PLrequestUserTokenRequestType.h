/*
	PLrequestUserTokenRequestType.h
	The interface definition of properties and methods for the PLrequestUserTokenRequestType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLrequestUserTokenRequestType : SoapObject
{
	NSString* _username;
	NSString* _password;
	
}
		
	@property (retain, nonatomic) NSString* username;
	@property (retain, nonatomic) NSString* password;

	+ (PLrequestUserTokenRequestType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end