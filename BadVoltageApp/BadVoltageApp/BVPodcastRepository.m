//
//  BVPodcastRepository.m
//  BadVoltageApp
//
//  Created by Frank Poole on 3/15/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVPodcastRepository.h"
#import "BVPodcastEpisode.h"
#import "BVPodcastMedia.h"
#import "BVFeedParser.h"

static BVPodcastRepository *_podcastRepo;

@implementation BVPodcastRepository
{
    NSMutableArray *_cache;
    NSString *_feedUrl;
}

+ (void)initialize
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    _podcastRepo = [[BVPodcastRepository alloc] initWithSettings:settings];
}

+ (BVPodcastRepository *)podcastRepository
{
    return _podcastRepo;
}

- (id)initWithSettings:(NSDictionary *)settings
{
    self = [super init];
    if (self) {
        _cache = [[NSMutableArray alloc] init];
        _feedUrl = [settings objectForKey:@"BV_FEED_URL"];
    }
    return self;
}


- (NSArray *)getEpisodesWithRange:(NSRange)range
{
    if ([_cache count] < range.location + range.length) {

        [self loadCacheWithRange:range];
    }
    
    return [_cache subarrayWithRange:range];
}

- (void)loadCacheWithRange:(NSRange)range
{
    BVFeedParser *feedParser = [[BVFeedParser alloc] initWithUrl:_feedUrl];
    
    if ([_cache count] < range.location + 1) {
        range.length = range.location + range.length;
        range.location = 0;
        
    }
    
    NSArray *episodes = [feedParser getEpisodesWithRange:range];
    
    NSInteger count = [_cache count];
    
    for (int i=range.location, j=0; i<range.length; i++, j++) {
        if ( i < count ) {
            [_cache replaceObjectAtIndex:i withObject:[episodes objectAtIndex:j]];
        } else {
            [_cache addObject:[episodes objectAtIndex:j]];
        }
    }
}


@end
