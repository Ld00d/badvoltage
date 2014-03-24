//
//  BVButton.m
//  BadVoltageApp
//
//  Created by Frank Poole on 3/22/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVButton.h"
#import "BVCommand.h"

@implementation BVButton
{
    BVCommand *_command;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCommand:(BVCommand *)command
{
    _command = command;
    [self addTarget:command action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
}


@end
