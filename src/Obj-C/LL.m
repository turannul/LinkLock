//
//  LL.m
//  LinkLock
//
//  Created by Turann_ on 7.03.2024 at 02:52
//

#import "LL.h"

@implementation LinkLock
- (instancetype)init { return self; }

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *macModel = [self getMacModel];
    NSString *majorVersionStr = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion == 0 ? @"" : [NSString stringWithFormat:@"%ld", [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion];
    NSString *minorVersionStr = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion == 0 ? @"" : [NSString stringWithFormat:@".%ld", [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion];
    NSString *patchVersionStr = [[NSProcessInfo processInfo] operatingSystemVersion].patchVersion == 0 ? @"" : [NSString stringWithFormat:@".%ld", [[NSProcessInfo processInfo] operatingSystemVersion].patchVersion];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil]; });
    dispatch_async(dispatch_get_main_queue(), ^{ if (![self hasAccessibilityPermission]) { [self displayAccessibilityAlert]; } });
    
    NSLog(@"Hello World, LinkLock is running on %@ macOS %@%@%@", macModel, majorVersionStr, minorVersionStr, patchVersionStr);
}

// * https://developer.apple.com/documentation/corebluetooth/cbmanagerstate?language=objc
// * /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/CoreBluetooth.framework/Headers/CBCentralManager.h
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
      case CBManagerStateUnknown: //. 0
            NSLog(@"Bluetooth state is unknown. (State: %ld)", (long)central.state);
            // ! unknown state? Possibly broken hardware/software problem may cause OS to won't report any status.
            break;
      case CBManagerStateResetting: //. 1
            NSLog(@"Bluetooth is resetting... (State: %ld)", (long)central.state);
            // ! The connection with the system service was momentarily lost, update imminent.
            // ! killall -9 bluetoothd took less than a second to recover/reload on my m1 mbp < no need to worry about or handling >
            break;
      case CBManagerStateUnsupported: //. 2
            NSLog(@"This device won't support Bluetooth LE (Low Energy). (State: %ld)", (long)central.state);
            [self displayBluetoothUnsupported];
            break;
      case CBManagerStateUnauthorized: //. 3
            NSLog(@"App is not authorized to use Bluetooth. (State: %ld)", (long)central.state);
            [self requestBluetoothPermission]; // ! Call the method above.
            break;
      case CBManagerStatePoweredOff: //. 4
            NSLog(@"Bluetooth is powered off, please enable it in Settings. (State: %ld)", (long)central.state);
            [self displayBluetoothOff];
            // ! Handle powered off state (prompt user or disable features)
            // ! Show dialog? or just disable features??
            break;
      case CBManagerStatePoweredOn: //. 5
            NSLog(@"Bluetooth is powered on. (State: %ld)", (long)central.state);
            [self requestBluetoothPermission];
            break;
    }
}

