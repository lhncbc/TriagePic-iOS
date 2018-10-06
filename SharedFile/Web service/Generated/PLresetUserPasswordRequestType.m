/*
	PLresetUserPasswordRequestType.h
	The implementation of properties and methods for the PLresetUserPasswordRequestType object.
	Generated by SudzC.com
*/
#import "PLresetUserPasswordRequestType.h"

@implementation PLresetUserPasswordRequestType
	@synthesize token = _token;
	@synthesize email = _email;

	- (id) init
	{
		if(self = [super init])
		{
			self.token = nil;
			self.email = nil;

		}
		return self;
	}

	+ (PLresetUserPasswordRequestType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.token = [Soap getNodeValue: node withName: @"token"];
			self.email = [Soap getNodeValue: node withName: @"email"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"resetUserPasswordRequestType"];
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
		if (self.email != nil) [s appendFormat: @"<email>%@</email>", [CommonFunctions escapeForXML:self.email]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	- (BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[PLresetUserPasswordRequestType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end