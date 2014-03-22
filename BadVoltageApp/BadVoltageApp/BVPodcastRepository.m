//The MIT License (MIT)

//Copyright (c) 2014 Brian Lampe
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


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
