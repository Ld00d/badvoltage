//
//  BVSettingsRepository.h
//  BadVoltageApp
//
//  Created by Frank Poole on 3/17/14.
//  Copyright (c) 2014 The Girls and Me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BVSettingsRepository : NSObject

+ (id)getSettingForKey:(NSString *)key;

@end
