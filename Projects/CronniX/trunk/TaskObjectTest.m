//
//  TaskObjectTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Sat Mar 23 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "TaskObjectTest.h"


NSString *taskString = @"Min Hour Mday Month Wday My \"Command\"";
NSString *systemTaskString = @"Min Hour Mday Month Wday User My \"Command\"";
NSString *infoString = @"Task info";

@implementation TaskObjectTest

- (void)setUp {
	task = [[ TaskObject alloc ] initWithString: taskString ];
	systemTask = [[ TaskObject alloc ] initWithString: systemTaskString forSystem: YES ];
}

- (void)tearDown {
	[ task release ];
	[ systemTask release ];
}

- (void)testIsContainedInStringPositives {
	[ self assertTrue: [ TaskObject isContainedInString: taskString ]];
	[ self assertTrue: [ TaskObject isContainedInString: systemTaskString ]];
}

- (void)testIsContainedInStringNegatives {
	[ self assertFalse: [ TaskObject isContainedInString: @"test test" ]];
	[ self assertFalse: [ TaskObject isContainedInString: @"# test" ]];
	[ self assertFalse: [ TaskObject isContainedInString: @"1 2 3 4 5" ]];
}

- (void)testMinute {
	[ self assert: [ task minute ] equals: @"Min" ];
}

- (void)testHour {
	[ self assert: [ task hour ] equals: @"Hour" ];
}

- (void)testMonth {
	[ self assert: [ task month ] equals: @"Month" ];
}

- (void)testMday {
	[ self assert: [ task mday ] equals: @"Mday" ];
}

- (void)testWday {
	[ self assert: [ task wday ] equals: @"Wday" ];
}

- (void)testCommand {
	[ self assert: [ task command ] equals: @"My \"Command\"" ];
}

- (void)testInfo {
	NSString *s = [ infoString copy ];
	[ task setInfo: s ];
	[ self assert: [ task info ] equals: infoString ];
	[ s release ];
	[ self assert: [ task info ] equals: infoString ];
	[ task setInfo: [ task info ] ];
	[ self assert: [ task info ] equals: infoString ];
}

- (void)testSystemTask {
	[ self assert: [ systemTask minute ] equals: @"Min" ];
	[ self assert: [ systemTask hour ] equals: @"Hour" ];
	[ self assert: [ systemTask month ] equals: @"Month" ];
	[ self assert: [ systemTask mday ] equals: @"Mday" ];
	[ self assert: [ systemTask wday ] equals: @"Wday" ];
	[ self assert: [ systemTask user ] equals: @"User" ];
	[ self assert: [ systemTask command ] equals: @"My \"Command\"" ];
}

- (void)testTaskWithTask {
	TaskObject *newtask = [ TaskObject taskWithTask: task ];
	[ task setMinute:  @"1" ];
	[ task setHour:    @"1" ];
	[ task setMonth:   @"1" ];
	[ task setMday:    @"1" ];
	[ task setWday:    @"1" ];
	[ task setUser:    @"testUser" ];
	[ task setCommand: @"testCommand" ];
	[ self assert: [ newtask minute ] equals: @"Min" ];
	[ self assert: [ newtask month ] equals: @"Month" ];
	[ self assert: [ newtask command ] equals: @"My \"Command\"" ];
}

- (void)testDictionary {
	NSMutableDictionary *copy;
	NSMutableDictionary *orig = [ NSMutableDictionary dictionary ];
	[ orig setObject: @"Hans Dampf" forKey: @"Name" ];
	copy = [ NSMutableDictionary dictionaryWithDictionary: orig ];
	[ orig setObject: @"Donni Lotti" forKey: @"Name" ];
	[ self assertFalse: [[ orig objectForKey: @"Name" ] isEqual: [ copy objectForKey: @"Name" ]]];
}

- (void)testDictionary2 {
	NSMutableDictionary *copy;
	NSMutableDictionary *orig = [ NSMutableDictionary dictionary ];
	[ orig setObject: @"Hans Dampf" forKey: @"Name" ];
	copy = [[ NSMutableDictionary alloc ] initWithDictionary: orig ];
	[ orig setObject: @"Donni Lotti" forKey: @"Name" ];
	[ self assertFalse: [[ orig objectForKey: @"Name" ] isEqual: [ copy objectForKey: @"Name" ]]];
}


@end
