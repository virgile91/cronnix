//
//  Crontab.m
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Jan 16 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Crontab.h"
#import "CommentLine.h"
#import "CrInfoCommentLine.h"
#import "UnparsedLine.h"

@implementation Crontab

- (id)initWithContentsOfFile: (NSString *)path forUser: (NSString *)aUser {
    NSData *data = [ NSData dataWithContentsOfFile: path ];
    return [ self initWithData: data forUser: aUser ];
}

- (id)initWithData: (NSData *)data forUser: (NSString *)aUser {
    [super init];
    
    objects = [[ NSMutableArray alloc ] init ];
    
    [ self setUser: aUser ];
    
    if ( data ) {
		[ self setLines: [ self linesFromData: data ]];
		
		[ self parseData ];
		
		// tell the world that there's a new crontab
		[[ NSNotificationCenter defaultCenter ] postNotificationName: NewCrontabParsedNotification
															  object: [ self tasks ]];
    }
    
    return self;
}

- (void)dealloc {
    [ lines release ];
    [ objects release ];
    [ user release ];
    [ super dealloc ];
}


// workers

- (void)clear {
    [ lines removeAllObjects ];
    [ objects removeAllObjects ];
    [ self setUser: nil ];
}

- (NSMutableArray *)linesFromData: (NSData *)data {
    NSString *string = [ [ NSString alloc ] initWithData: data 
												encoding: [ NSString defaultCStringEncoding ] ];
    NSMutableArray *array = [ NSMutableArray arrayWithArray: [ string componentsSeparatedByString: @"\n" ] ];
    [ string release ];
    return array;
}


- (void)parseData {
    NSEnumerator *en = [[ self lines ] objectEnumerator ];
    id line;
    id previousLine = nil;
    while ( line = [ en nextObject ] ) {
		id obj = nil;
		
		if ( [ line length ] == 0 ) {
			
			continue;
		
		} else if ( [ EnvVariable isContainedInString: line ] ) {
			
			obj = [[ EnvVariable alloc ] initWithString: line ];
			
		} else if ( [ CommentLine isContainedInString: line ] &&
					! [ CrInfoCommentLine isContainedInString: line ] ) {
			
			obj = [[ CommentLine alloc ] initWithString: line ];
			
		} else if ( [ TaskObject isContainedInString: line ] ) {
			
			obj = [[ TaskObject alloc ] initWithString: line ];
			if ( [ CrInfoCommentLine isContainedInString: previousLine ] ) {
				[ obj setInfo: previousLine ];
			}
			
		} else {
			
			// info lines are parsed into the TaskObject above (setInfo), therefore skip them here
			if ( ! [ CrInfoCommentLine isContainedInString: line ] )
				obj = [[ UnparsedLine alloc ] initWithString: line ];
		}
		[ obj autorelease ];
		[ previousLine release ];
		previousLine = [ line retain ];
		
		if ( obj ) [ objects addObject: obj ];
    }
    [ previousLine release ];
}



- (BOOL) isSystemCrontab {
    return [[ self user ] isEqualToString: systemCrontabUser ];
}


// accessors

- (NSMutableArray *)lines {
    return lines;
}

- (void)setLines: (NSArray *)aValue {
    if ( (NSArray *)lines != aValue ) {
        [ lines release ];
        lines = [ aValue retain ];
    }
}


- (NSEnumerator *)objectEnumeratorForClass: (Class)aClass {
    NSMutableArray *filteredObjects = [ NSMutableArray array ];
    NSEnumerator *iter = [ objects objectEnumerator ];
    id obj;
    while ( obj = [ iter nextObject ] ) {
		if ( [ obj isKindOfClass: aClass ] ) [ filteredObjects addObject: obj ];
    }
    return [ filteredObjects objectEnumerator ];
}

- (int)objectCountForClass: (Class)aClass {
    id iter = [ self objectEnumeratorForClass: aClass ];
    return [[ iter allObjects ] count ];
}


- (NSEnumerator *)tasks {
    return [ self objectEnumeratorForClass: [ TaskObject class ]];
}

- (int)taskCount {
    return [[[ self tasks ] allObjects ] count ];
}


- (NSString *)user {
    return user;
}

