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

#import "BVPodcastDetailViewController.h"
#import "BVPodcastEpisode.h"
#import "BVImages.h"
#import "BVPodcastSummaryViewController.h"

@interface BVPodcastDetailViewController ()

@end

@implementation BVPodcastDetailViewController
{
    BVPodcastEpisode *_episode;
    BVPodcastSummaryViewController *_summaryViewController;
}

- (id)initWithEpisode:(BVPodcastEpisode *)episode
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _episode = episode;
        self.title = episode.title;

        _summaryViewController = [[BVPodcastSummaryViewController alloc] init];
        [_summaryViewController setSummaryHtml:episode.summary];
        
        [self addChildViewController:_summaryViewController];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _summaryViewController.view.frame = self.summaryView.frame;
    [self.summaryView addSubview:_summaryViewController.view];
    [_summaryViewController didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playEpisode:(id)sender {
    NSDictionary *userInfo = @{@"episode": _episode};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BVPlayEpisodeNotification" object:nil userInfo:userInfo];
}

- (void)dealloc
{
    _episode = nil;
    _summaryViewController = nil;
}


@end
