//
//  NSDictionary+JSON.h
//  TurnByTurn
//
//  Created by 原田 丞 on 12/03/20.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONCategories)

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress error:(NSError **)error;
+(NSDictionary*)dictionaryWithContentsOfJSONString:(NSString *)jsonString error:(NSError **)error;

-(NSData*)toJSON;

@end
