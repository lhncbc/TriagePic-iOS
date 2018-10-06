/*
	PLgetHospitalDataResponseType.h
	The interface definition of properties and methods for the PLgetHospitalDataResponseType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLgetHospitalDataResponseType : SoapObject
{
	NSString* _name;
	NSString* _shortname;
	NSString* _street1;
	NSString* _street2;
	NSString* _city;
	NSString* _county;
	NSString* _state;
	NSString* _country;
	NSString* _zip;
	NSString* _phone;
	NSString* _fax;
	NSString* _email;
	NSString* _www;
	NSString* _npi;
	NSString* _latitude;
	NSString* _longitude;
	int _errorCode;
	NSString* _errorMessage;
	
}
		
	@property (retain, nonatomic) NSString* name;
	@property (retain, nonatomic) NSString* shortname;
	@property (retain, nonatomic) NSString* street1;
	@property (retain, nonatomic) NSString* street2;
	@property (retain, nonatomic) NSString* city;
	@property (retain, nonatomic) NSString* county;
	@property (retain, nonatomic) NSString* state;
	@property (retain, nonatomic) NSString* country;
	@property (retain, nonatomic) NSString* zip;
	@property (retain, nonatomic) NSString* phone;
	@property (retain, nonatomic) NSString* fax;
	@property (retain, nonatomic) NSString* email;
	@property (retain, nonatomic) NSString* www;
	@property (retain, nonatomic) NSString* npi;
	@property (retain, nonatomic) NSString* latitude;
	@property (retain, nonatomic) NSString* longitude;
	@property int errorCode;
	@property (retain, nonatomic) NSString* errorMessage;

	+ (PLgetHospitalDataResponseType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end