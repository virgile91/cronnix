//
//  EnvVariableTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Thu Mar 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "EnvVariableTest.h"

NSString *envType1 = @"ENV1= value\n";
NSString *envType2 = @"ENV2= value +more\n";
NSString *envType3 = @"ENV3=value\n";
NSString *envType4 = @"ENV4=value +more\n";
NSString *envType5 = @"ENV5 = value";
NSString *envType6 = @"ENV6 = value +more";
NSString *envType7 = @"ENV7 =value";
NSString *envType8 = @"ENV8 =value +more";


@implementation EnvVariableTest

- (void)testType1 {
	id env = [ EnvVariable envVariableWithString: envType1 ];
	[ self assert: [ env key ] equals: @"ENV1" ];
	[ self assert: [ env value ] equals: @"value" ];
}

@end
