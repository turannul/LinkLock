//
//  AppDelegate.m
//  LinkLock
//
//  Created by Turann_ on 7.03.2024 at 02:52
//

#import "AppDelegate.h"

@implementation LinkLock
- (instancetype)init { return self; }

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSLog(@"Hello World, LinkLock is running on macOS %ld.%ld.%ld",
            [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion,
            [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion,
            [[NSProcessInfo processInfo] operatingSystemVersion].patchVersion);
        // Creating/adding an Observer arguably more effective than launchd service
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name: NSApplicationWillResignActiveNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:NSApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification { /* Nothing to do here... (for now) */ }
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app { return YES; } // Nothing to do here either no fun :(

- (BOOL)hasAccessibilityPermission {
    BOOL accessibilityAccess = AXIsProcessTrusted();
    NSLog(@"Accessibility permission is %@", accessibilityAccess ? @"accepted" : @"declined, no fun :(");
    return accessibilityAccess;
}

- (void)displayAccessilityMissing {
    /* ... */
    NSLog(@"Without accessibility permission, I can't interfere with HID Devices");
}

- (void)displayBluetoothMissing {
    /* ... */
    NSLog(@"I don't have bluetooth access, what am i supposed to do now?");
}

- (void)displayBluetoothDeclined {
    // ...
    NSLog(@"Bluetooth permission not available, no fun :(");
}

/* - (void)scanDevices:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"We found a device? device: %@ signalPower: %@, rawData: %@ ", peripheral, RSSI, advertisementData);
} */

- (void)scanFordevices {
    NSLog(@"Proceeding to scanning devices/peripherals");
    [_centralManager scanForPeripheralsWithServices:nil options:nil]; // Start scanning
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Found via sfd: %@, ID: %@, SQ: %@", peripheral.name, peripheral.identifier.UUIDString, RSSI); // Report scan results 
    });
}

/* - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to device via sfd: %@", peripheral.name); // Connection ?
}         

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Disconnected to device via sfd: %@", peripheral.name); // Connection ?
}   */     
// Source: https://developer.apple.com/documentation/corebluetooth/cbmanagerauthorization?language=objc
- (void)requestBluetoothPermission {
    CBManagerAuthorization status = _centralManager.authorization;
    NSLog(@"Status: %ld", (long)status);
    // Processing 4 *possible* cases properly will prevent crash.
    switch (status) {
        case CBManagerAuthorizationNotDetermined: // 0 
            NSLog(@"No Perm, requesting?.");
            //[_centralManager authorize]; // Requests permission
            break;
        case CBManagerAuthorizationDenied: // 2 
            NSLog(@"No Perm, declined.");
            [self displayBluetoothDeclined]; // Show dialog
            break;
        case CBManagerAuthorizationAllowedAlways: // 3
            NSLog(@"We have bluetooth now!");
            [self scanFordevices]; // Start scanning for devices - Multiple references calls it peripherals
            break;
        case CBManagerAuthorizationRestricted: // 4 ?1 not sure about that
            NSLog(@"No Perm, restricted.");
            [self displayBluetoothDeclined];
            // Restricted meaning (According to Apple); In this state, the user can’t change the Bluetooth authorization status, possibly due to active restrictions such as parental controls.
            break;
    }
}

/* Source: https://developer.apple.com/documentation/corebluetooth/cbmanagerstate?language=objc */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Bluetooth state is %ld", (long)central.state);
    switch (central.state) {
      case CBManagerStateUnknown: // 0
            NSLog(@"Bluetooth state is unknown.");
            // unknown state (i guess) - is app can't/don't access bluetooth ( or broken hw? which may not able to report status? ) 
            break;
      case CBManagerStateResetting: // 1
            NSLog(@"Bluetooth is resetting...");
            // Handle resetting state (not necessary because) 
            // killall -9 bluetoothd just took a second to recover/reload on my m1 mbp
            break;
      case CBManagerStateUnsupported: // 2
            NSLog(@"This device does not support Bluetooth LE (Low Energy).");
            // Implement DeviceUnsupported view and exit.
            break;
      case CBManagerStateUnauthorized: // 3
            NSLog(@"App is not authorized to use Bluetooth.");
            [self requestBluetoothPermission]; // Call the method above.
            break;
      case CBManagerStatePoweredOff: // 4
            NSLog(@"Bluetooth is powered off, please enable it in Settings.");
            // Handle powered off state (prompt user or disable features)
            // Show dialog? or just disable features??
            break;
      case CBManagerStatePoweredOn: // 5
            NSLog(@"Bluetooth is powered on.");
            [self requestBluetoothPermission];
            break;
    }
}



// TODO: Try to discover and (un)paired device<s> (in the background?) 
// TODO: Create a display view & fix Xcode. <ffs Apple>
// TODO: Determine if the device is paired or not > > > > > > > CBCentralManager scanForPeripheralsWithServices:options:
// TODO: Detect signal power (RSSI) or connected at all? > > >  CBCentralManager scanForPeripheralsWithServices:options: 

@end
