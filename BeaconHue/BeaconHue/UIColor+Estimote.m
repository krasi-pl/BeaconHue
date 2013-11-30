//
//  UIColor+Estimote.m
//  BeaconHue
//
//  Created by Karol Kozimor on 30/11/13.
//  Copyright (c) 2013 Appuccino. All rights reserved.
//

#import "UIColor+Estimote.h"

@implementation UIColor (Estimote)

+ (instancetype)colorWithShort:(unsigned short)value
{
    float r = (value & 0xF800) > 11;
    float g = (value & 0x07E0) > 5;
    float b = (value & 0x001F);
    r /= 31.0;
    g /= 63.0;
    b /= 31.0;
    return [self colorWithRed:r green:g blue:b alpha:1.0f];
}

@end
