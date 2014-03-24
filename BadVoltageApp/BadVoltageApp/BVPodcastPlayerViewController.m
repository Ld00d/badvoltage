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

static void *statusContext = &statusContext;
static void *rateContext = &rateContext;
static void *currentItemContext = &currentItemContext;



@implementation BVPodcastPlayerViewController
{
    BVPodcastEpisode * _episode;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    BOOL _playbackEnabled;
    BOOL _isPlaying;
}

- (id)initWithPodcastEpisode:(BVPodcastEpisode *)episode
{
    self = [super init];
    if (self) {
        _episode = episode;
        self.title = _episode.title;
        _playbackEnabled = NO;
        _isPlaying = NO;
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
    
    NSURL *mediaUrl = [NSURL URLWithString:[[_episode media] url]];
    
    /*
     Create an asset for inspection of a resource referenced by a given URL.
     Load the values for the asset keys "tracks", "playable".
     */
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mediaUrl options:nil];
    
    NSArray *requestedKeys = @[@"tracks", @"playable"];
    
    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
    
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareToPlayAsset:(AVURLAsset*)asset withKeys:(NSArray*)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self assetFailedToPrepareForPlayback:error];
			return;
		}
	}
    
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    if (_playerItem != nil) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        
    }
    
    _playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:statusContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    if (_player == nil) {
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        
        [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:currentItemContext];
        
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:rateContext];
    }

    if (_player.currentItem != _playerItem) {
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == statusContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerStatusUnknown:
                
                break;
            case AVPlayerStatusReadyToPlay:
                _playbackEnabled = YES;
                break;
            case AVPlayerStatusFailed:
                
                break;
            default:
                break;
        }
        
        
    } else if (context == rateContext) {
        
    } else if (context == currentItemContext) {
        
    }
        

}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{


}

- (void)assetFailedToPrepareForPlayback:(NSError *)error
{
//    [self removePlayerTimeObserver];
//    [self syncScrubber];
//    [self disableScrubber];
//    [self disablePlayerButtons];
//    
    /* Display the error. */
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)playMedia
{
    
    @try {
        [_player play];
    }
    @catch (NSException *exception) {
        NSLog(@"Problem playing audio: %@", exception.reason);
    }    
    
}


#pragma mark - BVPodcastPlayerDelegate

- (NSString *)podcastEpisodeSummary
{
    return [_episode summary];
}

- (BVCommand *)skipBackwardCommand
{
    return [self command:@"skipBackwardCommand"
                  action:^(id sender){}
         canPerformBlock:^BOOL(id obj) {
             return _playbackEnabled;
         }
            ];
}

- (BVCommand *)rewindCommand
{
    return [self command:@"rewindCommand"
                  action:^(id sender) {
        [_player setRate:-1.0];
    }
         canPerformBlock:^BOOL(id obj) {
        return [_playerItem canPlayFastReverse];
    }];
}

- (BVCommand *)stopCommand
{
    return [self command:@"stopCommand"
                  action:^(id sender) {
        [_player pause];
        [_player seekToTime:kCMTimeZero];
    }
         canPerformBlock:^BOOL(id obj) {
        return _isPlaying;
    }];
}

- (BVCommand *)playCommand
{
    return [self command:@"playCommand"
                  action:^(id sender) {
                      [self playMedia];
                  }
         canPerformBlock:^BOOL(id obj) {
             return !_isPlaying;
         }];
}

- (BVCommand *)pauseCommand
{
    return [self command:@"pauseCommand"
                  action:^(id sender) {
                    [_player pause];
                  }
         canPerformBlock:^BOOL(id obj) {
             return _isPlaying;
         }];
}

- (BVCommand *)fastForwardCommand
{
    return [self command:@"fastForwardCommand"
                  action:^(id sender) {
                      [_player setRate:2.0];
                  }
         canPerformBlock:^BOOL(id obj) {
             return [_playerItem canPlayFastForward];
         }];

}

- (BVCommand *)skipForwardCommand
{
    return [self command:@"skipForwardCommand"
                  action:^(id sender){}
         canPerformBlock:^BOOL(id obj) {
             return _playbackEnabled;
         }
            ];

}

@end
