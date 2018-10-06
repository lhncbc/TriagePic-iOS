/*
	PLappCheckResponseType.h
	The interface definition of properties and methods for the PLappCheckResponseType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLappCheckResponseType : SoapObject
{
	NSString* _url;
	NSString* _text;
	int _errorCode;
	NSString* _errorMessage;
	
}
		
	@property (retain, nonatomic) NSString* url;
	@property (retain, nonatomic) NSString* text;
	@property int errorCode;
	@property (retain, nonatomic) NSString* errorMessage;

	+ (PLappCheckResponseType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
