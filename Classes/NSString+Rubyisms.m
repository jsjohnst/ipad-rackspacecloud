//
//  NSString+Rubyisms.m
//
//  Created by Michael Mayo on 2/18/10.
//

#import "NSString+Rubyisms.h"

@implementation NSString (Rubyisms)

-(NSString *)capitalize {
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self componentsSeparatedByString:@" "]];
    [components replaceObjectAtIndex:0 withObject:[[components objectAtIndex:0] capitalizedString]];
    return [components componentsJoinedByString:@" "];
}

@end
