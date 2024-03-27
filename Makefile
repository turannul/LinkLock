#
#.  Makefile.mk
#.  LinkLock
#
#. Created by Turann_ on 7.03.2024 at 00:42
#
appname := LinkLock
execname := LinkLock
identifier := xyz.turannul.LinkLock
version := 0.0.1
execpath := build/LinkLock.app/Contents/MacOS
plistpath := build/LinkLock.app/Contents/

all: $(execpath)/$(execname)

$(execpath)/$(execname): linklock/main.m linklock/LL.m
	rm -rf build/
	mkdir -p $(execpath)
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n' > $(plistpath)/Info.plist
	@printf '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n' >> $(plistpath)/Info.plist
	@printf '<plist version="1.0">\n' >> $(plistpath)/Info.plist
	@printf '<dict>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundleName</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>$(appname)</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundleIdentifier</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>$(identifier)</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundleDisplayName</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>$(appname)</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundleVersion</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>$(version)</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundleShortVersionString</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>$(version)</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundleExecutable</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>$(execname)</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundlePackageType</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>APPL</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>CFBundleSupportedPlatforms</key>\n' >> $(plistpath)/Info.plist
	@printf '    <array>\n' >> $(plistpath)/Info.plist
	@printf '        <string>MacOSX</string>\n' >> $(plistpath)/Info.plist
	@printf '    </array>\n' >> $(plistpath)/Info.plist
	@printf '    <key>LSMinimumSystemVersion</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>11.0</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>LSUIElement</key>\n' >> $(plistpath)/Info.plist
	@printf '    <true/>\n' >> $(plistpath)/Info.plist
	@printf '    <key>NSBluetoothPeripheralUsageDescription</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>Bluetooth is required to use LinkLock</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>NSBluetoothAlwaysUsageDescription</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>LinkLock observer requires Bluetooth in order to monitor device</string>\n' >> $(plistpath)/Info.plist
	@printf '    <key>NSHumanReadableCopyright</key>\n' >> $(plistpath)/Info.plist
	@printf '    <string>Copyright © 2024 Turann_. All rights reserved.</string>\n' >> $(plistpath)/Info.plist
	@printf '</dict>\n' >> $(plistpath)/Info.plist
	@printf '</plist>\n' >> $(plistpath)/Info.plist
	@clang -framework Cocoa -framework IOKit -framework CoreBluetooth -o $(execpath)/$(execname) linklock/main.m linklock/LL.m && printf "Build successful version: $(version)\n" || printf "Build unsuccessful!\n"
c:
	rm -rfv build/


