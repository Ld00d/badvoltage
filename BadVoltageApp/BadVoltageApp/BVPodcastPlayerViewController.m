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
#import "BVPodcastEpisode.h"
#import "BVPodcastMedia.h"
#import "BVImages.h"
#import <AVFoundation/AVFoundation.h>


static void *statusContext = &statusContext;
static void *rateContext = &rateContext;
static void *currentItemContext = &currentItemContext;

@interface BVPodcastPlayerViewController()
- (void)syncScrubber;

@end


@implementation BVPodcastPlayerViewController
{
    BVPodcastEpisode * _episode;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    id _timeObserver;
    float _rateToRestore;
    double _duration;
    BOOL _playbackEnabled;
    BOOL _isPlaying;
}

- (BOOL)isPlaying
{
    return _isPlaying;
}

- (BVPodcastEpisode *)episode
{
    return _episode;
}


- (id)initWithPodcastEpisode:(BVPodcastEpisode *)e playbackEnabled:(BOOL)enabled
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _episode = e;
        self.title = _episode.title;
        _playbackEnabled = enabled;
        _isPlaying = NO;
        _duration = 0.0f;
        _rateToRestore = 0.0f;
    }
    return self;
}



- (void)viewDidLoad
{
    UIImage *bgImage = [BVImages imageNamed:@"bv-lightning.jpg"];
    UIImageView *imgVw = [[UIImageView alloc] initWithImage:bgImage];
    [self.view addSubview:imgVw];
    [self.view sendSubviewToBack:imgVw];
    
    [self.summaryView setText:self.episode.summary];
    
    [self.summaryView setTextContainerInset:UIEdgeInsetsMake(5, 10, 5, 10)];
    
    
    [self.scrubber setValue:0.0];
    [self.scrubber setEnabled:NO];
    [self.scrubber setThumbImage:[BVImages imageNamed:@"thumb"] forState:UIControlStateNormal];
    
    if (_playbackEnabled) {
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
    }
    
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)restorationIdentifier
{
    return [NSString stringWithFormat:@"BVPodcastPlayerViewController::%@", _episode.title];
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
    
    [self removePlayerItemObserver];
    
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
                self.playButton.enabled = YES;
                [self initScrubber];
                
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



- (void)clearObservers
{
    [self removeTimeObserver];
    [self removePlayerItemObserver];
    [self removePlayerObserver];
}

- (void)removeTimeObserver
{
    if (_timeObserver != nil) {
        [_player removeTimeObserver:_timeObserver];
    }
    _timeObserver = nil;
}

- (void)removePlayerItemObserver
{
    if (_playerItem != nil) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
}

- (void)removePlayerObserver
{
    if (_player != nil) {
        [_player removeObserver:self forKeyPath:@"currentItem"];
        [_player removeObserver:self forKeyPath:@"rate"];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    self.rewindButton.enabled = NO;
    self.stopButton.enabled = NO;
    self.pauseButton.enabled = NO;
    self.playButton.enabled = YES;
    self.fastforwardButton.enabled = NO;
    
    [_player seekToTime:kCMTimeZero];
    _isPlaying = NO;

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
        _isPlaying = YES;
        self.rewindButton.enabled = _playerItem.canPlayFastReverse;
        self.stopButton.enabled = YES;
        self.fastforwardButton.enabled = _playerItem.canPlayFastForward;
        self.pauseButton.enabled = YES;
        self.playButton.enabled = NO;
    }
    @catch (NSException *exception) {
        NSLog(@"Problem playing audio: %@", exception.reason);
    }    
    
}


- (NSString *)podcastEpisodeSummary
{
    return [_episode summary];
}

#pragma mark scrubber

- (void)initScrubber
{
    CMTime playerDuration = [_playerItem duration];
    
    if (CMTIME_IS_INVALID(playerDuration)) {
        NSLog(@"Invalid player item duration");
        
    } else {
        self.scrubber.enabled = YES;
        _duration = CMTimeGetSeconds(playerDuration);
        [self initScrubberTimer];
    }
    
}

- (void)initScrubberTimer
{
    double interval = 0.1f;
    
    if (isfinite(_duration)) {
        CGFloat width = CGRectGetWidth(self.scrubber.bounds);
        interval = 0.5f * _duration / width;
    }
    __weak BVPodcastPlayerViewController *welf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                          queue:NULL
                                                     usingBlock:^(CMTime time) {
                                                         [welf syncScrubber];
                                                     }];

}

- (void)syncScrubber
{
    float minValue = self.scrubber.minimumValue;
    float maxValue = self.scrubber.maximumValue;
    
    double time = CMTimeGetSeconds(_player.currentTime);
    
    self.scrubber.value = (maxValue - minValue) * time / _duration + minValue;
}


- (IBAction)beginScrubbing:(id)sender
{
    _rateToRestore = [_player rate];
    _player.rate = 0.0f;
    
    [self removeTimeObserver];
}

- (IBAction)scrub:(id)sender
{
    if (isfinite(_duration)) {
        float minValue = _scrubber.minimumValue;
        float maxValue = _scrubber.maximumValue;
        float value = _scrubber.value;
        
        double time = _duration * (value - minValue) / (maxValue - minValue);
        
        [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
    }
    
    
}


- (IBAction)endScrubbing:(id)sender
{
    [self initScrubberTimer];
    if (_rateToRestore) {
        _player.rate = _rateToRestore;
        _rateToRestore = 0.0f;
    }

}

#pragma mark actions

- (IBAction)rewind:(id)sender
{
    [_player setRate:-1.0];
}


- (IBAction)stop:(id)sender
{
    [_player pause];
    [_player seekToTime:kCMTimeZero];
    _isPlaying = NO;
    self.playButton.enabled = YES;
    self.pauseButton.enabled = NO;
}


- (IBAction)play:(id)sender
{
    [self playMedia];
}


- (IBAction)pause:(id)sender
{
    [_player pause];
    self.playButton.enabled = YES;
    self.pauseButton.enabled = NO;
}


- (IBAction)fastforward:(id)sender
{
    [_player setRate:2.0];
}

#pragma mark -

- (void)dealloc
{
    NSLog(@"BVPodcastPlayerViewController dealloc");
    [self clearObservers];
    
    _episode = nil;
    _player = nil;
    _playerItem = nil;
    _timeObserver = nil;
}


@end
