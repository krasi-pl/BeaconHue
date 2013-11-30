//
//  BHMainViewController.m
//  BeaconHue
//
//  Created by Mariusz Błaszczyk on 30.11.2013.
//  Copyright (c) 2013 Appuccino. All rights reserved.
//

#import "BHMainViewController.h"
#import "UIColor+BeaconHue.h"
#import <HueSDK/HueSDK.h>

@interface BHMainViewController ()

@property (nonatomic, strong) PHHueSDK* phHueSDK;
@property (nonatomic, strong) PHLight* ourLight;
@property (nonatomic, strong) UISlider* valueHue;
@property (nonatomic, strong) UIButton* updateButton;
@property (nonatomic, strong) NSMutableArray* rgbSliders;
@property (nonatomic, strong) UIView* rgbView;
@end

@implementation BHMainViewController

- (id)init
{
  self = [super init];
  if (self) {
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    
    // Listen for notifications
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    /***************************************************
     If there is no authentication against the bridge this notification is sent
     *****************************************************/
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
     [self enableLocalHeartbeat];
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
  
//  self.valueHue = [[UISlider alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 100, 280, 40)];
//  self.valueHue.minimumValue = 0;
//  self.valueHue.maximumValue = 254;
//  [self.view addSubview: self.valueHue];
  
  self.rgbSliders = [NSMutableArray array];
  for (int i=0; i<3; ++i) {
    UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 180 + 40*i, 240, 40)];
    slider.minimumValue = 0;
    slider.maximumValue = 255;
    [self.view addSubview: slider];
    [self.rgbSliders addObject:slider];
  }
  
  
  self.rgbView = [[UIView alloc] initWithFrame:CGRectMake(260, self.view.bounds.size.height - 180, 40, 120)];
  [self.view addSubview:self.rgbView];
  
  self.updateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.updateButton.frame = (CGRectMake(100, self.view.bounds.size.height - 60, 120, 44));
  [self.updateButton setTitle:@"Update" forState:UIControlStateNormal];
  [self.updateButton addTarget:self action:@selector(updateLight) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:self.updateButton];
  [self.view addSubview:label];
}


- (void) viewDidAppear:(BOOL)animated {
  double delayInSeconds = 5.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    NSLog(@"do saome magic");
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];

    
    for (PHLight* light in cache.lights) {
      NSLog(@"Got : %@", light);
    }
    
    self.ourLight = [cache.lights objectForKey:@"2"];
    
    
  });
}


- (PHLightState *)createLightState {
  /***************************************************
   The PHLightState class is used as a parameter for the
   Hue SDK. It contains the attribute settings for an individual\
   light. This method creates it from the current
   user interface settings for the light
   *****************************************************/
  
  
  
  // Create an empty lightstate
  PHLightState *lightState = [[PHLightState alloc] init];
  
  // Check if on value should be send
  [lightState setOnBool:YES];
  
  CGFloat red = [(UISlider*)[self.rgbSliders objectAtIndex:0] value] / 255.0;
  CGFloat green = [(UISlider*)[self.rgbSliders objectAtIndex:1] value] / 255.0;
  CGFloat blue = [(UISlider*)[self.rgbSliders objectAtIndex:2] value] / 255.0;
  
  UIColor* sampleColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
  [self.rgbView setBackgroundColor:sampleColor];
  
  float h,s,b;
  [sampleColor getHue:&h saturation:&s brightness:&b alpha:NULL];
  
  float xColor, yColor;
  [sampleColor getX:&xColor Y:&yColor brightness:NULL alpha:NULL];
  
  // Check if hue value should be send
  
      [lightState setX:[NSNumber numberWithFloat:xColor]];
      [lightState setY:[NSNumber numberWithFloat:yColor]];
  
  
  
  
  
  // Check if saturation value should be send
//  if (self.sendSat.on) {
//    [lightState setSaturation:[NSNumber numberWithInt:((int)self.valueSat.value)]];
//  }
  
  // Check if brightness value should be send
//  if (self.sendBri.on) {
//    [lightState setBrightness:[NSNumber numberWithInt:((int)self.valueBri.value)]];
//  }
  
  // Check if xy values should be send

  
  // Check if effect value should be send
//  if (self.sendEffect.on) {
//    if (self.valueEffect.selectedSegmentIndex == 0) {
//      [lightState setEffectMode:EFFECT_NONE];
//    }
//    else if (self.valueEffect.selectedSegmentIndex == 1) {
//      [lightState setEffectMode:EFFECT_COLORLOOP];
//    }
//  }
  
  // Check if alert value should be send
//  if (self.sendAlert.on) {
//    if (self.valueAlert.selectedSegmentIndex == 0) {
//      [lightState setAlertMode:ALERT_NONE];
//    }
//    else if (self.valueAlert.selectedSegmentIndex == 1) {
//      [lightState setAlertMode:ALERT_SELECT];
//    }
//    else if (self.valueAlert.selectedSegmentIndex == 2) {
//      [lightState setAlertMode:ALERT_LSELECT];
//    }
//  }
//  
//  // Check if transition time should be send
//  if (self.sendTransitionTime.on) {
//    [lightState setTransitionTime:[NSNumber numberWithInt:((int)self.valueTransitionTime.value)]];
//  }
  
  return lightState;
}

