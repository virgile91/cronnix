
@protocol CrontabLineParsing

- (id)initWithString: (NSString *)line;
+ (BOOL)isContainedInString: (NSString *)line;

@end