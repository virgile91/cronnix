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

- (void)parseData;

- (void)removeShortLines;

- (void)removeCommentLines;

- (void)replaceWhitespaceWithSingleTabs;

- (void)findEnvironmentVariables;

- (void)findTasks;

- (BOOL)hasEnvType1InWords: (NSArray *)words;

- (BOOL)hasEnvType2InWords: (NSArray *)words;

- (BOOL)hasEnvType3InWords: (NSArray *)words;

- (BOOL)hasEnvType4InWords: (NSArray *)words;

- (BOOL)isSystemCrontab;

- (BOOL)isShortLine: (NSString *)line;

- (BOOL)writeAtPath: (NSString *)path;

// accessors

- (NSMutableArray *)lines;

- (void)setLines: (NSArray *)aVal;

- (NSMutableArray *)tasks;

- (void)setTasks: (NSMutableArray *)aVal;

- (NSString *)user;

- (void)setUser: (NSString *)aVal;

- (NSMutableDictionary *)envVariables;

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
