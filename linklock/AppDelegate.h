//
//.  AppDelegate.h
//.  LinkLock
//
//.  Created by Turann_ on 7.03.2024 at 23:42
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreBluetooth/CoreBluetooth.h> // CoreBluetooth.framework

@interface LinkLock : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *_centralManager; // CoreBluetooth Manager
}

@property (strong, nonatomic) NSWindow *window;

- (BOOL)hasAccessibilityPermission;
- (void)displayAccessibilityAlert;

- (void)displayBluetoothAlert;
- (void)displayBluetoothOff;
- (void)displayBluetoothUnsupported;

-(void)scanFordevices;

@end