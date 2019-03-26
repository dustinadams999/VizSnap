//
//  NSDictionary+JSON.m
//  TurnByTurn
//
//  Created by 原田 丞 on 12/03/20.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary(JSONCategories)

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress error:(NSError **)error
{
    *error = nil;
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlAddress] options:kNilOptions error:error];
    
    if (data == nil) {
        NSLog(@"NSDictionary:dictionaryWithContentsOfJSONURLString: error: %@", *error);
        return nil;
    }

    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:error];
    if (*error != nil) return nil;
    return result;
}

+ (NSDictionary *)dictionaryWithContentsOfJSONString:(NSString *)jsonString error:(NSError **)error
{
    *error = nil;

    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];

    if (*error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
//    NSData* result = [NSJSONSerialization dataWithJSONObject:self
//                                                     options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil) return nil;

    return result;
}

@end
