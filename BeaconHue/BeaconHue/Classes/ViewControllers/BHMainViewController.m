//
//  BHMainViewController.m
//  BeaconHue
//
//  Created by Mariusz Błaszczyk on 30.11.2013.
//  Copyright (c) 2013 Appuccino. All rights reserved.
//

#import "BHMainViewController.h"
#import <HueSDK/HueSDK.h>

@interface BHMainViewController ()

@end

@implementation BHMainViewController

- (id)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}


- (void) loadView {
  [super loadView];
  
  
  UILabel* label = [[UILabel alloc] init];
  label.numberOfLines = 0;
  [label setText:@"Hello, last time you were on page: \n452. \n\nEnjoy!"];
  [label setFrame:CGRectMake(20, 20, 200, 500)];
  label.center = self.view.center;
  [label setTextAlignment:NSTextAlignmentCenter];
  
  [self.view addSubview:label];
}

@end
