/*
	PLgetHospitalDataRequestType.h
	The implementation of properties and methods for the PLgetHospitalDataRequestType object.
	Generated by SudzC.com
*/
#import "PLgetHospitalDataRequestType.h"

@implementation PLgetHospitalDataRequestType
	@synthesize token = _token;
	@synthesize hospital_uuid = _hospital_uuid;

	- (id) init
	{
		if(self = [super init])
		{
			self.token = nil;

		}
		return self;
	}

	+ (PLgetHospitalDataRequestType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.token = [Soap getNodeValue: node withName: @"token"];
			self.hospital_uuid = [[Soap getNodeValue: node withName: @"hospital_uuid"] intValue];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"getHospitalDataRequestType"];
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
		if (self.token != nil) [s appendFormat: @"<token>%@</token>", [CommonFunctions escapeForXML:self.token]];
		[s appendFormat: @"<hospital_uuid>%@</hospital_uuid>", [NSString stringWithFormat: @"%i", self.hospital_uuid]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	- (BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[PLgetHospitalDataRequestType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
