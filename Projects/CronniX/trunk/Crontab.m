//
//  Crontab.m
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Jan 16 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Crontab.h"



@implementation Crontab

- (id)initWithContentsOfFile: (NSString *)path forUser: (NSString *)aUser {
    NSData *data = [ NSData dataWithContentsOfFile: path ];
    return [ self initWithData: data forUser: aUser ];
}

- (id)initWithData: (NSData *)data forUser: (NSString *)aUser {
    [super init];
    
    tasks = [[ NSMutableArray alloc ] init ];
    objects = [[ NSMutableArray alloc ] init ];
    envVariables = [[ NSMutableDictionary alloc ] init ];
    
    [ self setUser: aUser ];
    
    if ( data ) {
	[ self setLines: [ self linesFromData: data ]];
	
	[ self parseData ];
	
	// tell the world that there's a new crontab
	[[ NSNotificationCenter defaultCenter ] postNotificationName: NewCrontabParsedNotification
							      object: [ self tasks ]];
    }
    
    [[ NSNotificationCenter defaultCenter ] addObserver: self 
					       selector:@selector(envVariableAdded:)
						   name: EnvVariableAddedNotification 
						 object: nil ];
    [[ NSNotificationCenter defaultCenter ] addObserver: self 
					       selector:@selector(envVariableEdited:)
						   name: EnvVariableEditedNotification 
						 object: nil ];
    [[ NSNotificationCenter defaultCenter ] addObserver: self 
					       selector:@selector(envVariableDeleted:)
						   name: EnvVariableDeletedNotification 
						 object: nil ];
    return self;
}

- (void)dealloc {
    [ lines release ];
    [ objects release ];
    [ tasks release ];
    [ envVariables release ];
    [ user release ];
    [ super dealloc ];
}


// workers

- (void)clear {
    [ lines removeAllObjects ];
    [ objects removeAllObjects ];
    [ tasks removeAllObjects ];
    [ envVariables removeAllObjects ];
    [ self setUser: nil ];
}

- (NSMutableArray *)linesFromData: (NSData *)data {
    NSString *string = [ [ NSString alloc ] initWithData: data 
						encoding: [ NSString defaultCStringEncoding ] ];
    NSMutableArray *array = [ NSMutableArray arrayWithArray: [ string componentsSeparatedByString: @"\n" ] ];
    [ string release ];
    return array;
}


- (void)parseDataOld {
    //NSLog( @"removeShortLines" );
    [ self removeShortLines ];
    //NSLog( @"removeCommentLines" );
    [ self removeCommentLines ];
    //NSLog( @"replaceWhitespaceWithSingleTabs" );
    //[ self replaceWhitespaceWithSingleTabs ];
    //NSLog( @"findEnvironmentVariables" );
    [ self findEnvironmentVariables ];
    //NSLog( @"findTasks" );
    [ self findTasks ];
}


- (void)parseData {
	NSEnumerator *en = [[ self lines ] objectEnumerator ];
	id line;
	while ( line = [ en nextObject ] ) {
		if ( [ self isShortLine: line ] ) {
			[ objects addObject: line ];
			continue;
		}
		if ( [ self isEnvironmentVariable: line ] ) {
			env = [ EnvVariable envVariableFromString: line ];
			[ envVariables setObject: env forKey: someKey ];
			[ objects addObject: env ];
		}
	}
}

- (BOOL)isShortLine: (NSString *)line {
	if ( [ line length ] < 3 ) return YES;
	else return NO;
}

- (void)removeShortLines {
    NSEnumerator *en = [[ self lines ] objectEnumerator ];
    id item;
    while ( item = [ en nextObject ] ) {
	if ( [ item length ] < 3 ) [[ self lines ] removeObject: item ];
    }
}


- (void)removeCommentLines {
    NSEnumerator *en = [[ self lines ] objectEnumerator ];
    id item;
    while ( item = [ en nextObject ] ) {
	if (      [ item characterAtIndex: 0 ] == '#'
		  && ! [ item hasPrefix: disableComment ]
		  && ! [ item hasPrefix: cronnixComment ] ) {
	    [[ self lines ] removeObject: item ];
	}
    }
}


