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
                .frame(width:23, height:23) // Adjust frame size properly.
				.aspectRatio(contentMode:.fit) // Or we could fit images in frame, ngl swift is easy lol.
            Text(deviceName)
            Spacer()
            Toggle("", isOn: $isSelected)
                .toggleStyle(DefaultToggleStyle())
        }
    }
}

struct ContentView: View {
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
                Image(systemName: "info.circle").foregroundColor(.accentColor)
                Text("If your device isn't listed, try pairing it in system preferences.").font(.footnote)
					.foregroundColor(.gray)
            }
			Button(action: { print("Selected Devices:", selectedDevices) }) { Text("Confirm")}.disabled(selectedDevices.isEmpty)
        }
        .padding()
    }

    func getDeviceData() -> [Device] {
        return [ // This is just an example of *possible* UI
			// In real app Bluetooth devices could be actual devices, those are personal and argugeably trusted items.
			Device(name: "Turann_'s iPhone_8P", imageName: "iphone.gen1"),
			Device(name: "Turann_'s iPhone_XR", imageName: "iphone.gen2"),
			Device(name: "Turann_'s iPhone_XS", imageName: "iphone"),
            Device(name: "Turann_'s Watch S4", imageName: "applewatch"),
            Device(name: "Turann_'s Beats Studio Buds", imageName: "beats.studiobudsplus"),
			Device(name: "45 TU 420", imageName: "car.fill"),
			Device(name: "Turann_'s AirPods I", imageName: "airpods"),
			Device(name: "Turann_'s AirPods II", imageName: "airpods"),
			Device(name: "Turann_'s AirPods III", imageName: "airpods.gen3"),
            Device(name: "Turann_'s AirPods Pro", imageName: "airpodspro"),
            Device(name: "EsraDnzz's MacBook Air", imageName: "macbook.gen1"),
			Device(name: "EsraDnzz's MacBook Pro", imageName: "macbook.gen2"),
            Device(name: "Turann's MacMini13", imageName: "macmini.fill"),
			Device(name: "MacStudio", imageName: "macstudio.fill"),
            Device(name: "Turann_'s iMac Pro", imageName: "desktopcomputer"),
        ]
    }
}

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // imagename should be determined by system somehow?
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
