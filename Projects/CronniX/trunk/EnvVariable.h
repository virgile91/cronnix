//
//  EnvVariable.h
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 abstracture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrontabLineParsing.h"

@interface EnvVariable : NSObject <CrontabLineParsing> {
	NSString *key;
	NSString *value;
}

- (id)initWithString: (NSString *)string;
+ (id)envVariableWithString: (NSString *)string;
+ (id)envVariableWithValue: (NSString *)aValue forKey: (NSString *)aKey;

+ (BOOL)isContainedInString: (NSString *)string;

- (NSString *)key;
- (NSString *)value;

- (void)parseString: (NSString *)string;

@end
