/*
	PLreservePatientIdsResponseType.h
	The interface definition of properties and methods for the PLreservePatientIdsResponseType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLreservePatientIdsResponseType : SoapObject
{
	NSString* _idList;
	int _errorCode;
	NSString* _errorMessage;
	
}
		
	@property (retain, nonatomic) NSString* idList;
	@property int errorCode;
	@property (retain, nonatomic) NSString* errorMessage;

	+ (PLreservePatientIdsResponseType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
