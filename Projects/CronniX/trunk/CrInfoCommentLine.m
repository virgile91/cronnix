//
//  CrInfoCommentLine.m
//  CronniX
//
//  Created by Sven A. Schmidt on Wed Apr 07 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "CrInfoCommentLine.h"
#import "SasString.h"

@implementation CrInfoCommentLine

- (id)initWithString: (NSString *)line {
    [ super init ];
    return self;
}

+ (BOOL)isContainedInString: (NSString *)string {
    if ( [ string startsWithStringIgnoringWhitespace: CrInfoComment ] ) {
	return YES;
    } else {
	return NO;
    }
}


@end
