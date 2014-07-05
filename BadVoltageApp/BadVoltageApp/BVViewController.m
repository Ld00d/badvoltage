//
//  BVViewController.m
//  BadVoltageApp
//
//  Created by Brian Lampe on 3/22/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVViewController.h"
#import "BVImages.h"

@interface BVViewController ()

@end

@implementation BVViewController


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}



- (void)viewDidLoad
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeNone];

    UIImage *bgImage = [BVImages imageNamed:@"bv-lightning.jpg"];
    UIImageView *imgVw = [[UIImageView alloc] initWithImage:bgImage];
    [self.view addSubview:imgVw];
    [self.view sendSubviewToBack:imgVw];

    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