- (void)replaceWhitespaceWithSingleTabs {
    NSEnumerator *en = [[ self lines ] objectEnumerator ];
    id item;
    int iline = 0;
    int i;
    while ( item = [ en nextObject ] ) {
	NSMutableString *newline = [ NSMutableString stringWithCapacity: [ item length ] ];
	[ newline appendFormat: @"%c", [ item characterAtIndex: 0 ] ];
	for ( i = 1; i < [ item length ]; i++ ) {
	    unichar pre = [ item characterAtIndex: i-1 ];
	    unichar cur = [ item characterAtIndex: i ];
	    if ( cur == ' ' && pre == ' ' ) continue;
	    if ( cur == '\t' && pre == ' ' ) continue;
	    if ( cur == '\t' ) {
		[ newline appendString: @" " ];
	    } else {
		[ newline appendFormat: @"%c", cur ];
	    }
	}
	[[ self lines ] replaceObjectAtIndex: iline withObject: newline ];
	iline++;
    }
}


- (void)findEnvironmentVariables {
    NSArray *words;
    NSEnumerator *en = [[ self lines ] objectEnumerator ];
    id item;
    
    while ( item = [ en nextObject ] ) {
	words = [ item componentsSeparatedByString: @" " ];
	
	// ENV= value [+more]
	if ( [ self hasEnvType1InWords: words ] ) {
	    [[ self lines ] removeObject: item ];
	    continue;
	}
	
	// ENV=value [+more]
	if ( [ self hasEnvType2InWords: words ] ) {
	    [[ self lines ] removeObject: item ];
	    continue;
	}
	
	// ENV = value [+more]
	if ( [ self hasEnvType3InWords: words ] ) {
	    [[ self lines ] removeObject: item ];
	    continue;
	}
	
	// ENV =value [+more]
	if ( [ self hasEnvType4InWords: words ] ) {
	    [[ self lines ] removeObject: item ];
	    continue;
	}
	
    }
}


- (void)findTasks {
    NSEnumerator *en = [[ self lines ] objectEnumerator ];
    id item;
    TaskObject *task = nil;
    while ( item = [ en nextObject ] ) {
	if ( [ item hasPrefix: cronnixComment ] ) {
	    NSString *infoString = [ item substringFromIndex: [ cronnixComment length ]];
	    id nextLine = [ en nextObject ];
	    if ( nextLine ) {
		task = [[ TaskObject alloc ] initWithString: nextLine forSystem: [ self isSystemCrontab ]];
		[ task setInfo: infoString ];
	    }
	} else {
	    task = [[ TaskObject alloc ] initWithString: item forSystem: [ self isSystemCrontab ]];
	}
	[ self addTask: [ task autorelease ] ];
    }
}


// ENV= value [+more]
- (BOOL)hasEnvType1InWords: (NSArray *)words {
    if ( [ words count ] >= 2 && [ [ words objectAtIndex: 0 ] isLike: @"*=" ] ) {
		return YES;
    } else {
		return NO;
	}
}

// ENV= value [+more]
- (void)addEnvType1: (NSArray *)words {
	int i;
	NSString *word = [ [ words objectAtIndex: 0 ]
				substringToIndex: [ [ words objectAtIndex: 0 ] length ] -1 ];
	NSMutableString *env = [ NSMutableString stringWithString: word ];
	NSMutableString *value   = [ NSMutableString stringWithString: [ words objectAtIndex: 1 ]];
	for ( i = 2; i < [ words count ]; i++ ) {
	    [ value appendString: @" " ];
	    [ value appendString: [ words objectAtIndex: i ] ];
	}
	[ self addEnv: env withValue: value ];
}



// ENV=value [+more]
- (BOOL)hasEnvType2InWords: (NSArray *)words {
    NSString *env;
    NSMutableString *value;
    if ( [ words count ] >= 1 && [ [ words objectAtIndex: 0 ] isLike: @"*=*" ] ) {
	int i;
	NSArray *tmp = [ [ words objectAtIndex: 0 ] componentsSeparatedByString: @"=" ];
	if ( [ tmp count ] < 2 ) return NO;
	env   = [ tmp objectAtIndex: 0 ];
	value   = [ NSMutableString stringWithString: [ tmp objectAtIndex: 1 ]];
	// more "=" in this line, unlikely, but who knows
	for ( i = 2; i < [ tmp count ]; i++ ) {
	    [ value appendString: @"=" ];
	    [ value appendString: [ tmp objectAtIndex: i ] ];
	}
	[ self addEnv: env withValue: value ];
	return YES;
    }
    return NO;
}


// ENV = value [+more]
- (BOOL)hasEnvType3InWords: (NSArray *)words {
    NSString *env;
    NSMutableString *value;
    if ( [ words count ] >= 2 && [ [ words objectAtIndex: 1 ] isLike: @"=" ] ) {
	int i;
	env   = [ words objectAtIndex: 0 ];
	value   = [ NSMutableString stringWithString: [ words objectAtIndex: 2 ]];
	for ( i = 3; i < [ words count ]; i++ ) {
	    [ value appendString: @" " ];
	    [ value appendString: [ words objectAtIndex: i ] ];
	}
	[ self addEnv: env withValue: value ];
	return YES;
    }
    return NO;
}


