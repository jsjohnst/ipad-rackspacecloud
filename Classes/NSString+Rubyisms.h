//
//  NSString+Rubyisms.h
//
//  Created by Michael Mayo on 2/18/10.
//

#import <Foundation/Foundation.h>

@class SpinnerViewController;

@interface NSString (Rubyisms)

// Returns a copy of str with the first character converted to uppercase and the remainder to lowercase.
-(NSString *)capitalize;

-(NSString *)downcase;
-(NSString *)upcase;

-(NSArray *)split;
-(NSArray *)split:(NSString *)str;

-(NSString *)camelize;
-(NSString *)camelize:(BOOL)firstCharacterUppercase;

-(Class)constantize;

-(NSString *)dasherize;

@end
