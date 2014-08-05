//
//  TideInfo.h
//  KingTides
//
//  Created by linchuang on 23/07/2014.
//  Copyright (c) 2014 Green Cross Australia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TideInfo : NSObject
{
}
@property(nonatomic,copy) NSString* tideID;
@property(nonatomic,copy) NSString* location;
@property(nonatomic,copy) NSString* state;
@property(nonatomic,copy) NSString* description;
@property(nonatomic,copy) NSString* hightTideOccurs;
@property(nonatomic,copy) NSString* eventStarts;
@property(nonatomic,copy) NSString* eventEnds;
@property(nonatomic,copy) NSNumber* latitude;
@property(nonatomic,copy) NSNumber* longtitude;
@property(nonatomic,copy) NSString* picURL;//reserve for furture use
@property(nonatomic,assign) NSNumber* version;
+(NSArray*)parseJSON:(NSArray *)JSONData;
+(NSDictionary*)groupDataByState:(NSArray*)tideInfoArray;


@end


