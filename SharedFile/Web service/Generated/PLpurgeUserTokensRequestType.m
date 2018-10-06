/*
	PLpurgeUserTokensRequestType.h
	The implementation of properties and methods for the PLpurgeUserTokensRequestType object.
	Generated by SudzC.com
*/
#import "PLpurgeUserTokensRequestType.h"

@implementation PLpurgeUserTokensRequestType
	@synthesize token = _token;
	@synthesize username = _username;
	@synthesize password = _password;

	- (id) init
	{
		if(self = [super init])
		{
			self.token = nil;
			self.username = nil;
			self.password = nil;

		}
		return self;
	}

	+ (PLpurgeUserTokensRequestType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.token = [Soap getNodeValue: node withName: @"token"];
			self.username = [Soap getNodeValue: node withName: @"username"];
			self.password = [Soap getNodeValue: node withName: @"password"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"purgeUserTokensRequestType"];
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
		if (self.username != nil) [s appendFormat: @"<username>%@</username>", [CommonFunctions escapeForXML:self.username]];
		if (self.password != nil) [s appendFormat: @"<password>%@</password>", [CommonFunctions escapeForXML:self.password]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	- (BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[PLpurgeUserTokensRequestType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end