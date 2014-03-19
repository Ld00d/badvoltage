//
//  BVSettingsRepository.m
//  BadVoltageApp
//
//  Created by Frank Poole on 3/17/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import "BVSettingsRepository.h"

static NSDictionary *_settings;

@implementation BVSettingsRepository


+ (void)initialize
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    _settings = [[NSDictionary alloc] initWithContentsOfFile:path];
}

+ (id)getSettingForKey:(NSString *)key
{
    return [_settings objectForKey:key];
}


@end
