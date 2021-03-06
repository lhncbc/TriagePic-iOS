/*
	PLgetHospitalLegaleseRequestType.h
	The implementation of properties and methods for the PLgetHospitalLegaleseRequestType object.
	Generated by SudzC.com
*/
#import "PLgetHospitalLegaleseRequestType.h"

@implementation PLgetHospitalLegaleseRequestType
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

	+ (PLgetHospitalLegaleseRequestType*) createWithNode: (CXMLNode*) node
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
		return [self serialize: @"getHospitalLegaleseRequestType"];
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
		if(object != nil && [object isKindOfClass:[PLgetHospitalLegaleseRequestType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
