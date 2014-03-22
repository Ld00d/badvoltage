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


#import "BVPodcastPlayer.h"
#define BUTTON_W 30.0
#define BUTTON_H 20.0
#define CTRLS_Y_OFFSET 40.0
#define CTRLS_X_SPACING 20.0

@implementation BVPodcastPlayer
{
    id<BVPodcastPlayerDelegate> _delegate;
    UIButton *_skipBackButton;
    UIButton *_rewindButton;
    UIButton *_stopButton;
    UIButton *_playButton;
    UIButton *_fastfwdButton;
    UIButton *_skipFwdButton;
    UIView *_buttonView;
    UITextView *_summaryView;
    
    BOOL _isPlaying;
    
}

- (id)initWithDelegate:(id<BVPodcastPlayerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _isPlaying = NO;
        _delegate = delegate;
        [self addControls];
        UIImage *bgImage = [UIImage imageNamed:@"bv-lightning.jpg"];
        UIImageView *imgVw = [[UIImageView alloc] initWithImage:bgImage];
        [self addSubview:imgVw];
        [self sendSubviewToBack:imgVw];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect frame = [self frame];
    CGRect btnFrame;
    CGRect summaryFrame;
    
    summaryFrame = CGRectMake(0, 0, frame.size.width, frame.size.height - CTRLS_Y_OFFSET - 10.0);
    _summaryView.frame = summaryFrame;
    
    frame.origin.y = frame.size.height - CTRLS_Y_OFFSET;
    frame.size.height = BUTTON_H;
    
    _buttonView.frame = frame;
    
    float x = (frame.size.width - ((BUTTON_W * 6) + (CTRLS_X_SPACING * 5))) / 2.0;
    
    btnFrame = CGRectMake(x, 0, BUTTON_W, BUTTON_H);
    _skipBackButton.frame = btnFrame;
    
    x = x + BUTTON_W + CTRLS_X_SPACING;
    btnFrame = CGRectMake(x, 0, BUTTON_W, BUTTON_H);
    _rewindButton.frame = btnFrame;
    
    x = x + BUTTON_W + CTRLS_X_SPACING;
    btnFrame = CGRectMake(x, 0, BUTTON_W, BUTTON_H);
    _stopButton.frame = btnFrame;
    
    x = x + BUTTON_W + CTRLS_X_SPACING;
    btnFrame = CGRectMake(x, 0, BUTTON_W, BUTTON_H);
    _playButton.frame = btnFrame;
    
    x = x + BUTTON_W + CTRLS_X_SPACING;
    btnFrame = CGRectMake(x, 0, BUTTON_W, BUTTON_H);
    _fastfwdButton.frame = btnFrame;
    
    x = x + BUTTON_W + CTRLS_X_SPACING;
    btnFrame = CGRectMake(x, 0, BUTTON_W, BUTTON_H);
    _skipFwdButton.frame = btnFrame;

}

- (void)addControls
{
    UIButton *btn;
    
    _summaryView = [[UITextView alloc] init];
    [_summaryView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:.3]];
    [_summaryView setTextColor:[UIColor whiteColor]];
    [_summaryView setText:[_delegate podcastEpisodeSummary]];
    //[_summaryView setContentInset:UIEdgeInsetsMake(10.0, 20.0, 10.0, 20.0)];
    [_summaryView setEditable:NO];
    [self addSubview:_summaryView];
    
    
    _buttonView = [[UIView alloc] init];
    [_buttonView setOpaque:NO];
    [_buttonView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:.3]];
    [self addSubview:_buttonView];
    
    btn = [[UIButton alloc] init];
    [btn setTitle:@"|<" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(skipBackward:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:btn];
    _skipBackButton = btn;
    
    btn = [[UIButton alloc] init];
    [btn setTitle:@"<<" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rewind:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:btn];
    _rewindButton = btn;
    
    btn = [[UIButton alloc] init];
    [btn setTitle:@"[]" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:btn];
    _stopButton = btn;
    
    btn = [[UIButton alloc] init];
    [btn setTitle:@">" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:btn];
    _playButton = btn;
    
    btn = [[UIButton alloc] init];
    [btn setTitle:@">>" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(fastForward:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:btn];
    _fastfwdButton = btn;
    
    btn = [[UIButton alloc] init];
    [btn setTitle:@">|" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(skipForward:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:btn];
    _skipFwdButton = btn;
}

- (IBAction)skipBackward:(id)sender
{
    [_delegate skipBackward];
}

- (IBAction)rewind:(id)sender
{
    [_delegate rewind];
}

- (IBAction)stop:(id)sender
{
    [_delegate stop];
}

- (IBAction)play:(id)sender
{
    if (_isPlaying) {
        [_playButton setTitle:@">" forState:UIControlStateNormal];
        [_delegate pause];
    } else {
        [_playButton setTitle:@"||" forState:UIControlStateNormal];
        [_delegate play];
    }
    _isPlaying = !_isPlaying;
}

- (IBAction)fastForward:(id)sender
{
    [_delegate fastForward];
}

- (IBAction)skipForward:(id)sender
{
    [_delegate skipForward];
}

@end
