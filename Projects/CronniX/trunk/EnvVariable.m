//
//  EnvVariable.m
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "EnvVariable.h"


@implementation EnvVariable

- (id)initWithString: (NSString *)line {
    [ super init ];
    return self;
}

+ (BOOL)isContainedInString: (NSString *)line {
    return NO;
}



@end
