/*
	PLgetHospitalLegaleseAnonResponseType.h
	The interface definition of properties and methods for the PLgetHospitalLegaleseAnonResponseType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLgetHospitalLegaleseAnonResponseType : SoapObject
{
	NSString* _legaleseAnon;
	int _errorCode;
	NSString* _errorMessage;
	
}
		
	@property (retain, nonatomic) NSString* legaleseAnon;
	@property int errorCode;
	@property (retain, nonatomic) NSString* errorMessage;

	+ (PLgetHospitalLegaleseAnonResponseType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
