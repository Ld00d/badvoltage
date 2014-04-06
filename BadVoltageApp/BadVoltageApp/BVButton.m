//
//  BVButton.m
//  BadVoltageApp
//
//  Created by Brian Lampe on 3/22/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVButton.h"
#import "BVCommand.h"

@implementation BVButton
{
    BVCommand *_command;
}

- (id)initWithCommand:(BVCommand *)command

{
    self = [super init];
    if (self) {
        _command = command;
        self.enabled = _command.canPerformAction;
        [self addTarget:command action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
        [_command addObserver:self forKeyPath:@"canPerformAction" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    self.enabled = _command.canPerformAction;
}

@end
