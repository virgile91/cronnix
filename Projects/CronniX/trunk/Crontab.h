//
//  Crontab.h
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Jan 16 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskObject.h"

// __attribute__ ((unused)) suppresses compiler warnings
static NSString *NewCrontabParsedNotification __attribute__ ((unused)) = @"NewCrontabParsed";
static NSString *disableComment __attribute__ ((unused)) = @"#CronniX";
static NSString *cronnixComment __attribute__ ((unused)) = @"#CrInfo ";
static NSString *systemCrontabUser __attribute__ ((unused)) = @"system";

static NSString *EnvVariableAddedNotification __attribute__ ((unused)) = @"EnvVariableAdded";
static NSString *EnvVariableEditedNotification __attribute__ ((unused)) = @"EnvVariableEdited";
static NSString *EnvVariableDeletedNotification __attribute__ ((unused)) = @"EnvVariableDeleted";


/*!
	@class Crontab
	@abstract 
	@discussion 
*/
@interface Crontab : NSObject {
	NSMutableArray *lines;
	NSMutableArray *objects;
	NSMutableArray *tasks;
	NSMutableDictionary *envVariables;
	NSString *user;
}

- (id)initWithData: (NSData *)data forUser: (NSString *)aUser;

- (id)initWithContentsOfFile: (NSString *)path forUser: (NSString *)aUser;

// workers

- (void)clear;

- (NSMutableArray *)linesFromData: (NSData *)data;
/*!
	@method parseData
	@abstract 
	@discussion 
	@result 
*/
- (void)parseData;
/*!
	@method removeShortLines
	@abstract 
	@discussion 
	@result 
*/
- (void)removeShortLines;
/*!
	@method removeCommentLines
	@abstract 
	@discussion 
	@result 
*/
- (void)removeCommentLines;
/*!
	@method replaceWhitespaceWithSingleTabs
	@abstract 
	@discussion 
	@result 
*/
- (void)replaceWhitespaceWithSingleTabs;
/*!
	@method findEnvironmentVariables
	@abstract 
	@discussion 
	@result 
*/
- (void)findEnvironmentVariables;
/*!
	@method findTasks
	@abstract 
	@discussion 
	@result 
*/
- (void)findTasks;
/*!
	@method hasEnvType1InWords
	@abstract 
	@discussion 
	@result 
*/
- (BOOL)hasEnvType1InWords: (NSArray *)words;
/*!
	@method hasEnvType2InWords
	@abstract 
	@discussion 
	@result 
*/
- (BOOL)hasEnvType2InWords: (NSArray *)words;

- (BOOL)hasEnvType3InWords: (NSArray *)words;

- (BOOL)hasEnvType4InWords: (NSArray *)words;

- (BOOL)isSystemCrontab;

- (BOOL)writeAtPath: (NSString *)path;

// accessors

/*!
	@method lines
	@abstract 
	@discussion 
	@result 
*/
- (NSMutableArray *)lines;
/*!
	@method setLines
	@abstract 
	@discussion 
	@result 
*/
- (void)setLines: (NSArray *)aVal;
/*!
	@method tasks
	@abstract 
	@discussion 
	@result 
*/
- (NSMutableArray *)tasks;
/*!
	@method setTasks
	@abstract 
	@discussion 
	@result 
*/
- (void)setTasks: (NSMutableArray *)aVal;
/*!
	@method user
	@abstract 
	@discussion 
	@result 
*/
- (NSString *)user;
/*!
	@method setUser
	@abstract 
	@discussion 
	@result 
*/
- (void)setUser: (NSString *)aVal;
/*!
	@method envVariables
	@abstract 
	@discussion 
	@result 
*/
- (NSMutableDictionary *)envVariables;
/*!
	@method setEnvVariables
	@abstract 
	@discussion 
	@result 
*/
- (void)setEnvVariables: (NSMutableDictionary *)aVal;

- (void)addEnv: (NSDictionary *)env;
- (void)addEnv: (NSString *)env withValue: (NSString *)value;
- (void)replaceEnv: (NSDictionary *)oldEnv with: (NSDictionary *)newEnv;

- (void)removeEnv: (NSDictionary *)env;
- (void)removeEnvForKey: (NSString *)key;

- (void)addTask: (TaskObject *)task;

- (void)addTaskWithString: (NSString *)string;

- (NSArray *)envVariablesArray;

- (NSMutableData *)envVariablesData;

- (NSMutableData *)data;

- (TaskObject *)taskAtIndex: (int)index;

// notification handlers

- (void)envVariableAdded: (NSNotification *)notification;
- (void)envVariableEdited: (NSNotification *)notification;

@end
