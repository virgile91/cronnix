//
//  Crontab.m
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Jan 16 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Crontab.h"
#import "CommentLine.h"


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
    while ( line = [ en nextObject ] ) {
		id obj = nil;

		if ( [ EnvVariable isContainedInString: line ] ) {
			obj = [[ EnvVariable alloc ] initWithString: line ];
		} else if( [ CommentLine isContainedInString: line ] ) {
			obj = [[ CommentLine alloc ] initWithString: line ];
		} else if ( [ TaskObject isContainedInString: line ] ) {
			obj = [[ TaskObject alloc ] initWithString: line ];
		}
		[ obj autorelease ];
		
		if ( obj ) [ objects addObject: obj ];
    }
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



- (NSMutableData *)envVariablesData {
    NSMutableData *envData = [ NSMutableData data ];
    NSEnumerator *envVars = [ self envVariables ];
    id env;
    
    while ( env = [ envVars nextObject ] ) {
		NSString *item = [ NSString stringWithFormat: @"%@ = %@\n", [ env key ], [ env value ]];
		[ envData appendData: [ item dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
    }
    
    return envData;
}

- (NSMutableData *)data {
    NSMutableData *data = [ self envVariablesData ];
    
    // we need to build a different crontab in the "system" case, because of the additional "User" field
    NSEnumerator *enumerator = [ self tasks ];
    TaskObject *task;
    
    while ( task = [ enumerator nextObject ] ) {
	NSString *line;
	
	// add info line
	if ( [ task info ] ) {
	    line = [ NSString stringWithFormat: @"%@%@\n", cronnixComment, [ task info ]];
	    //NSLog( @"info: %@", line );
	    [ data appendData: [ line dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
	}
	
	// prepare the task line
	{
	    // prepare the active/inactive string
	    NSString *activeString = [ task isActive ] ?  (NSString*)@"" : disableComment;
	    NSString *asterisk = @"*";
	    if ( [ self isSystemCrontab ] ) {
		line = [ NSString stringWithFormat: @"%@ %@\t%@\t%@\t%@\t%@\t%@\t%@\n",
			activeString,
[[ task objectForKey: @"Min" ] length ] != 0 ? [ task objectForKey: @"Min" ] : asterisk,
[[ task objectForKey: @"Hour" ] length ] != 0 ? [ task objectForKey: @"Hour" ] : asterisk,
[[ task objectForKey: @"Mday" ] length ] != 0 ? [ task objectForKey: @"Mday" ] : asterisk,
[[ task objectForKey: @"Month" ] length ] != 0 ? [ task objectForKey: @"Month" ] : asterisk,
[[ task objectForKey: @"Wday" ] length ] != 0 ? [ task objectForKey: @"Wday" ] : asterisk,
[[ task objectForKey: @"User" ] length ] != 0 ? [ task objectForKey: @"User" ] : @"root",
[[ task objectForKey: @"Command" ] length ] != 0 ? [ task objectForKey: @"Command" ] : asterisk ];
	    } else {
		line = [ NSString stringWithFormat: @"%@ %@\t%@\t%@\t%@\t%@\t%@\n",
		    activeString,
[[ task objectForKey: @"Min" ] length ] != 0 ? [ task objectForKey: @"Min" ] : asterisk,
[[ task objectForKey: @"Hour" ] length ] != 0 ? [ task objectForKey: @"Hour" ] : asterisk,
[[ task objectForKey: @"Mday" ] length ] != 0 ? [ task objectForKey: @"Mday" ] : asterisk,
[[ task objectForKey: @"Month" ] length ] != 0 ? [ task objectForKey: @"Month" ] : asterisk,
[[ task objectForKey: @"Wday" ] length ] != 0 ? [ task objectForKey: @"Wday" ] : asterisk,
[[ task objectForKey: @"Command" ] length ] != 0 ? [ task objectForKey: @"Command" ] : asterisk ];
	    }
	}
	//NSLog( @"task: %@", line );
	[ data appendData: [ line dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
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
