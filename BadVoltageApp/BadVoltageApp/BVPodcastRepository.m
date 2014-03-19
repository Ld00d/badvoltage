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
#import "BVSettingsRepository.h"

static BVPodcastRepository *_podcastRepo;

@implementation BVPodcastRepository
{
    NSMutableArray *_cache;
    NSString *_feedUrl;
}

+ (void)initialize
{
    _podcastRepo = [[BVPodcastRepository alloc] init];
}

+ (BVPodcastRepository *)podcastRepository
{
    return _podcastRepo;
}

- (id)init
{
    self = [super init];
    if (self) {
        _cache = [[NSMutableArray alloc] init];
        _feedUrl = [BVSettingsRepository getSettingForKey:@"BV_FEED_URL"];
    }
    return self;
}


- (NSArray *)getEpisodesWithRange:(NSRange)range
{
    if ([_cache count] < range.location + range.length) {

        [self loadCacheWithRange:range];
    }
    
    //if it's still beyond the range...
    if ([_cache count] < range.location + range.length) {
        if ([_cache count] + 1 < range.location ) {
            return [[NSArray alloc] init];
        } else {
            range.length = range.length - ((range.location + range.length) - [_cache count]);
        }
        
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
    
    for (NSInteger i=range.location, j=0; i<[episodes count]; i++, j++) {
        if ( i < count ) {
            [_cache replaceObjectAtIndex:i withObject:[episodes objectAtIndex:j]];
        } else {
            [_cache addObject:[episodes objectAtIndex:j]];
        }
    }
}


@end
