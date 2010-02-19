//
//  NSString+Rubyisms.m
//
//  Created by Michael Mayo on 2/18/10.
//

#import "NSString+Rubyisms.h"

@implementation NSString (Rubyisms)

-(NSString *)capitalize {
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self split]];
    [components replaceObjectAtIndex:0 withObject:[[components objectAtIndex:0] capitalizedString]];
    return [components componentsJoinedByString:@" "];
}

-(NSString *)downcase {
    return [self lowercaseString];
}

-(NSString *)upcase {
    return [self uppercaseString];
}

-(NSArray *)split {
    return [self split:@" "];
}

-(NSArray *)split:(NSString *)str {
    return [self componentsSeparatedByString:str];
}

-(NSString *)camelize {
    return [self camelize:YES];
}

-(NSString *)camelize:(BOOL)firstCharacterUppercase {
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self split:@"_"]];
    NSUInteger i = firstCharacterUppercase ? 0 : 1;
    while (i < [components count]) {
        [components replaceObjectAtIndex:i withObject:[[components objectAtIndex:i] capitalizedString]];
        i++;
    }
    return [components componentsJoinedByString:@""];
}

-(Class)constantize {
    return NSClassFromString(self);
}

-(NSString *)dasherize {
    return [self stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
}

@end
