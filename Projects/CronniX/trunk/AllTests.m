//
//  AllTests.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sat Mar 23 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "AllTests.h"
#import "CrontabTest.h"
#import "TaskObjectTest.h"
#import "crControllerTest.h"


@implementation AllTests

+ (TestSuite *)suite {
	TestSuite *suite = [ TestSuite suiteWithName: @"CronniX Tests" ];

	[ suite addTest: [ TestSuite suiteWithClass: [ CrontabTest class ]]];
	[ suite addTest: [ TestSuite suiteWithClass: [ TaskObjectTest class ]]];
	[ suite addTest: [ TestSuite suiteWithClass: [ crControllerTest class ]]];
	
	return suite;
}


@end
