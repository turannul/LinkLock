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
    NSString *minorVersionStr = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion == 0 ? @"" : [NSString stringWithFormat:@".%ld", [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion];
    NSString *patchVersionStr = [[NSProcessInfo processInfo] operatingSystemVersion].patchVersion == 0 ? @"" : [NSString stringWithFormat:@".%ld", [[NSProcessInfo processInfo] operatingSystemVersion].patchVersion];

    NSLog(@"Hello World, LinkLock is running on macOS %ld%@%@",
        [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion,
        minorVersionStr,
        patchVersionStr);
}

- (BOOL)hasAccessibilityPermission {
    BOOL accessibilityAccess = AXIsProcessTrusted();
    NSLog(@"Accessibility permission is %@", accessibilityAccess ? @"available" : @"N/A, no fun :(");
    return accessibilityAccess;
}

- (void)displayAccessibilityAlert {
    NSAlert *accessibilityAlert = [[NSAlert alloc] init];
    [accessibilityAlert setMessageText:@"Missing Accessibility permission"];
    [accessibilityAlert setInformativeText:@"Because of security restrictions, Accessibility permission is required to restrict HID (Human Interface Device) events."];
    [accessibilityAlert addButtonWithTitle:@"Open Settings"];
    [accessibilityAlert addButtonWithTitle:@"Exit"];
    [accessibilityAlert setAlertStyle:NSAlertStyleCritical];

    NSModalResponse response = [accessibilityAlert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSURL *securityPrefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"];
        [[NSWorkspace sharedWorkspace] openURL:securityPrefsURL];
    } else if (response == NSAlertSecondButtonReturn) {
        exit(0);
    }
}
- (void)displayBluetoothAlert {
    NSAlert *bluetoothAccessAlert = [[NSAlert alloc] init];
    [bluetoothAccessAlert setMessageText:@"Missing Bluetooth permission"];
    [bluetoothAccessAlert setInformativeText:@"LinkLock needs bluetooth permission to play with it."];
    [bluetoothAccessAlert addButtonWithTitle:@"Open Settings"];
    [bluetoothAccessAlert addButtonWithTitle:@"Exit"];
    [bluetoothAccessAlert setAlertStyle:NSAlertStyleCritical];

    NSModalResponse response = [bluetoothAccessAlert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSURL *bluetoothPermPrefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth"];
        [[NSWorkspace sharedWorkspace] openURL:bluetoothPermPrefsURL];
    } else if (response == NSAlertSecondButtonReturn) {
        exit(0);
    }
}

- (void)displayBluetoothOff {
    NSAlert *bluetoothOffAlert = [[NSAlert alloc] init];
    [bluetoothOffAlert setMessageText:@"Bluetooth is turned off"];
    [bluetoothOffAlert setInformativeText:@"LinkLock requires bluetooth to be enabled."];
    [bluetoothOffAlert addButtonWithTitle:@"Open Settings"];
    [bluetoothOffAlert setAlertStyle:NSAlertStyleWarning];

    NSModalResponse response = [bluetoothOffAlert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSURL *bluetoothPrefsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.BluetoothSettings"];
        [[NSWorkspace sharedWorkspace] openURL:bluetoothPrefsURL];
    }
}

- (void)displayBluetoothUnsupported {
    NSAlert *bluetoothUnavailableAlert = [[NSAlert alloc] init];
    [bluetoothUnavailableAlert setMessageText:@"Bluetooth is unavailable"];
    [bluetoothUnavailableAlert setInformativeText:@"LinkLock needs Bluetooth so you don't have bye."];
    [bluetoothUnavailableAlert addButtonWithTitle:@"Exit"];
    [bluetoothUnavailableAlert setAlertStyle:NSAlertStyleCritical];

    NSModalResponse response = [bluetoothUnavailableAlert runModal];
    if (response == NSAlertFirstButtonReturn) { exit(0); }
}

- (void)scanFordevices {
    [_centralManager scanForPeripheralsWithServices:nil options:nil]; // * Start scanning
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered device: %@, ID: %@, SQ: %@", peripheral.name, peripheral.identifier.UUIDString, RSSI); // * Report scan results
}

// * Source: https://developer.apple.com/documentation/corebluetooth/cbmanagerstate?language=objc
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
      case CBManagerStateUnknown: // 0
            NSLog(@"Bluetooth state is unknown. (State: %ld)", (long)central.state);
            // ! unknown state (i guess) - is app can't/don't access bluetooth ( or broken hardware? which may not able to report status? ) 
            break;
      case CBManagerStateResetting: // 1
            NSLog(@"Bluetooth is resetting... (State: %ld)", (long)central.state);
            // ! Handle resetting state (not necessary because) 
            // ! killall -9 bluetoothd took less than a second to recover/reload on my m1 mbp
            break;
      case CBManagerStateUnsupported: // 2
            NSLog(@"This device does not support Bluetooth LE (Low Energy). (State: %ld)", (long)central.state);
            [self displayBluetoothUnsupported];
            break;
      case CBManagerStateUnauthorized: // 3
            NSLog(@"App is not authorized to use Bluetooth. (State: %ld)", (long)central.state);
            [self requestBluetoothPermission]; // ! Call the method above.
            break;
      case CBManagerStatePoweredOff: // 4
            NSLog(@"Bluetooth is powered off, please enable it in Settings. (State: %ld)", (long)central.state);
            [self displayBluetoothOff];
            // ! Handle powered off state (prompt user or disable features)
            // ! Show dialog? or just disable features??
            break;
      case CBManagerStatePoweredOn: // 5
            NSLog(@"Bluetooth is powered on. (State: %ld)", (long)central.state);
            [self requestBluetoothPermission];
            break;
    }
}

// * Source: https://developer.apple.com/documentation/corebluetooth/cbmanagerauthorization?language=objc
- (void)requestBluetoothPermission {
    CBManagerAuthorization status = _centralManager.authorization;
    // ? Processing 4 *possible* cases properly will prevent crash.
    switch (status) {
        case CBManagerAuthorizationNotDetermined: //. 0 
            NSLog(@"No Perm, requesting?. (Auth Status: %ld)", (long)status);
            [_centralManager authorize]; // ? Requests permission
            break;
        case CBManagerAuthorizationDenied: // . 2
            NSLog(@"No Perm, declined. (Auth Status: %ld)", (long)status);
            [self displayBluetoothAlert]; // ? Show dialog
            break;
        case CBManagerAuthorizationAllowedAlways: // . 3
            NSLog(@"We have bluetooth now! (Auth Status: %ld)", (long)status);
            [self scanFordevices];
            // ? Start scanning for devices - Multiple references calls it peripherals
            break;
        case CBManagerAuthorizationRestricted: // . 4 ?1 not sure about that
            NSLog(@"No Perm, restricted. (Auth Status: %ld)", (long)status);
            [self displayBluetoothAlert];
            // ? Restricted meaning (According to Apple); In this state, the user can’t change the Bluetooth authorization status, possibly due to active restrictions such as parental controls.
            break;
    }
}

@end
// todo UI stuff