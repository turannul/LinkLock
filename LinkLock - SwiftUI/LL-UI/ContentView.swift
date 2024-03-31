// ContentView.swift
// LinkLock UI (Swift)
//
// Created by EsraDnzz35_ on 30.03.2024.

import SwiftUI

struct DeviceRow: View {
    let deviceName: String
    let imageName: String
    @Binding var isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(isSelected ? .accentColor : .gray)
                .frame(width: 20, height: 20) // Adjust frame size properly.
                //.font(.system(size: 14)) // Set size accordingly to frame size property.
                .aspectRatio(contentMode: .fit) // Or we could fit images in frame, ngl swift is easy lol.
            Text(deviceName)
            Spacer()
            Toggle("", isOn: $isSelected)
                .toggleStyle(DefaultToggleStyle())
        }
    }
}

struct ContentView: View {
    @State private var hideUnidentified = true
    @State private var selectedDevices = Set<String>()

    var body: some View {
        VStack {
            List {
                ForEach(getDeviceData()) { device in
                    DeviceRow(deviceName: device.name, imageName: device.imageName, isSelected: Binding(
                        get: { self.selectedDevices.contains(device.name) },
                        set: { newValue in
                            if newValue {
                                self.selectedDevices.insert(device.name)
                            } else {
                                self.selectedDevices.remove(device.name)
                            }
                        }
                    ))
                }
            }
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.accentColor)
                Text("If your device isn't listed, try pairing it in system settings.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Toggle("Hide unidentified devices", isOn: $hideUnidentified)
            Button(action: { print("Selected Devices:", selectedDevices) }) {
                Text("Finish Setup")
            }
            .disabled(selectedDevices.isEmpty)
        }
        .padding()
    }

    func getDeviceData() -> [Device] {
        return [
            Device(name: "Turann_'s iPhone", imageName: "iphone"),
            Device(name: "Turann_'s Watch S4", imageName: "applewatch"), // R.I.P my watch
            Device(name: "Turann_'s Beats Studio Buds", imageName: "beats.studiobudsplus"),
            Device(name: "Turann_'s AirPods II", imageName: "airpods"),
            Device(name: "Turann_'s AirPods Pro", imageName: "airpodspro"),
            Device(name: "HUAWEI FreeBuds SE", imageName: "headphones"),
            Device(name: "EsraDnzz's MacBook Air", imageName: "laptopcomputer"),
            Device(name: "Turann's MacMini13", imageName: "macmini.fill"),
            Device(name: "Turann_'s iMac Pro", imageName: "desktopcomputer"),
            Device(name: "Upside Down", imageName: "magicmouse.fill")
        ]
    }
}

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
