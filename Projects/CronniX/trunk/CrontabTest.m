//
//  CrontabTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sat Mar 23 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "CrontabTest.h"

NSString *testString =
@"ENV1= value\n"
@"ENV2= value +more\n"
@"ENV3=value\n"
@"ENV4=value +more\n"
@"ENV5 = value\n"
@"ENV6 = value +more\n"
@"ENV7 =value\n"
@"ENV8 =value +more\n"
@"#CrInfo another test...\n"
@" 1      2       3       4       *       echo \"Happy New Year!\"\n"
@"# plain comment line\n"
@" 1      2       3       4       *       second Task\n"
@"#CrInfo third Task\n"
@" 30\t5\t \t6       4       *       third Task\n";


@implementation CrontabTest

- (void)setUp {
	crontab = [[ Crontab alloc ] initWithData: [ testString dataUsingEncoding: [ NSString defaultCStringEncoding ]]
								forUser: nil ];
}

- (void)tearDown {
	[ crontab release ];
}


- (void)testWhiteSpaceTask {
	id task = [[ crontab tasks ] objectAtIndex: 2 ];
	[ self assert: [ task minute ] equals: @"30" ];
	[ self assert: [ task hour ] equals: @"5" ];
	[ self assert: [ task mday ] equals: @"6" ];
	[ self assert: [ task command ] equals: @"third Task" ];
}


- (void)off_testLineCount {
	[ self assertInt: [[ crontab lines ] count ] equals: 2 ];
}


- (void)testSetLines {
	NSArray *a1 = [ NSArray arrayWithObjects: @"A", @"B", nil ];
	[ crontab setLines: a1 ];
	[ self assert: [[ crontab lines ] objectAtIndex: 0] equals: @"A" message: @"content" ];
	[ self assertInt: [[ crontab lines ] count ] equals: 2 message: @"length" ];
}

- (void)testTaskCount {
	[ self assertInt: [[ crontab tasks ] count ] equals: 3 ];
}

- (void)testTask {
	[ self assertNotNil: [[ crontab tasks ] objectAtIndex: 0 ] ];
}

- (void)testTaskMinute {
	id task = [[ crontab tasks ] objectAtIndex: 0 ];
	[ self assert: [ task minute ] equals: @"1" ];
}

- (void)testTaskHour {
	id task = [[ crontab tasks ] objectAtIndex: 0 ];
	[ self assert: [ task hour ] equals: @"2" ];
}

- (void)testTaskMonth {
	id task = [[ crontab tasks ] objectAtIndex: 0 ];
	[ self assert: [ task month ] equals: @"4" ];
}

- (void)testTaskMday {
	id task = [[ crontab tasks ] objectAtIndex: 0 ];
	[ self assert: [ task mday ] equals: @"3" ];
}

- (void)testTaskWday {
	id task = [[ crontab tasks ] objectAtIndex: 0 ];
	[ self assert: [ task wday ] equals: @"*" ];
}

- (void)testTaskCommand {
	id task = [[ crontab tasks ] objectAtIndex: 0 ];
	[ self assert: [ task command ] equals: @"echo \"Happy New Year!\"" ];
}

- (void)testHasEnvType1InWords {
	NSArray *w1 = [ NSArray arrayWithObjects: @"ENV=", @"value", nil ];
	NSArray *w2 = [ NSArray arrayWithObjects: @"ENV=", @"value", @"+more", nil ];
	NSArray *w3 = [ NSArray arrayWithObjects: @"ENV", @"value", @"+more", nil ];
	[ self assertTrue: [ crontab hasEnvType1InWords: w1 ] message: @"w1" ];
	[ self assertTrue: [ crontab hasEnvType1InWords: w2 ] message: @"w2" ];
	[ self assertFalse: [ crontab hasEnvType1InWords: w3 ] message: @"w3" ];
}


- (void)testFindEnvironmentVariables {
	[ crontab findEnvironmentVariables ];
	[ self assertInt: [[ crontab envVariablesArray ] count ] equals: 8 message: @"Env count:" ];
}


- (void)testTaskAtIndex {
	[ self assertNotNil: [ crontab taskAtIndex: 0 ]];
	[ self assert: [ crontab taskAtIndex: 0 ] equals: [[ crontab tasks ] objectAtIndex: 0 ]];
}

@end
