/*
	PLgetUuidByMassCasualtyIdRequestType.h
	The interface definition of properties and methods for the PLgetUuidByMassCasualtyIdRequestType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLgetUuidByMassCasualtyIdRequestType : SoapObject
{
	NSString* _token;
	NSString* _mcid;
	NSString* _shortname;
	
}
		
	@property (retain, nonatomic) NSString* token;
	@property (retain, nonatomic) NSString* mcid;
	@property (retain, nonatomic) NSString* shortname;

	+ (PLgetUuidByMassCasualtyIdRequestType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
