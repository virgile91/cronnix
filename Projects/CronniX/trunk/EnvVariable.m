//
//  EnvVariable.m
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "EnvVariable.h"


@implementation EnvVariable

- (id)initWithString: (NSString *)string {
    [ super init ];

	key = [[ NSString alloc ] init ];
	value = [[ NSString alloc ] init ];

    NS_DURING
	[ self parseString: string ];
    NS_HANDLER
	NSLog( @"Error parsing line: %@", string );
    NS_ENDHANDLER

	return self;
}

- (void)dealloc {
	[ key release ];
	[ value release ];
}

+ (id)envVariableWithEnvVariable: (id)anEnv {
    id env = [[ EnvVariable alloc ] init];
    [ env setValue: [ anEnv value ] forKey: [ anEnv key ]];
    return [ env autorelease ];
}

+ (id)envVariableWithString: (NSString *)string {
    return [[[ EnvVariable alloc ] initWithString: string ] autorelease ];
}

+ (id)envVariableWithValue: (NSString *)aValue forKey: (NSString *)aKey {
	id env = [[ EnvVariable alloc ] init];
	[ env setValue: aValue forKey: aKey ];
	return [ env autorelease ];
}

+ (BOOL)isContainedInString: (NSString *)string {
	if ( ! [ string isLike: @"*=*" ] ) return NO;
    return YES;
}

- (NSString *)key { return key; }
- (NSString *)value { return value; }

/*
 we use key value coding to map the env table contents to objects and need
 a slightly modified handling of the standard key value coding.
 The table columns have the identifiers "Env" and "Value", which are used as
 [ env valueForKey: @"Env" ];
 This would normally try to fetch an instance variable 'Env' which we don't have here.
 The method below maps this to the ivars key and value.
 */
- (id)valueForKey: (id)aKey {
	if ( [ aKey isEqualTo: @"key" ] ||
		 [ aKey isEqualTo: @"Key" ] ||
		 [ aKey isEqualTo: @"Env" ] ||
		 [ aKey isEqualTo: @"env" ] ) {
		 return [ self key ];
	} else if ( [ aKey isEqualTo: @"Value" ] ||
				[ aKey isEqualTo: @"value" ] ) {
		return [ self value ];
	}
	return [ super valueForKey: aKey ];
}


- (void) setValue: (id)aValue forKey: (id)aKey {
	if ( aValue != value ) {
		[ value release ];
		value = [ aValue copy ];
	}
	if ( aKey != key ) {
		[ key release ];
		key   = [ aKey copy ];
	}
}

- (void)parseString: (NSString *)string {
	NSScanner *scanner = [ NSScanner scannerWithString: string ];
	NSString *aKey;
	NSString *aValue;
	[ scanner scanUpToString: @"=" intoString: &aKey ];
	[ scanner scanString: @"=" intoString: nil ];
	aValue = [ string substringFromIndex: [ scanner scanLocation ]];
	aKey = [ aKey stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]];
	aValue = [ aValue stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]];
	[ self setValue: aValue forKey: aKey ];
}


- (NSData *)data {
    NSMutableData *envData = [ NSMutableData data ];
	NSString *item = [ NSString stringWithFormat: @"%@ = %@", [ self key ], [ self value ]];
	[ envData appendData: [ item dataUsingEncoding: [ NSString defaultCStringEncoding ]]];
    
    return envData;
}



@end
