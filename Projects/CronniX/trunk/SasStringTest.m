//
//  SasStringTest.m
//  CronniX
//
//  Created by Sven A. Schmidt on Tue Mar 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SasStringTest.h"
#import "SasString.h"

@implementation SasStringTest

- (void)testFieldCount {
    NSCharacterSet *ws = [ NSCharacterSet whitespaceCharacterSet ];
    id line = @" 30\t5\t \t6       4       *       third Task\n";
    int fieldCount = [ line fieldCountSeperatedBy: ws ];
    [ self assertInt: fieldCount equals: 7 ];
}

- (void)testStartsWithNumer {
    id s = @"test";
    [ self assertFalse: [ s startsWithNumber ]];
}

@end
