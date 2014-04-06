//
//  BVViewController.m
//  BadVoltageApp
//
//  Created by Brian Lampe on 3/22/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVViewController.h"
#import "BVCommand.h"

@interface BVViewController ()

@end

@implementation BVViewController
{
    NSMutableDictionary *_commands;
}

- (id)init
{
    self = [super init];
    if (self) {
        _commands = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BVCommand *)command:(NSString *)name action:(void (^)(id))action canPerform:(BOOL)canPerform
{
    BVCommand *cmd = [_commands objectForKey:name];
    if (!cmd) {
        cmd = [[BVCommand alloc] initWithAction:action canPerform:canPerform];
        [_commands setObject:cmd forKey:name];
    }
    return cmd;
}

- (void)viewDidLoad
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeNone];

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