// * https://developer.apple.com/documentation/corebluetooth/cbmanagerauthorization?language=objc
- (void)requestBluetoothPermission {
    CBManagerAuthorization status = _centralManager.authorization;
    // note: Processing all (4) different status will prevent crash.
    switch (status) {
        case CBManagerAuthorizationNotDetermined: //. 0 
            NSLog(@"Permission not requested yet. (Auth Status: %ld)", (long)status);
            // ! This is not required actually
            // .[_centralManager requestAuthorizationWithOptions:nil]; // * Request permission
            break;
        case CBManagerAuthorizationDenied: // . 2
            NSLog(@"Permission requested before and it was declined. (Auth Status: %ld)", (long)status);
            [self displayBluetoothAlert]; // * Show dialog
            break;
        case CBManagerAuthorizationAllowedAlways: // . 3
            NSLog(@"We have permission. (Auth Status: %ld)", (long)status);
            [_centralManager scanForPeripheralsWithServices:nil options:nil]; // * Start scanning
            // * Start scanning for devices - Multiple references calls it peripherals
            break;
        case CBManagerAuthorizationRestricted: // . 4
            NSLog(@"Bluetooth is restricted. (Auth Status: %ld)", (long)status);
            [self displayBluetoothAlert];
            // * Restricted meaning (According to Apple); In this state, the user can’t change the Bluetooth authorization status, possibly due to active restrictions such as parental controls.
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    BOOL hasValidName = peripheral.name != nil && ![peripheral.name isEqualToString:@"null"]; // * pointer safety incl.
    if (hasValidName) { NSLog(@"Discovered device: %@, ID: %@, SQ: %@", peripheral.name, peripheral.identifier.UUIDString, RSSI); } // * RSSI (Received Signal Strength Indication) also known as "signal strength"
    }


- (BOOL)hasAccessibilityPermission {
    BOOL accessibilityAccess = AXIsProcessTrusted();
    NSLog(@"Accessibility permission is %@", accessibilityAccess ? @"available (Trusted: 1)" : @"not available (Trusted: 0)");
    return accessibilityAccess;
}

//. UI Alerts
- (void)displayAccessibilityAlert {
    NSAlert *accessibilityAlert = [[NSAlert alloc] init];
    [accessibilityAlert setMessageText:@"Missing Accessibility permission"];
    [accessibilityAlert setInformativeText:@"Accessibility permission is required for LinkLock to restrict HID (Human Interface Device) devices."];
    [accessibilityAlert addButtonWithTitle:@"Open Settings"];
    [accessibilityAlert addButtonWithTitle:@"Exit"];
    [accessibilityAlert setAlertStyle:NSAlertStyleCritical];

    NSModalResponse response = [accessibilityAlert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSURL *securityPrefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"]; //. Shortcut of: System Preferences -> Security & Privacy -> Accessibility
        [[NSWorkspace sharedWorkspace] openURL:securityPrefsURL];
    } else if (response == NSAlertSecondButtonReturn) {
        exit(0);
    }
}

- (void)displayBluetoothAlert {
    NSAlert *bluetoothAccessAlert = [[NSAlert alloc] init];
    [bluetoothAccessAlert setMessageText:@"Missing Bluetooth permission"];
    [bluetoothAccessAlert setInformativeText:@"Bluetooth permission is required for LinkLock to monitor Bluetooth devices."];
    [bluetoothAccessAlert addButtonWithTitle:@"Open Settings"];
    [bluetoothAccessAlert addButtonWithTitle:@"Exit"];
    [bluetoothAccessAlert setAlertStyle:NSAlertStyleCritical];

    NSModalResponse response = [bluetoothAccessAlert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSURL *bluetoothPermPrefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth"]; //. Shortcut of: System Preferences -> Security & Privacy -> Bluetooth 
        [[NSWorkspace sharedWorkspace] openURL:bluetoothPermPrefsURL];
    } else if (response == NSAlertSecondButtonReturn) {
        exit(0);
    }
}

- (void)displayBluetoothOff {
    NSAlert *bluetoothOffAlert = [[NSAlert alloc] init];
    [bluetoothOffAlert setMessageText:@"Bluetooth is turned off"];
    [bluetoothOffAlert setInformativeText:@"Bluetooth needs to be turned on for LinkLock to monitor Bluetooth devices."];
    [bluetoothOffAlert addButtonWithTitle:@"Open Settings"];
    [bluetoothOffAlert setAlertStyle:NSAlertStyleWarning];

    NSModalResponse response = [bluetoothOffAlert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSURL *bluetoothPrefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.BluetoothSettings"]; //. Shortcut of: System Preferences -> Bluetooth
        [[NSWorkspace sharedWorkspace] openURL:bluetoothPrefsURL];
    }
}

- (void)displayBluetoothUnsupported {
    NSAlert *bluetoothUnavailableAlert = [[NSAlert alloc] init];
    [bluetoothUnavailableAlert setMessageText:@"Bluetooth is unavailable"];
    [bluetoothUnavailableAlert setInformativeText:@"Bluetooth is required for LinkLock to monitor Bluetooth devices."];
    [bluetoothUnavailableAlert addButtonWithTitle:@"Exit"];
    [bluetoothUnavailableAlert setAlertStyle:NSAlertStyleCritical];

    NSModalResponse response = [bluetoothUnavailableAlert runModal];
    if (response == NSAlertFirstButtonReturn) { exit(0); }
}

//. Model identifier for debugging purposes.
- (NSString *)getMacModel {
    NSTask *cmd = [[NSTask alloc] init];
    [cmd setLaunchPath:@"/usr/sbin/sysctl"];
    [cmd setArguments:@[@"-n", @"hw.model"]];
    NSPipe *pipe = [NSPipe pipe];
    [cmd setStandardOutput:pipe];
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    [cmd launch];
    NSData *data = [fileHandle readDataToEndOfFile];
    NSString *resultofcmd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    resultofcmd = [resultofcmd stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    return resultofcmd;
}

@end