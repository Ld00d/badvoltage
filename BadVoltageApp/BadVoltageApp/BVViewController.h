//
//  BVViewController.h
//  BadVoltageApp
//
//  Created by Brian Lampe on 3/22/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BVCommand;

@interface BVViewController : UIViewController

- (BVCommand *)command:(NSString *)name
                action:(void(^)(id))action
       canPerform:(BOOL)canPerform;

@end
