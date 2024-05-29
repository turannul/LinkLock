//
// LinkLockAppDelegate.swift
// LinkLock
//
// Created by Turann_ on 16.05.2024 <Swift Re-write>
//


import Foundation
import CoreBluetooth
import SwiftUI
import AppKit

class LinkLockAppDelegate: NSObject, ObservableObject, CBCentralManagerDelegate {
	@Published var selectd_Devices: Set<UUID> = []
	@Published var discoveredDevices: [Device] = []
	// Warning Strings
	@Published var statusStr: String = ""
	// Button 0 text
	@Published var btn0Str: String = "" // Open A/B Settings 
	// Button 0 show/hide
	@Published var btn0Show: Bool = false // Show the button
	// Button 1 text
	@Published var btn1Str: String = "Quit App" // Quit App
	// Button 1 show/hide
	@Published var btn1Show: Bool = false // Show the button
	
	@Published var isBluetoothOff: Bool = false // default value is false
	@Published var isBluetoothUnavailable: Bool = false // default value is false
	@Published var accessibilityAccess: Bool = true // default value is false
	private var centralManager: CBCentralManager?

	override init() {
		super.init()
		loadSelectedDevices()
		centralManager = CBCentralManager(delegate: self, queue: nil)
	}

	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
			case .unknown:
				statusStr = "Bluetooth state is unknown."
				isBluetoothUnavailable = true
				btn1Show = true
			case .resetting:
				statusStr = "Bluetooth is resetting..."
				isBluetoothOff = true
			case .unsupported:
				statusStr = "This device does not support Bluetooth LE (Low Energy)."
				isBluetoothUnavailable = true
				btn1Show = true
			case .unauthorized:
				statusStr = "App is not authorized to use Bluetooth."
				isBluetoothUnavailable = true
				btn0Show = true
				btn1Str = "Open Bluetooth Privacy Settings"
				btn1Show = true
				requestBluetoothPermission()
			case .poweredOff:
				statusStr = "Bluetooth is powered off, please enable it in Settings."
				isBluetoothOff = true
				isBluetoothUnavailable = true
				btn0Show = true
				btn1Str = "Open Bluetooth Settings"
				btn1Show = true
			case .poweredOn:
				isBluetoothOff = false
				isBluetoothUnavailable = false
				requestBluetoothPermission()
			@unknown default:
				statusStr = "Unknown state? please wait..."
				btn1Show = true
				break
		}
	}

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		guard let name = peripheral.name else { return }
		let device = Device(id: peripheral.identifier, name: name, imageName: "iphone")
		if !discoveredDevices.contains(where: { $0.id == device.id }) {
			discoveredDevices.append(device)
			print("Discovered device: \(name), ID: \(peripheral.identifier.uuidString), RSSI: \(RSSI)")
		}
	}

	func requestBluetoothPermission() {
		guard let centralManager = centralManager else { return }
		let status = centralManager.authorization
		switch status {
			case .notDetermined:
				statusStr = "Permission not requested yet."
				btn0Show = true
				btn0Str = "Request Permission"
			case .denied:
				statusStr = "Permission requested before and it was declined."
				isBluetoothUnavailable = true
				btn0Show = true
				btn0Str = "Request Permission"
			case .allowedAlways:
				print("We have what we need, let's go.")
				centralManager.scanForPeripherals(withServices: nil, options: nil)
			case .restricted:
				statusStr = "Bluetooth is restricted."
				isBluetoothUnavailable = true
				btn1Show = true
			@unknown default:
				break
		}
	}

	func saveSelectedDevices() {
		let selectedDeviceUUIDs = selectd_Devices.map { $0.uuidString }
		UserDefaults.standard.set(selectedDeviceUUIDs, forKey: "selectedDevices")
		print("Selected devices saved successfully.")
		// Check if all UUID strings were successfully converted
		if selectedDeviceUUIDs.count != selectd_Devices.count {
			print("Warning: Some UUID strings could not be converted.")
		}
	}


	func loadSelectedDevices() {
		guard let selectedDeviceUUIDs = UserDefaults.standard.stringArray(forKey: "selectedDevices") else { return }
		var selectedDevices: Set<UUID> = []
		for idString in selectedDeviceUUIDs {
			if let uuid = UUID(uuidString: idString) {
				selectedDevices.insert(uuid)
			} else {
				print("Invalid UUID string: \(idString)")
			}
		}
		selectd_Devices = selectedDevices
		print("Selected devices loaded successfully.")
	}
}

struct Device: Identifiable {
	let id: UUID
	let name: String
	let imageName: String
}
