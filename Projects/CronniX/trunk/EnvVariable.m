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

- (void) setValue: (id)aValue forKey: (id)aKey {
	if ( aValue != value ) {
		[ value release ];
		value = [ aValue retain ];
	}
	if ( aKey != key ) {
		[ key release ];
		key   = [ aKey retain ];
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

@end
