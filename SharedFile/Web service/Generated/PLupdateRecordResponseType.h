/*
	PLupdateRecordResponseType.h
	The interface definition of properties and methods for the PLupdateRecordResponseType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLupdateRecordResponseType : SoapObject
{
	int _errorCode;
	NSString* _errorMessage;
	
}
		
	@property int errorCode;
	@property (retain, nonatomic) NSString* errorMessage;

	+ (PLupdateRecordResponseType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
