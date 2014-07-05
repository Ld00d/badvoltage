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

#import "BVPodcastSummaryViewController.h"

#define HTML @"<html> \
    <head> \
        <style> \
            body { color: white; !important; background-color:transparent;} \
            a { color: white; !important} \
            a:visited { color: purple; !important} \
            a:link { color: white; !important}\
        </style> \
    </head> \
    <body>%@</body> \
    </html>"


@interface BVPodcastSummaryViewController ()

@end

@implementation BVPodcastSummaryViewController
{
    NSString *_summaryHtml;
}

- (NSString *)summaryHtml
{
    return _summaryHtml;
}

- (void)setSummaryHtml:(NSString *)summaryHtml
{
    _summaryHtml = [NSString stringWithFormat:HTML, summaryHtml];
    [self.summaryView loadHTMLString:_summaryHtml baseURL:nil];

}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.summaryView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.summaryView loadHTMLString:_summaryHtml baseURL:nil];
    [self.summaryView setDelegate:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _summaryHtml = nil;
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //without reloading, the webview zooms in 
    [self.summaryView loadHTMLString:_summaryHtml baseURL:nil];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}


#pragma mark -


@end