// ENV =value [+more]
- (BOOL)hasEnvType4InWords: (NSArray *)words {
    NSString *env;
    NSMutableString *value;
    if ( [ words count ] >= 2 && [ [ words objectAtIndex: 1 ] isLike: @"=*" ] ) {
	int i;
	env   = [ words objectAtIndex: 0 ];
	value   = [ NSMutableString stringWithString: [[ words objectAtIndex: 1 ] substringFromIndex: 1 ]];
	for ( i = 2; i < [ words count ]; i++ ) {
	    [ value appendString: @" " ];
	    [ value appendString: [ words objectAtIndex: i ] ];
	}
	[ self addEnv: env withValue: value ];
	return YES;
    }
    return NO;
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

- (NSMutableArray *)tasks {
    return tasks;
}

- (void)setTasks: (NSMutableArray *)aValue {
    if ( tasks != aValue ) {
        [ tasks release ];
        tasks = [ aValue retain ];
    }
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

- (NSMutableDictionary *)envVariables {
    return envVariables;
}

- (void)setEnvVariables: (NSMutableDictionary *)aValue {
    if ( envVariables != aValue ) {
        [ envVariables release ];
        envVariables = [ aValue retain ];
    }
}

- (void)addEnv: (NSDictionary *)env {
    [ self addEnv: [ env objectForKey: @"Env" ] withValue: [ env objectForKey: @"Value" ]];
}

- (void)addEnv: (NSString *)env withValue: (NSString *)value {
    [[ self envVariables ] setObject: value forKey: env ];
}

- (void)removeEnv: (NSDictionary *)env {
    [ self removeEnvForKey: [ env objectForKey: @"Env" ]];
}

- (void)removeEnvForKey: (NSString *)key {
    [[ self envVariables ] removeObjectForKey: key ];
}

- (void)replaceEnv: (NSDictionary *)oldEnv with: (NSDictionary *)newEnv {
    [ self removeEnv: oldEnv ];
    [ self addEnv: newEnv ];
}


- (void)addTask: (TaskObject *)task {
    [[ self tasks] addObject: task ];
}


- (void)addTaskWithString: (NSString *)string {
    TaskObject *task = [[ TaskObject alloc ] initWithString: string ];
    [[ self tasks ] addObject: [ task autorelease ]];
}


- (NSArray *)envVariablesArray {
    NSMutableArray *envArray = [ NSMutableArray array ];
    NSEnumerator *enumerator = [[ self envVariables ] keyEnumerator ];
    id key;
    
    while ((key = [enumerator nextObject])) {
	id obj = [[ self envVariables ] objectForKey: key ];
	NSMutableDictionary *dict = [ NSMutableDictionary dictionary ];
	[ dict setObject: key forKey: @"Env" ];
	[ dict setObject: obj forKey: @"Value" ];
	[ envArray addObject: dict ];
    }
    
    return envArray;
}


- (NSMutableData *)envVariablesData {
    NSMutableData *envData = [ NSMutableData data ];
    NSEnumerator *enumerator = [[ self envVariables ] keyEnumerator ];
    id key;
    
    while ((key = [enumerator nextObject])) {
	id obj = [[ self envVariables ] objectForKey: key ];
	NSString *item = [ NSString stringWithFormat: @"%@ = %@\n", key, obj ];
	//		NSLog( @"%@=%@", key, obj );
	[ envData appendData: [ item dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
    }
    
    return envData;
}

- (NSMutableData *)data {
    NSMutableData *data = [ self envVariablesData ];
    
    // we need to build a different crontab in the "system" case, because of the additional "User" field
    NSEnumerator *enumerator = [[ self tasks ] objectEnumerator ];
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
    return [[ self tasks ] objectAtIndex: index ];
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


// notification handlers

- (void)envVariableAdded: (NSNotification *)notification {
    id dict = [ notification object ];
    [ self addEnv: dict ];
}

- (void)envVariableEdited: (NSNotification *)notification {
    id dict = [ notification object ];
    [ self replaceEnv: [ dict objectForKey: @"OldEnv" ] with: [ dict objectForKey: @"NewEnv" ]];
}

- (void)envVariableDeleted: (NSNotification *)notification {
    id dict = [ notification object ];
    [ self removeEnv: dict ];
}


@end
