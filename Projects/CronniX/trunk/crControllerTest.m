//
//  crControllerTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sun Mar 24 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "crControllerTest.h"

NSString *crontabString =
@"ENV1= value\n"
@"ENV2= value +more\n"
@"ENV3=value\n"
@"ENV4=value +more\n"
@"ENV5 = value\n"
@"ENV6 = value +more\n"
@"ENV7 =value\n"
@"ENV8 =value +more\n"
@"#CrInfo another test...\n"
@" 1      2       3       4       *       echo \"Happy New Year!\"\n";


@implementation crControllerTest


- (void)setUp {
	controller = [[ crController alloc ] init ];
	cronData = [[ crontabString dataUsingEncoding: [ NSString defaultCStringEncoding ]] retain ];
}

- (void)tearDown {
	[ controller release ];
	[ cronData release ];
}


- (void)testInitCurrentCrontab {
	Crontab *ct = [[ Crontab alloc ] initWithData: cronData forUser: nil ];
	[ self assertNotNil: ct ];
	[ ct release ];
}

- (void)testParseCrontab {
	[ self assertNotNil: cronData message: @"cronData" ];
	[ controller parseCrontab: cronData ];
	[ self assertNotNil: [ controller currentCrontab ]];
}


- (void)testOpenSystemCrontab {
	[ controller openSystemCrontab ];
	[ self assertNotNil: [ controller currentCrontab ]];	
}

@end
