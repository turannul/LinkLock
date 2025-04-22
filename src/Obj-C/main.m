//
//  main.m
//  LinkLock
//
//  Created by Turann_ on 6.03.2024.
//

#import "LL.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        LinkLock *app = [[LinkLock alloc] init];
        [application setDelegate:app];
        return NSApplicationMain(argc, argv);
    }
}
