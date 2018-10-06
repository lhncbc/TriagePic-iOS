/*
	PLgetImageCountsAndTokensResponseType.h
	The implementation of properties and methods for the PLgetImageCountsAndTokensResponseType object.
	Generated by SudzC.com
*/
#import "PLgetImageCountsAndTokensResponseType.h"

@implementation PLgetImageCountsAndTokensResponseType
	@synthesize imageCount = _imageCount;
	@synthesize firstToken = _firstToken;
	@synthesize lastToken = _lastToken;
	@synthesize nullTokenCount = _nullTokenCount;
	@synthesize errorCode = _errorCode;
	@synthesize errorMessage = _errorMessage;

	- (id) init
	{
		if(self = [super init])
		{
			self.errorMessage = nil;

		}
		return self;
	}

	+ (PLgetImageCountsAndTokensResponseType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.imageCount = [[Soap getNodeValue: node withName: @"imageCount"] intValue];
			self.firstToken = [[Soap getNodeValue: node withName: @"firstToken"] intValue];
			self.lastToken = [[Soap getNodeValue: node withName: @"lastToken"] intValue];
			self.nullTokenCount = [[Soap getNodeValue: node withName: @"nullTokenCount"] intValue];
			self.errorCode = [[Soap getNodeValue: node withName: @"errorCode"] intValue];
			self.errorMessage = [Soap getNodeValue: node withName: @"errorMessage"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"getImageCountsAndTokensResponseType"];
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
		[s appendFormat: @"<imageCount>%@</imageCount>", [NSString stringWithFormat: @"%i", self.imageCount]];
		[s appendFormat: @"<firstToken>%@</firstToken>", [NSString stringWithFormat: @"%i", self.firstToken]];
		[s appendFormat: @"<lastToken>%@</lastToken>", [NSString stringWithFormat: @"%i", self.lastToken]];
		[s appendFormat: @"<nullTokenCount>%@</nullTokenCount>", [NSString stringWithFormat: @"%i", self.nullTokenCount]];
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
		if(object != nil && [object isKindOfClass:[PLgetImageCountsAndTokensResponseType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
