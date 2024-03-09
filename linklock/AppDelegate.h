//
//  AppDelegate.h
//  LinkLock
//
//  Created by Turann_ on 7.03.2024 at 23:42
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreBluetooth/CoreBluetooth.h> // CoreBluetooth.framework

@interface LinkLock : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *_centralManager; // CoreBluetooth Manager
}

@property (strong, nonatomic) NSWindow *window;

- (BOOL)hasAccessibilityPermission;
- (void)displayBluetoothMissing;
- (void)displayAccessilityMissing;

-(void)scanFordevices;

@end

/*
@interface CBManager : NSObject
@property(nonatomic, assign, readonly) CBManagerState state; // Current state of the manager 
This state is initially set to CBManagerStateUnknown. When the state updates, the manager calls its delegate’s centralManagerDidUpdateState: method.
*/
