/*
	PLgetEventListResponseType.h
	The implementation of properties and methods for the PLgetEventListResponseType object.
	Generated by SudzC.com
*/
#import "PLgetEventListResponseType.h"

@implementation PLgetEventListResponseType
	@synthesize eventList = _eventList;
	@synthesize errorCode = _errorCode;
	@synthesize errorMessage = _errorMessage;

	- (id) init
	{
		if(self = [super init])
		{
			self.eventList = nil;
			self.errorMessage = nil;

		}
		return self;
	}

	+ (PLgetEventListResponseType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.eventList = [Soap getNodeValue: node withName: @"eventList"];
			self.errorCode = [[Soap getNodeValue: node withName: @"errorCode"] intValue];
			self.errorMessage = [Soap getNodeValue: node withName: @"errorMessage"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"getEventListResponseType"];
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
		if (self.eventList != nil) [s appendFormat: @"<eventList>%@</eventList>", [CommonFunctions escapeForXML:self.eventList]];
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
		if(object != nil && [object isKindOfClass:[PLgetEventListResponseType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end