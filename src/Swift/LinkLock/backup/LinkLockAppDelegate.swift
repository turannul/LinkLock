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
	@Published var selectedDevices: Set<UUID> = []
	@Published var discoveredDevices: [Device] = []
	@Published var statusStr: String = ""
	@Published var btn0Str: String = "" // Open A/B Settings
	@Published var btn0Show: Bool = false // Show the button
	@Published var btn1Str: String = "Quit App" // Quit App
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
		let selectedDevicesIDs = selectedDevices.map { $0.uuidString }
		let plistPath = getPlistPath()

		do {
			let data = try PropertyListSerialization.data(fromPropertyList: selectedDevicesIDs, format: .xml, options: 0)
			try data.write(to: plistPath)
			print("Selected devices saved successfully.")
		} catch {
			print("Error saving selected devices: \(error)")
		}
	}

	func loadSelectedDevices() {
		let plistPath = getPlistPath()

		if FileManager.default.fileExists(atPath: plistPath.path) {
			do {
				let data = try Data(contentsOf: plistPath)
				if let selectedDevicesIDs = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String] {
					selectedDevices = Set(selectedDevicesIDs.compactMap { UUID(uuidString: $0) })
					print("Selected devices loaded successfully.")
				}
			} catch {
				print("Error loading selected devices: \(error)")
			}
		}
	}

	func getPlistPath() -> URL {
		let fileManager = FileManager.default
		guard let preferencesDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
		else {
			fatalError("Unable to locate Library/Preferences directory.")
		}
		let plistPath = preferencesDirectory.appendingPathComponent("Preferences/xyz.turannul.linklock.plist")
		return plistPath
	}
}

struct Device: Identifiable {
	let id: UUID
	let name: String
	let imageName: String
}