- (void) updateLight {
  id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
  
  // Send lightstate to light
  PHLightState *lightState = [self createLightState];
  [bridgeSendAPI updateLightStateForId:self.ourLight.identifier withLighState:lightState completionHandler:^(NSArray* errors) {
    
  }];
}


#pragma mark - Hue start methods
- (void)notAuthenticated {
  /***************************************************
   We are not authenticated so we start the authentication process
   *****************************************************/
  
  // Move to main screen (as you can't control lights when not connected)
  [self.navigationController popToRootViewControllerAnimated:YES];
  
  // Dismiss modal views when connection is lost
  if (self.navigationController.presentedViewController) {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
  }
  
  NSLog(@"Not authenticated");
  [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

- (void)enableLocalHeartbeat {
  /***************************************************
   The heartbeat processing collects data from the bridge
   so now try to see if we have a bridge already connected
   *****************************************************/
  
  PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
  if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
    // Some bridge is known
    [self.phHueSDK enableLocalConnectionUsingInterval:10];
  }
  else {
    /***************************************************
     No bridge connected so start the bridge search process
     *****************************************************/
    
    // No bridge known
    [self searchForBridgeLocal];
  }
}

- (void)disableLocalHeartbeat {
  [self.phHueSDK disableLocalConnection];
}

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
  // Stop heartbeats
  [self disableLocalHeartbeat];
  
  // Show search screen
  NSLog(@"Searching...");
  /***************************************************
   A bridge search is started using UPnP to find local bridges
   *****************************************************/
  
  // Start search
  PHBridgeSearching *bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES];
  [bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
    // Done with search, remove loading view
    
    // Check for results
    if (bridgesFound.count > 0) {
      NSLog(@"Bridge found");
      NSString *username = [PHUtilities whitelistIdentifier];
      NSArray* macs = [bridgesFound allKeys];
      NSArray* ips = [bridgesFound allValues];
      
      [self.phHueSDK setBridgeToUseWithIpAddress:[ips lastObject]
                                      macAddress:[macs lastObject]
                                     andUsername:username];
      
      [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
      
    }
    else {
      NSLog(@"No bridge found");
    }
  }];
}

/**
 Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
 */
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andMacAddress:(NSString *)macAddress {
  /***************************************************
   Removing the selection view controller takes us to
   the 'normal' UI view
   *****************************************************/
  
  // Remove the selection view controller
//  self.bridgeSelectionViewController = nil;
//  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  
  // Show a connecting view while we try to connect to the bridge
//  [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
  
  // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
//  NSString *username = [PHUtilities whitelistIdentifier];
  /***************************************************
   Set the username, ipaddress and mac address,
   as the bridge properties that the SDK framework will use
   *****************************************************/
//  [UIAppDelegate.phHueSDK setBridgeToUseWithIpAddress:ipAddress macAddress:macAddress andUsername:username];
  
  /***************************************************
   Setting the hearbeat running will cause the SDK
   to regularly update the cache with the status of the
   bridge resources
   *****************************************************/
  
  // Start local heartbeat again
  [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
  // Disable heartbeats
  NSLog(@"do authenticate!!");
  [self disableLocalHeartbeat];
}

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
  // Check current connection state
  [self checkConnectionState];
  
  // Check if an update is available
  //[self performSelector:@selector(updateCheck) withObject:nil afterDelay:1];
    NSLog(@"have local connection");
}

- (void)noLocalConnection {
  NSLog(@"no local connection");
}


- (void)checkConnectionState {
  if (!self.phHueSDK.localConnected) {
    NSLog(@"not connected :(");
  }
  else {
    NSLog(@"Connected :)");
  }
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successful
 */
- (void)pushlinkSuccess {

}

@end
