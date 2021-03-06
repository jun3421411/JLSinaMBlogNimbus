//
//  SMWeiboMainbodyEntity.m
//  SinaMBlog
//
//  Created by Jiang Yu on 13-1-30.
//  Copyright (c) 2013年 jimneylee. All rights reserved.
//

#import "SMStatusEntity.h"
#import "SMJSONKeys.h"
#import "NSString+StringValue.h"
#import "NSDateAdditions.h"
#import "SMRegularParser.h"

@implementation SMKeywordEntity
@end

@implementation SMStatusEntity

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDictionary:(NSDictionary*)dic
{
    if (!dic.count || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super initWithDictionary:dic];
    if (self) {
        self.user = (SMUserInfoEntity *)[SMUserInfoEntity entityWithDictionary:dic[JSON_STATUS_USER]];
        self.retweeted_status = (SMStatusEntity *)[SMStatusEntity entityWithDictionary:dic[JSON_STATUS_RETWEEDTED_STATUS]];
        self.created_at = dic[JSON_STATUS_CREATED_AT];
        self.blogID = [NSString getStringValue:dic[JSON_STATUS_ID]];
        self.blogMID = [NSString getStringValue:dic[JSON_STATUS_MID]];
        self.blogIDStr = dic[JSON_STATUS_IDSTR];
        self.text = dic[JSON_STATUS_TEXT];
        self.source = [self getSourceString:dic[JSON_STATUS_SOURCE]];
        self.favorited = [dic[JSON_STATUS_FAVORITED] boolValue];
        self.truncated = [dic[JSON_STATUS_TRUNCATED] boolValue];
        self.thumbnail_pic = dic[JSON_STATUS_THUMBNAIL_PIC];
        self.bmiddle_pic = dic[JSON_STATUS_BMIDDLE_PIC];
        self.original_pic = dic[JSON_STATUS_ORIGINAL_PIC];
        self.reposts_count = [dic[JSON_STATUS_REPOSTS_COUNT] intValue];
        self.comments_count = [dic[JSON_STATUS_COMMENTS_COUNT] intValue];
        self.attitudes_count = [dic[JSON_STATUS_ATTITUDES_COUNT] intValue];
        self.timestamp = [NSDate formatDateFromString:self.created_at];
        
        // 与其每个微博加载都卡，不如这边一次都解析好
        [self parseAllKeywords];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+(JLNimbusEntity *) entityWithDictionary:(NSDictionary *)dic {
    if (!dic.count || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    SMStatusEntity *entity = [[SMStatusEntity alloc] initWithDictionary:dic];    
    return entity;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//<a href="http://app.weibo.com/t/feed/40zIsF" rel="nofollow">谈微博</a>
- (NSString*)getSourceString:(NSString*)htmlSource
{
    NSRange range1 = [htmlSource rangeOfString:@"\">"];
    NSRange range2 = [htmlSource rangeOfString:@"/a>"];
    NSRange sourceRange = NSMakeRange(range1.location + range1.length,
                                      range2.location - (range1.location + range1.length) - 1);
    NSString* source = [htmlSource substringWithRange:sourceRange];
    return [NSString stringWithFormat:@"来自%@", source];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// 识别出 表情 at某人 share话题 标签
- (void)parseAllKeywords
{
    if (self.text.length) {
        // TODO: emotion
        // 考虑优先剔除表情，这样@和#不会勿标识
        if (!self.atPersonRanges) {
            self.atPersonRanges = [SMRegularParser keywordRangesOfAtPersonInString:self.text];
        }
        if (!self.sharpTrendRanges) {
            self.sharpTrendRanges = [SMRegularParser keywordRangesOfSharpTrendInString:self.text];
        }
    }
}

@end
