/*
	PLgetHospitalDataResponseType.h
	The implementation of properties and methods for the PLgetHospitalDataResponseType object.
	Generated by SudzC.com
*/
#import "PLgetHospitalDataResponseType.h"

@implementation PLgetHospitalDataResponseType
	@synthesize name = _name;
	@synthesize shortname = _shortname;
	@synthesize street1 = _street1;
	@synthesize street2 = _street2;
	@synthesize city = _city;
	@synthesize county = _county;
	@synthesize state = _state;
	@synthesize country = _country;
	@synthesize zip = _zip;
	@synthesize phone = _phone;
	@synthesize fax = _fax;
	@synthesize email = _email;
	@synthesize www = _www;
	@synthesize npi = _npi;
	@synthesize latitude = _latitude;
	@synthesize longitude = _longitude;
	@synthesize errorCode = _errorCode;
	@synthesize errorMessage = _errorMessage;

	- (id) init
	{
		if(self = [super init])
		{
			self.name = nil;
			self.shortname = nil;
			self.street1 = nil;
			self.street2 = nil;
			self.city = nil;
			self.county = nil;
			self.state = nil;
			self.country = nil;
			self.zip = nil;
			self.phone = nil;
			self.fax = nil;
			self.email = nil;
			self.www = nil;
			self.npi = nil;
			self.latitude = nil;
			self.longitude = nil;
			self.errorMessage = nil;

		}
		return self;
	}

	+ (PLgetHospitalDataResponseType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.name = [Soap getNodeValue: node withName: @"name"];
			self.shortname = [Soap getNodeValue: node withName: @"shortname"];
			self.street1 = [Soap getNodeValue: node withName: @"street1"];
			self.street2 = [Soap getNodeValue: node withName: @"street2"];
			self.city = [Soap getNodeValue: node withName: @"city"];
			self.county = [Soap getNodeValue: node withName: @"county"];
			self.state = [Soap getNodeValue: node withName: @"state"];
			self.country = [Soap getNodeValue: node withName: @"country"];
			self.zip = [Soap getNodeValue: node withName: @"zip"];
			self.phone = [Soap getNodeValue: node withName: @"phone"];
			self.fax = [Soap getNodeValue: node withName: @"fax"];
			self.email = [Soap getNodeValue: node withName: @"email"];
			self.www = [Soap getNodeValue: node withName: @"www"];
			self.npi = [Soap getNodeValue: node withName: @"npi"];
			self.latitude = [Soap getNodeValue: node withName: @"latitude"];
			self.longitude = [Soap getNodeValue: node withName: @"longitude"];
			self.errorCode = [[Soap getNodeValue: node withName: @"errorCode"] intValue];
			self.errorMessage = [Soap getNodeValue: node withName: @"errorMessage"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"getHospitalDataResponseType"];
	}
  
	- (NSMutableString*) serialize: (NSString*) nodeName
	{
		NSMutableString* s = [NSMutableString string];
		[s appendFormat: @"<%@", nodeName];
		[s appendString: [self serializeAttributes]];
		[s appendString: @">"];
		[s appendString: [self serializeElements]];
		[s appendFormat: @"</%@>", nodeName];
		return s;
	}
	
	- (NSMutableString*) serializeElements
	{
		NSMutableString* s = [super serializeElements];
		if (self.name != nil) [s appendFormat: @"<name>%@</name>", [CommonFunctions escapeForXML:self.name]];
		if (self.shortname != nil) [s appendFormat: @"<shortname>%@</shortname>", [CommonFunctions escapeForXML:self.shortname]];
		if (self.street1 != nil) [s appendFormat: @"<street1>%@</street1>", [CommonFunctions escapeForXML:self.street1]];
		if (self.street2 != nil) [s appendFormat: @"<street2>%@</street2>", [CommonFunctions escapeForXML:self.street2]];
		if (self.city != nil) [s appendFormat: @"<city>%@</city>", [CommonFunctions escapeForXML:self.city]];
		if (self.county != nil) [s appendFormat: @"<county>%@</county>", [CommonFunctions escapeForXML:self.county]];
		if (self.state != nil) [s appendFormat: @"<state>%@</state>", [CommonFunctions escapeForXML:self.state]];
		if (self.country != nil) [s appendFormat: @"<country>%@</country>", [CommonFunctions escapeForXML:self.country]];
		if (self.zip != nil) [s appendFormat: @"<zip>%@</zip>", [CommonFunctions escapeForXML:self.zip]];
		if (self.phone != nil) [s appendFormat: @"<phone>%@</phone>", [CommonFunctions escapeForXML:self.phone]];
		if (self.fax != nil) [s appendFormat: @"<fax>%@</fax>", [CommonFunctions escapeForXML:self.fax]];
		if (self.email != nil) [s appendFormat: @"<email>%@</email>", [CommonFunctions escapeForXML:self.email]];
		if (self.www != nil) [s appendFormat: @"<www>%@</www>", [CommonFunctions escapeForXML:self.www]];
		if (self.npi != nil) [s appendFormat: @"<npi>%@</npi>", [CommonFunctions escapeForXML:self.npi]];
		if (self.latitude != nil) [s appendFormat: @"<latitude>%@</latitude>", [CommonFunctions escapeForXML:self.latitude]];
		if (self.longitude != nil) [s appendFormat: @"<longitude>%@</longitude>", [CommonFunctions escapeForXML:self.longitude]];
		[s appendFormat: @"<errorCode>%@</errorCode>", [NSString stringWithFormat: @"%i", self.errorCode]];
		if (self.errorMessage != nil) [s appendFormat: @"<errorMessage>%@</errorMessage>", [CommonFunctions escapeForXML:self.errorMessage]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	- (BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[PLgetHospitalDataResponseType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
