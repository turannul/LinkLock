//
//  LinkLockApp.swift
//  LinkLock
//
//  Created by Turann_ on 7.03.2024.
//

import Cocoa
import SwiftUI

@main
struct LinkLockApp: App {
	@StateObject private var bluetoothManager = LinkLockAppDelegate()

	var body: some Scene {
		WindowGroup {
			LinkLockUI()
				.environmentObject(bluetoothManager)
		}
	}
}

class LinkLock: NSObject { override init() { super.init() } }
