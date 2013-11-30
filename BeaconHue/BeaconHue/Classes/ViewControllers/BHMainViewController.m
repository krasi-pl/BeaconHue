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

@property (nonatomic, strong) PHHueSDK* phHueSDK;

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
  
  [self.view addSubview:label];
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
  [self disableLocalHeartbeat];

}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successful
 */
- (void)pushlinkSuccess {

}

@end