- (void)setUser: (NSString *)aValue {
    if ( user != aValue ) {
        [ user release ];
        user = ( aValue ) ? [ aValue retain ] : nil;
    }
}


- (void)addEnvVariable: (EnvVariable *)env {
    [ objects addObject: env ];
}

- (void)addEnvVariableWithValue: (NSString *)aValue forKey: (NSString *)aKey {
    [ objects addObject: [ EnvVariable envVariableWithValue: aValue forKey: aKey ]];
}


- (void)removeAllEnvVariables {
    id allEnvs = [[ self envVariables ] allObjects ];
    id iter = [ allEnvs objectEnumerator ];
    id env;
    while ( env = [ iter nextObject ] ) {
		[ self removeEnvVariable: env ];
    }
}

- (void)removeEnvVariable: (EnvVariable *)env {
    [ objects removeObject: env ];
}

- (void)removeEnvVariableWithKey: (NSString *)key {
    NSEnumerator *envs = [ self envVariables ];
    id env;
    while ( env = [ envs nextObject ] ) {
		if ( [[ env key ] isEqualToString: key ] ) {
			[ objects removeObject: env ];
			break;
		}
    }
}

- (void)removeEnvVariableAtIndex: (int)index {
    id env = [ self envVariableAtIndex: index ];
    [ objects removeObject: env ];
}


- (void)insertEnvVariable: (id)env atIndex: (int)index {
    int objIndex = [ self objectIndexOfEnvVariableAtIndex: index ];
    [ objects insertObject: env atIndex: objIndex ];
}

- (void)addTask: (TaskObject *)task {
    [ objects addObject: task ];
}


- (void)removeTaskAtIndex: (int)index {
    id task = [ self taskAtIndex: index ];
    [ objects removeObject: task ];
}


- (int)objectIndexOfTaskAtIndex: (int)index {
    id task = [ self taskAtIndex: index ];
    return [ objects indexOfObject: task ];
}

- (int)objectIndexOfEnvVariableAtIndex: (int)index {
    id env = [ self envVariableAtIndex: index ];
    return [ objects indexOfObject: env ];
}


- (void)insertTask: (TaskObject *)aTask atIndex: (int)index {
    int objIndex = [ self objectIndexOfTaskAtIndex: index ];
    [ objects insertObject: aTask atIndex: objIndex ];
}

- (void)replaceTaskAtIndex: (int)index withTask: (TaskObject *)aTask {
    int objIndex = [ self objectIndexOfTaskAtIndex: index ];
    [ objects removeObjectAtIndex: objIndex ];
    [ objects insertObject: aTask atIndex: objIndex ];
}


- (void)addTaskWithString: (NSString *)string {
    [ objects addObject: [ TaskObject taskWithString: string ] ];
}

- (NSEnumerator *)envVariables {
    return [ self objectEnumeratorForClass: [ EnvVariable class ]];
}

- (int)envVariableCount {
    return [[[ self envVariables ] allObjects ] count ];
}

- (EnvVariable *)envVariableAtIndex: (int)index {
    return [[[ self envVariables ] allObjects ] objectAtIndex: index ];
}


- (NSData *)data {
	id data = [ NSMutableData data ];
	id iter = [ objects objectEnumerator ];
	id obj;
	
	while ( obj = [ iter nextObject ] ) {
		[ data appendData: [ obj data ]];
		[ data appendData: [ @"\n" dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
	}
	
	return data;
}


- (TaskObject *)taskAtIndex: (int)index {
    return [[[ self tasks ] allObjects ] objectAtIndex: index ];
}


- (int)indexOfTask: (id)aTask {
    return [[[ self tasks ] allObjects ] indexOfObject: aTask ];
}


- (BOOL)writeAtPath: (NSString *)path {
    BOOL success = [[ self data ] writeToFile: path atomically: NO ];
    return success;
}

- (void)writeAtPath2: (NSString *)path {
    NSFileHandle *fh = [ NSFileHandle fileHandleForWritingAtPath: path ];
    NS_DURING
		[ fh writeData: [ self data ]];
		[ fh closeFile ];
    NS_HANDLER
		NSLog( @"failure writing file %@", path );
    NS_ENDHANDLER
}



@end
