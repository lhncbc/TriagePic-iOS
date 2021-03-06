/*
	PLSudzc.m
	Creates a list of the services available with the PL prefix.
	Generated by SudzC.com
*/
#import "PLSudzc.h"

@implementation PLSudzC

@synthesize logging, server, defaultServer;

@synthesize plusWebServices;


#pragma mark Initialization

- (id)initWithServer:(NSString*)serverName{
	if(self = [self init]) {
		self.server = serverName;
	}
	return self;
}

+(PLSudzC*)sudzc{
	return (PLSudzC*)[[PLSudzC alloc] init];
}

+(PLSudzC*)sudzcWithServer:(NSString*)serverName{
	return (PLSudzC*)[[PLSudzC alloc] initWithServer:serverName];
}

#pragma mark Methods

- (void)setLogging:(BOOL)value{
	logging = value;
	[self updateServices];
}

- (void)setServer:(NSString*)value{
	server = value;
	[self updateServices];
}

- (void)updateServices{

	[self updateService: self.plusWebServices];
}

- (void)updateService:(SoapService*)service{
	service.logging = self.logging;
	if(self.server == nil || self.server.length < 1) { return; }
	service.serviceUrl = [service.serviceUrl stringByReplacingOccurrencesOfString:defaultServer withString:self.server];
}

#pragma mark Getter Overrides


- (PLplusWebServices*)plusWebServices{
	if(plusWebServices == nil) {
		plusWebServices = [[PLplusWebServices alloc] init];
	}
	return plusWebServices;
}


@end
			