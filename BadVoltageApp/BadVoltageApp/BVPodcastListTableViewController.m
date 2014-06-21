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


#import "BVPodcastListTableViewController.h"
#import "BVPodcastRepository.h"
#import "BVPodcastEpisode.h"
#import "BVSettingsRepository.h"
#import "BVPodcastPlayerViewController.h"
#import "BVImages.h"

@interface BVPodcastListTableViewController ()

@end

static NSInteger _feedBatchSz;

@implementation BVPodcastListTableViewController
{
    BVPodcastRepository *_podcastRepo;
    NSArray *_episodes;
    BVPodcastPlayerViewController *_selected;
    BVPodcastPlayerViewController *_nowPlaying;
    UIBarButtonItem *_nowPlayingButton;
    NSTimer *_refreshTimer;
}

+ (void)initialize
{
    NSNumber *feedBatchSz = [BVSettingsRepository getSettingForKey:@"BV_FEED_FETCH_SZ"];
    _feedBatchSz = [feedBatchSz integerValue];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _podcastRepo = [BVPodcastRepository podcastRepository];
        _selected = _nowPlaying = nil;
        //hard coded timer for 10800 seconds
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10800 target:self selector:@selector(refreshEpisodes) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[BVImages imageNamed:@"horizontalblackbg"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self.navigationItem.titleView = logoView;
    
    UIImageView *imgVw = [[UIImageView alloc] initWithImage:[BVImages imageNamed:@"bv-lightning.jpg"]];
    imgVw.contentMode = UIViewContentModeTopLeft;
    self.tableView.backgroundView = imgVw;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    _nowPlayingButton = [[UIBarButtonItem alloc] initWithImage:[BVImages imageNamed:@"next"] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingTouched:)];
    
    
    self.navigationItem.rightBarButtonItem = _nowPlayingButton;
    
    _nowPlayingButton.enabled = NO;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refreshEpisodes:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.backgroundView.layer.zPosition = refreshControl.layer.zPosition -1;
    
    [self setRefreshControl:refreshControl];
     
    NSRange range;
    range.length = _feedBatchSz;
    range.location = 0;
    _episodes = [_podcastRepo getEpisodesWithRange:range];
    
    
}

- (void)refreshEpisodes:(id)sender
{
    UIRefreshControl *refreshControl = sender;
    
    [self refreshEpisodes];
    
    [refreshControl endRefreshing];
}

- (void)refreshEpisodes
{
    [_podcastRepo refresh];
    
    NSRange range;
    range.length = _feedBatchSz;
    range.location = 0;
    _episodes = [_podcastRepo getEpisodesWithRange:range];
    
    
    [[self tableView] reloadData];
}

- (IBAction)nowPlayingTouched:(id)sender
{
    _selected = _nowPlaying;
    [[self navigationController] pushViewController:_selected animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if (_nowPlaying == nil && _selected != nil && _selected.isPlaying ) {
        //nothing was playing, but now it is.
        _nowPlaying = _selected;
        _nowPlayingButton.enabled = YES;
        
    } else if (_nowPlaying != nil && !_nowPlaying.isPlaying) {
        //something was playing, but it's not anymore.
        _nowPlaying = nil;
        _nowPlayingButton.enabled = NO;
    }
    
    _selected = nil;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)restorationIdentifier
{
    return @"BVPodcastListTableViewController";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_episodes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"podcastListTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    BVPodcastEpisode *episode = [_episodes objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[episode title]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BVPodcastEpisode *episode = [_episodes objectAtIndex:[indexPath row]];
    
    if (_nowPlaying == nil || _nowPlaying.episode != episode) {
        BOOL playbackAllowed = (_nowPlaying == nil);
        _selected = [[BVPodcastPlayerViewController alloc] initWithPodcastEpisode:episode playbackEnabled:playbackAllowed];
    } else {
        _selected = _nowPlaying;
    }

    [[self navigationController] pushViewController:_selected animated:NO];
}




@end
