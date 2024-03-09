//
//  main.m
//  LinkLock
//
//  Created by Turann_ on 6.03.2024.
//

#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        LinkLock *app = [[LinkLock alloc] init];
        [application setDelegate:app]; // corrected delegate assignment
        return NSApplicationMain(argc, argv);
    }
}
