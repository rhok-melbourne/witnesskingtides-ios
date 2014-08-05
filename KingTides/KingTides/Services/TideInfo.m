//
//  TideInfo.m
//  KingTides
//
//  Created by linchuang on 23/07/2014.
//  Copyright (c) 2014 Green Cross Australia. All rights reserved.
//

#import "TideInfo.h"
@interface TideInfo()

@end

@implementation TideInfo
+(NSArray*)parseJSON:(NSArray *)JSONData
{
    if (JSONData==nil||![JSONData isKindOfClass:[NSArray class]]) {
        return NO;
    }
    NSMutableArray* tideInfoArray= [NSMutableArray array];
    
    for(NSDictionary* item in JSONData)
    {
        TideInfo* oneTideInfo= [[TideInfo alloc] init];
        if(![[item objectForKey:@"id"] isKindOfClass: [NSString class]] ||[item objectForKey:@"id"]==nil)
            continue;
        oneTideInfo.tideID=[item objectForKey:@"id"];
        
        if(![[item objectForKey:@"event"] isKindOfClass: [NSDictionary class]] ||[item objectForKey:@"event"]==nil)
            continue;
        NSDictionary* eventInfo=[item objectForKey:@"event"];
        
        
        if ([eventInfo objectForKey:@"location"]==nil ||![[eventInfo objectForKey:@"location"] isKindOfClass:[NSString class]]) {
            continue;
        }
        oneTideInfo.location=[eventInfo objectForKey:@"location"];
        
        if ([eventInfo objectForKey:@"state"]==nil ||![[eventInfo objectForKey:@"state"] isKindOfClass:[NSString class]]) {
            continue;
        }
        oneTideInfo.state=[eventInfo objectForKey:@"state"];
        
        
        if ([eventInfo objectForKey:@"description"]==nil ||![[eventInfo objectForKey:@"description"] isKindOfClass:[NSString class]]) {
            continue;
        }
        oneTideInfo.description=[eventInfo objectForKey:@"description"];
        
        if ([eventInfo objectForKey:@"highTideOccurs"]==nil ||![[eventInfo objectForKey:@"highTideOccurs"] isKindOfClass:[NSString class]]) {
            continue;
        }
        oneTideInfo.hightTideOccurs=[eventInfo objectForKey:@"highTideOccurs"];
        
        if ([eventInfo objectForKey:@"eventStart"]==nil ||![[eventInfo objectForKey:@"eventStart"] isKindOfClass:[NSString class]]) {
            continue;
        }
        oneTideInfo.eventStarts=[eventInfo objectForKey:@"eventStart"];
        
        if ([eventInfo objectForKey:@"eventEnd"]==nil ||![[eventInfo objectForKey:@"eventEnd"] isKindOfClass:[NSString class]]) {
            continue;
        }
        oneTideInfo.eventEnds=[eventInfo objectForKey:@"eventEnd"];
        
        if ([eventInfo objectForKey:@"latitude"]==nil ||![[eventInfo objectForKey:@"latitude"] isKindOfClass:[NSNumber class]])
        {
            continue;
        }
        oneTideInfo.latitude=[eventInfo objectForKey:@"latitude"];
        
        if ([eventInfo objectForKey:@"longitude"]==nil ||![[eventInfo objectForKey:@"longitude"] isKindOfClass:[NSNumber class]]) {
            continue;
        }
        oneTideInfo.longtitude=[eventInfo objectForKey:@"longitude"];
        
        if ([eventInfo objectForKey:@"__v"]==nil ||![[eventInfo objectForKey:@"__v"] isKindOfClass:[NSNumber class]]) {
            continue;
        }
        oneTideInfo.version= [eventInfo objectForKey:@"__v"];
        
        [tideInfoArray addObject:oneTideInfo];
        
    }
    return [NSArray arrayWithArray:tideInfoArray];
    
    
}

+(NSDictionary*)groupDataByState:(NSArray*)tideInfoArray
{
    NSMutableSet* stateSet= [NSMutableSet set];
    NSMutableDictionary* tideInfoDivideByState= [NSMutableDictionary dictionary];
    
    for (TideInfo* info in tideInfoArray)
    {
        [stateSet addObject:info.state];
    }
    
    for (NSString* stateNmae in stateSet)
    {
        NSMutableArray* sectionArray= [NSMutableArray array];
        
        for (TideInfo* info in tideInfoArray) {
            if ([info.state isEqualToString:stateNmae])
            {
                [sectionArray addObject:info];
                
            }
        }
        [tideInfoDivideByState setObject:sectionArray forKey:stateNmae];
    }
    return [NSDictionary dictionaryWithDictionary:tideInfoDivideByState];
    
}

@end
