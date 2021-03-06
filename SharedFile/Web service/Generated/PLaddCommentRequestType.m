/*
	PLaddCommentRequestType.h
	The implementation of properties and methods for the PLaddCommentRequestType object.
	Generated by SudzC.com
*/
#import "PLaddCommentRequestType.h"

@implementation PLaddCommentRequestType
	@synthesize token = _token;
	@synthesize uuid = _uuid;
	@synthesize comment = _comment;
	@synthesize suggested_status = _suggested_status;
	@synthesize suggested_location = _suggested_location;
	@synthesize suggested_image = _suggested_image;

	- (id) init
	{
		if(self = [super init])
		{
			self.token = nil;
			self.uuid = nil;
			self.comment = nil;
			self.suggested_status = nil;
			self.suggested_location = nil;
			self.suggested_image = nil;

		}
		return self;
	}

	+ (PLaddCommentRequestType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.token = [Soap getNodeValue: node withName: @"token"];
			self.uuid = [Soap getNodeValue: node withName: @"uuid"];
			self.comment = [Soap getNodeValue: node withName: @"comment"];
			self.suggested_status = [Soap getNodeValue: node withName: @"suggested_status"];
			self.suggested_location = [Soap getNodeValue: node withName: @"suggested_location"];
			self.suggested_image = [Soap getNodeValue: node withName: @"suggested_image"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"addCommentRequestType"];
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
		if (self.uuid != nil) [s appendFormat: @"<uuid>%@</uuid>", [CommonFunctions escapeForXML:self.uuid]];
		if (self.comment != nil) [s appendFormat: @"<comment>%@</comment>", [CommonFunctions escapeForXML:self.comment]];
		if (self.suggested_status != nil) [s appendFormat: @"<suggested_status>%@</suggested_status>", [CommonFunctions escapeForXML:self.suggested_status]];
		if (self.suggested_location != nil) [s appendFormat: @"<suggested_location>%@</suggested_location>", [CommonFunctions escapeForXML:self.suggested_location]];
		if (self.suggested_image != nil) [s appendFormat: @"<suggested_image>%@</suggested_image>", [CommonFunctions escapeForXML:self.suggested_image]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	- (BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[PLaddCommentRequestType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
