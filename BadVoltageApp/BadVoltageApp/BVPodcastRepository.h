//
//  BVPodcastRepository.h
//  BadVoltageApp
//
//  Created by Frank Poole on 3/15/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BVPodcastEpisode;

@interface BVPodcastRepository : NSObject

+ (BVPodcastRepository *)podcastRepository;

- (NSArray *)getEpisodesWithRange:(NSRange)range;


@end
