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
        self.title = _episode.title;
    }
    return self;
}

- (void)loadView
{
    BVPodcastPlayer *player = [[BVPodcastPlayer alloc] initWithDelegate:self];
    self.view = player;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playMedia
{
    NSURL *mediaUrl = [NSURL URLWithString:[[_episode media] url]];
    
    _player = [AVPlayer playerWithURL:mediaUrl];
    
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

#pragma mark - BVPodcastPlayerDelegate

- (void)skipBackward
{}

- (void)rewind
{}

- (void)stop
{}

- (void)play
{
    [self playMedia];
}

- (void)pause
{}

- (void)fastForward
{}

- (void)skipForward
{}

@end
