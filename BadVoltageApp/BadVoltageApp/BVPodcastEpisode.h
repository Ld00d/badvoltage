//
//  BVPodcastEpisode.h
//  BadVoltageApp
//
//  Created by Frank Poole on 3/15/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BVPodcastMedia;

@interface BVPodcastEpisode : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *subtitle;
@property(nonatomic, strong) NSString *summary;
@property(nonatomic, strong) NSDate *pubDate;

@property(nonatomic, strong) BVPodcastMedia *media;


@end
