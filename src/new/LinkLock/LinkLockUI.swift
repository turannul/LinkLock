//
//  LinkLockUI.swift
//  LinkLock
//
//  Created by Turann_ on 7.03.2024.
//

import SwiftUI

struct LinkLockUI: View {
    @EnvironmentObject var LLManager: LinkLockAppDelegate
    @State private var selectedDevices = Set<UUID>()

    var body: some View {
		/* if !LLManager.accessibilityAccess {
            VStack {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.accentColor)
                    Text(LLManager.statusStr).font(.footnote).foregroundColor(.gray)
                }
                Button(action: {
                    if let accessibilityPrivacyPrefs = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") { 
                        NSWorkspace.shared.open(accessibilityPrivacyPrefs)
                    }
                }) {
                    Text("Open Accessibility Privacy Settings")
                }
                Button(action: { exit(0) } ) { Text("Quit App") }
            }
            .padding()
        } else  */
        if LLManager.isBluetoothOff {
            VStack {
                StatusHeader(statusStr: LLManager.statusStr)
                
                if LLManager.btn0Show {
                    Button(action: {
                        if let bluetoothPrefs = URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings") { 
                            NSWorkspace.shared.open(bluetoothPrefs)
                        }
                    }) {
                        Text(LLManager.btn0Str)
                    }
                }

                if LLManager.btn1Show {
                    Button(action: { exit(0) }) {
                        Text(LLManager.btn1Str)
                    }
                }
            }
            .padding()
        } else if LLManager.isBluetoothUnavailable {
            VStack {
                StatusHeader(statusStr: LLManager.statusStr)
                
                if LLManager.btn0Show {
                    Button(action: {
                        if let bluetoothPrivacyPrefs = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth") { 
                            NSWorkspace.shared.open(bluetoothPrivacyPrefs)
                        }
                    }) {
                        Text(LLManager.btn0Str)
                    }
                }

                if LLManager.btn1Show {
                    Button(action: { exit(0) }) {
                        Text(LLManager.btn1Str)
                    }
                }
            }
            .padding()
        } else if LLManager.discoveredDevices.isEmpty {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.accentColor)
                Text("No device found, are you sure? 'other devices is in pairable mode'.")
                    .font(.footnote).foregroundColor(.gray).padding()
            }
        } else {
            VStack {
                List {
                    ForEach(LLManager.discoveredDevices) { device in
                        DeviceRow(deviceName: device.name, imageName: device.imageName, isSelected: Binding(
                            get: { self.selectedDevices.contains(device.id) },
                            set: { newValue in
                                if newValue {
                                    self.selectedDevices.insert(device.id)
                                } else {
                                    self.selectedDevices.remove(device.id)
                                }
                            }
                        ))
                    }
                }
                Button(action: { 
                    //LLManager.selectd_Devices = self.selectedDevices
                    LLManager.saveSelectedDevices()
                    print("Selected Devices:", selectedDevices) 
                }) {
                    Text("Confirm")
                }
                .disabled(selectedDevices.isEmpty)
            }
            .padding()
        }
    }
}

struct StatusHeader: View {
    let statusStr: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.accentColor)
            Text(statusStr).font(.footnote).foregroundColor(.gray)
        }
    }
}

struct DeviceRow: View {
    let deviceName: String
    let imageName: String
    @Binding var isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(isSelected ? .accentColor : .gray)
                .frame(width: 23, height: 23)
                .aspectRatio(contentMode: .fit)
            Text(deviceName)
            Spacer()
            Toggle("", isOn: $isSelected)
                .toggleStyle(DefaultToggleStyle())
        }
    }
}

struct LinkLockUI_Previews: PreviewProvider {
    static var previews: some View {
        LinkLockUI().environmentObject(LinkLockAppDelegate())
    }
}
