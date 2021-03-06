/*
	PLgetImageCountsAndTokensRequestType.h
	The interface definition of properties and methods for the PLgetImageCountsAndTokensRequestType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLgetImageCountsAndTokensRequestType : SoapObject
{
	NSString* _key;
	
}
		
	@property (retain, nonatomic) NSString* key;

	+ (PLgetImageCountsAndTokensRequestType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
