//
//  BVButton.h
//  BadVoltageApp
//
//  Created by Frank Poole on 3/22/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BVCommand;

@interface BVButton : UIButton

- (void)setCommand:(BVCommand *)command;

@end
