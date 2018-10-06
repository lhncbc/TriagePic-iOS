/*
	PLsearchRequestType.h
	The interface definition of properties and methods for the PLsearchRequestType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLsearchRequestType : SoapObject
{
	NSString* _token;
	NSString* _eventShortname;
	NSString* _query;
	NSString* _photo;
	NSString* _filters;
	int _pageStart;
	int _perPage;
	NSString* _sortBy;
	BOOL _countOnly;
	
}
		
	@property (retain, nonatomic) NSString* token;
	@property (retain, nonatomic) NSString* eventShortname;
	@property (retain, nonatomic) NSString* query;
	@property (retain, nonatomic) NSString* photo;
	@property (retain, nonatomic) NSString* filters;
	@property int pageStart;
	@property int perPage;
	@property (retain, nonatomic) NSString* sortBy;
	@property BOOL countOnly;

	+ (PLsearchRequestType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

- (PLsearchRequestType *)copy;
@end
