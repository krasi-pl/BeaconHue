//
//  UIColor+BeaconHue.h
//  BeaconHue
//
//  Created by Karol Kozimor on 30/11/13.
//  Copyright (c) 2013 Appuccino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BeaconHue)

- (BOOL)getX:(CGFloat *)x Y:(CGFloat *)y brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha;
- (BOOL)getX:(CGFloat *)x Y:(CGFloat *)y brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha forModel:(NSString *)model;

@end
