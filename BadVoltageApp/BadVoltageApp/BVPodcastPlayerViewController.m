//
//  BVPodcastPlayerViewController.m
//  BadVoltageApp
//
//  Created by Frank Poole on 3/18/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVPodcastPlayerViewController.h"
#import "BVPodcastPlayer.h"
#import "BVPodcastEpisode.h"
#import "BVPodcastMedia.h"
#import <AVFoundation/AVFoundation.h>


@interface BVPodcastPlayerViewController ()

@end

@implementation BVPodcastPlayerViewController
{
    BVPodcastEpisode * _episode;
    AVPlayer *_player;
}

- (id)initWithPodcastEpisode:(BVPodcastEpisode *)episode
{
    self = [super init];
    if (self) {
        _episode = episode;
    }
    return self;
}

- (void)loadView
{
    self.view = [[BVPodcastPlayer alloc] init];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self playMedia];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playMedia
{
    //NSError *error;
    NSURL *mediaUrl = [NSURL URLWithString:[[_episode media] url]];
    
    _player = [AVPlayer playerWithURL:mediaUrl];
    
//    if (error != nil) {
//        NSLog(@"Problem playing audio %@", error.localizedDescription);
//    }
    @try {
        [_player play];
    }
    @catch (NSException *exception) {
        NSLog(@"Problem playing audio: %@", exception.reason);
    }    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
