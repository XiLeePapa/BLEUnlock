# BLEUnlock

BLEUnlock locks your Mac when you walk away with your iPhone, Apple Watch, or another Bluetooth Low Energy device, and unlocks it when you get back. The app lives in the menu bar, and nothing runs on the phone.

This repository is a fork of [ts1/BLEUnlock](https://github.com/ts1/BLEUnlock). It keeps the original behaviour, fixes what broke on recent macOS, and adds a few things on top.

![Downloads](https://img.shields.io/github/downloads/XiLeePapa/BLEUnlock/total.svg)
[![Buy me a coffee](img/buymeacoffee.svg)](https://www.buymeacoffee.com/tsone)

This document is also available in [Japanese](README.ja.md).

## What this fork adds

- **Device names in the list.** You pick `q phone`, not `197634CD-E57D-64DE-6DE0-26F579277F25`. Recent macOS stopped letting third-party apps read the system's Bluetooth records, and the upstream app lost its names with them. This fork reads the name from the device instead.
- **A named first menu line.** The line at the top shows which device controls locking and unlocking, next to its signal reading. Before, it only showed the reading.
- **Your own labels.** Devices that never report a name, which covers most bands, sensors and beacons, can carry a label you type.
- **Estimated distance.** Each row can show `≈0.5m` beside the dBm reading, from a reference value you calibrate once.
- **A sorted list.** Opening **Device** orders the list by signal strength, strongest first.
- **Current Apple hardware.** The model table went from 163 entries to 258, so a model code like `iPhone18,4` reads as `iPhone Air`.
- **A build that works on modern Xcode.** The deployment target moved from 10.13 to 12.0, which is the lowest Xcode 27 accepts.

## Requirements

- A Mac with Bluetooth Low Energy support
- macOS 12 (Monterey) or later
- iPhone 5s or newer, Apple Watch (all models), or another BLE device that transmits periodically from a [static MAC address](#address-stability-and-device-names)

## Install

### Homebrew

```
brew tap xileepapa/tap
brew install --cask xileepapa/tap/bleunlock
```

Keep the `xileepapa/tap/` prefix. Plain `bleunlock` resolves to the upstream build in Homebrew's own tap.

Both casks install `/Applications/BLEUnlock.app`. Uninstall the one you are not keeping first, so Homebrew does not find an app it did not install:

```
brew uninstall --cask bleunlock
```

### Download

Download `BLEUnlock-1.13.0.zip` from [Releases](https://github.com/XiLeePapa/BLEUnlock/releases), unzip it, and move `BLEUnlock.app` to `/Applications`.

This build is signed ad-hoc and not notarized. `spctl --assess` rejects it, so macOS blocks the first launch. Open **System Settings → Privacy & Security** and approve BLEUnlock there, then start the app. Later launches need no approval.

To skip that step, build the app yourself. Gatekeeper leaves locally built apps alone. See [Build from source](#build-from-source).

## Set up

The first launch asks for several permissions. BLEUnlock cannot do its job without the first three:

| Permission | Why you need to grant it |
|-----|--------|
| Bluetooth | Scanning for devices. |
| Accessibility | Typing your password at the lock screen. Turn BLEUnlock on in **System Settings → Privacy & Security → Accessibility**. |
| Keychain | Reading the stored password while the screen is locked. Choose **Always Allow**, or the prompt blocks the unlock. |
| Notifications | Optional. BLEUnlock posts a banner when it locks the screen, which tells you why the Mac just locked. To see it on the lock screen, set **Show previews** to **Always** for BLEUnlock. |

Older macOS versions ask for fewer of these. macOS ties each grant to the app's code signature, so a build signed with a different certificate can ask you again. Replacing the upstream app with this fork is one such case.

BLEUnlock then asks for your login password and stores it in the Keychain. Skip it by setting **Unlock RSSI** to **Disable**, if you only want automatic locking.

To pick your device:

1. Click the menu bar icon, then click **Device**.
2. Wait for the list to fill up. Your device appears as its name, with its MAC address when the app can resolve one.
3. Click your device. It gets a check mark, and the first menu line starts showing its signal reading.
4. Set **Unlock RSSI**, **Lock RSSI**, and **Delay to Lock**. Start from the reading you see when the device is in your pocket and when it is across the room.

## Options

| Option | Description |
|-------|-------------|
| Lock Screen Now | Locks the screen even if the device is nearby. It unlocks again once the device moves away and comes back. Useful before you leave your seat. |
| Unlock RSSI | Signal strength needed to unlock. A larger value means the device has to be closer. Choose **Disable** to never unlock automatically. |
| Lock RSSI | Signal strength that counts as away. A smaller value means the device has to be farther away before locking. Choose **Disable** to never lock automatically. |
| Delay to Lock | How long the device has to be away before the Mac locks. If the device comes back within that time, nothing happens. |
| No-Signal Timeout | How long BLEUnlock waits between the last signal and locking. Raise it if "Signal is lost" locks happen too often. |
| Wake on Proximity | Wakes the display from sleep when the device approaches while the screen is locked. |
| Wake without Unlocking | BLEUnlock does not unlock when the display wakes, whether **Wake on Proximity** woke it or you did. Use it with the built-in Apple Watch unlock, or if you want the lock screen to appear sooner. |
| Pause "Now Playing" while Locked | Pauses and resumes the music or video that the **Now Playing** widget or the ⏯ key controls, on lock and unlock. |
| Use Screensaver to Lock | Starts the screensaver instead of locking. Set **Require password immediately after sleep or screen saver begins** in **System Settings → Privacy & Security** so the screensaver really locks the session. |
| Turn Off Screen on Lock | Turns the display off as soon as it locks. |
| Set Password… | Stores a new login password, after you change it. |
| Passive Mode | Reads the signal from advertisements only, and never connects to the device. The default mode connects and reads the signal directly, which is steadier. Turn on Passive Mode if a Bluetooth keyboard, mouse, trackpad, or Personal Hotspot misbehaves. 2.4 GHz Wi-Fi can cause the same interference. |
| Launch at Login | Starts BLEUnlock when you log in. |
| Set Minimum RSSI | Hides devices weaker than this value from the scan list. |
| Show Estimated Distance | Adds a distance to each device, such as `q phone (-52dBm ≈0.5m)`. The distance comes from the signal reading, so treat it as a guide. Thresholds stay in dBm. |
| Set 1m Reference RSSI… | The signal a device shows at exactly one meter, used only for the estimate. Typical values are -50 to -70 dBm. Raising it makes estimates larger, lowering it makes them smaller. iBeacons carry this value themselves and ignore the setting. |
| Rename Selected Device… | Labels the selected device with a name you choose, shown in the list and on the first menu line. Leave the field empty to go back to the name the device reports. |

## Troubleshooting

### The name of a device did not update

macOS caches the name a Bluetooth device reports. Renaming an iPhone under **Settings → General → About** does not reach the Mac just because BLEUnlock rescans. The app reads the same cached value each time. Turn Bluetooth off and on again, on the iPhone or on the Mac, and wait for the device to reappear. If the old name sticks, label it yourself with **Rename Selected Device…**.

### My device shows a UUID

BLEUnlock picks the first label it can find, in this order:

1. The name you set with **Rename Selected Device…**
2. The name CoreBluetooth reports for the device
3. The name macOS 12 and older recorded for it
4. The Local Name in the device's advertisement
5. The model the device reports over GATT, translated through `BLEUnlock/appleDeviceNames.swift`
6. An iBeacon label, for beacons that carry a proximity UUID
7. The MAC address
8. The CoreBluetooth UUID

A name of just `iPhone` or `iPad` counts as no name, so step 5 gets its chance first. A row that ends at the UUID told the app nothing it could use, so give it your own label with **Rename Selected Device…**.

Labels are stored per CoreBluetooth device identifier, which stays put while the device keeps its address. A device that rotates a private address looks like a new device, so it needs a new label. See [Address stability and device names](#address-stability-and-device-names).

If your device is a non-Apple product that does not advertise a name, BLEUnlock cannot know what it is. Move it closer to and farther from the Mac and watch which row's dBm value follows.

### I don't see any device at all

Reset the Bluetooth module. Hold Shift and Option and click the Bluetooth icon in the menu bar, then click **Reset the Bluetooth module**.

macOS 12 (Monterey) removed that item. Run this instead, and enter your login password:

```
sudo pkill bluetoothd
```

If the list stays empty, turn on **Passive Mode**.

### It fails to unlock

Turn BLEUnlock off and on again in **System Settings → Privacy & Security → Accessibility**. Turning it off and on again fixes a grant that macOS stopped trusting.

If it asks to read its own password in the Keychain, choose **Always Allow**. The screen is locked at that moment, so nobody can answer a prompt.

### "Signal is lost" occurs frequently

Raise **No-Signal Timeout**, or turn on **Passive Mode**.

### My Bluetooth keyboard, mouse, or Personal Hotspot went nuts

Reset the Bluetooth module as described above, then turn on **Passive Mode**. The default mode holds a connection to your device, and that connection competes with other Bluetooth traffic.

### Launchpad shows two BLEUnlock icons

Two copies of the app exist on disk, usually one in `/Applications` and one under `build/dd`. Running `make build` removes the built copy for this reason. To fix a leftover, delete the copy under `build/dd` and relaunch from `/Applications`.

## Run a script on lock and unlock

On lock and unlock, BLEUnlock runs this script:

```
~/Library/Application Scripts/jp.sone.BLEUnlock/event
```

It passes the event type as the first argument:

| Event | Argument |
|-----|--------|
| Locked because the signal dropped below **Lock RSSI** | `away` |
| Locked because no signal arrived within **No-Signal Timeout** | `lost` |
| Unlocked by BLEUnlock | `unlocked` |
| Unlocked by hand | `intruded` |

For `intruded` to work, set **Require password immediately after sleep** in **System Settings → Privacy & Security**.

### Example

This script sends a LINE Notify message, with a photo of whoever unlocked the Mac by hand:

```sh
#!/bin/bash

set -eo pipefail

LINE_TOKEN=xxxxx

notify() {
    local message=$1
    local image=$2
    if [ "$image" ]; then
        img_arg="-F imageFile=@$image"
    else
        img_arg=""
    fi
    curl -X POST -H "Authorization: Bearer $LINE_TOKEN" -F "message=$message" \
        $img_arg https://notify-api.line.me/api/notify
}

capture() {
    open -Wa SnapshotUnlocker
    ls -t /tmp/unlock-*.jpg | head -1
}

case $1 in
    away)
        notify "$(hostname -s) is locked by BLEUnlock because iPhone is away."
        ;;
    lost)
        notify "$(hostname -s) is locked by BLEUnlock because signal is lost."
        ;;
    unlocked)
        #notify "$(hostname -s) is unlocked by BLEUnlock."
        ;;
    intruded)
        notify "$(hostname -s) is manually unlocked." $(capture)
        ;;
esac
```

`SnapshotUnlocker` is an app made in Script Editor from this line:

```
do shell script "/usr/local/bin/ffmpeg -f avfoundation -r 30 -i 0 -frames:v 1 -y /tmp/unlock-$(date +%Y%m%d_%H%M%S).jpg"
```

The extra app exists because BLEUnlock has no Camera permission. Granting permission to `SnapshotUnlocker` gets around that.

## Address stability and device names

Unlike classic Bluetooth, BLE devices can use a private MAC address, and that address can be random and change over time. Phones, both iPhone and Android, now rotate such addresses every 15 minutes or so, to make tracking harder.

BLEUnlock can only track a device whose address stays put, because it follows the signal of one specific radio. On Apple devices signed in to the same Apple ID as the Mac, the address resolves to the true public one. For other vendors there is no way to resolve it, so a device that rotates its address cannot be supported.

To check whether an address resolves, compare the MAC address in the BLEUnlock **Device** list with the one your device shows.

Names come from the same source as the address, which is why they broke. Through macOS 12, BLEUnlock read names from the system's own Bluetooth records: the SQLite databases under `/Library/Bluetooth`, and the caches in `/Library/Preferences/com.apple.Bluetooth.plist`. Recent macOS either keeps those from third-party apps or stopped writing them. So the app asks the device instead. CoreBluetooth reports the name the device uses for itself, which on an iPhone is what you set under **Settings → General → About**. A device that publishes a Local Name in its advertisement is read from there. When both come back empty, the app falls back to the model number GATT exposes, and translates it through `BLEUnlock/appleDeviceNames.swift`.

The distance estimate works the other way, from signal to space. It models the space between the two radios as free space, with a path loss exponent of 2, so every 6 dB of signal lost doubles the estimate. Walls, a pocket, and how you hold the device all move the reading by more than that, which is why the thresholds stay in dBm.

## Build from source

You need Xcode. The Command Line Tools are not enough, because the app compiles `MainMenu.xib` with `ibtool` and `Images.xcassets` with `actool`, and neither ships with them.

```
make build     # compile, then remove the built .app so Launchpad sees only one copy
make deploy    # compile Debug, replace /Applications/BLEUnlock.app, and start it
make clean     # delete build output
```

`make deploy` signs ad-hoc, like the release build, but a locally built app carries no download quarantine, so Gatekeeper never asks about it.

## Publish a release

`make dist` builds the Release configuration with ad-hoc signing, zips it into `dist/`, and prints the sha256 and the exact `gh release create` command. It keeps the new `CFBundleVersion` in `BLEUnlock/Info.plist`, which the project's own build phase increments.

After it runs:

1. Run the printed `gh release create` command. It uploads `dist/BLEUnlock-<version>.zip` under a tag of the form `v<version>-build<number>`.
2. Update `Casks/bleunlock.rb` in [XiLeePapa/homebrew-tap](https://github.com/XiLeePapa/homebrew-tap) with the new `version`, `sha256`, and the build number the URL is built from.
3. Commit `BLEUnlock/Info.plist`, so the build number in the repository matches the one you released.
4. Check the tap from a clean shell:

   ```
   brew update
   brew info --cask xileepapa/tap/bleunlock
   ```

   If Homebrew says the tap is untrusted, run `brew trust xileepapa/tap` first. `brew install` trusts the cask you name, but `brew info` refuses to load an untrusted one.

Homebrew verifies the sha256 on every install, so an unchanged cask with a rebuilt zip fails to install.

To refresh the Apple model table before releasing, run:

```
./apple-device-names > BLEUnlock/appleDeviceNames.swift
```

It reads the CoreTypes bundles of the Mac you run it on, so the table is only as current as that macOS.

## Funding

The annual Apple Developer Program fee is funded by donations. If you like the app, a donation via [Buy Me a Coffee](https://www.buymeacoffee.com/tsone) or [PayPal Me](https://www.paypal.com/paypalme/my/profile) keeps the original author able to maintain it.

## Credits

- [ts1](https://github.com/ts1): the app, and everything not listed below
- [peiit](https://github.com/peiit): Chinese translation
- [wenmin-wu](https://github.com/wenmin-wu): Minimum RSSI and moving average
- [stephengroat](https://github.com/stephengroat): CI
- [joeyhoer](https://github.com/joeyhoer): Homebrew Cask
- [Skyearn](https://github.com/Skyearn): Big Sur style icon
- [cyberclaus](https://github.com/cyberclaus): German, Swedish, Norwegian (Bokmål) and Danish localizations
- [alonewolfx2](https://github.com/alonewolfx2): Turkish localization
- [wernjie](https://github.com/wernjie): Wake without Unlocking
- [tokfrans03](https://github.com/tokfrans03): Language fixes

Icons are based on SVGs from materialdesignicons.com, originally designed by Google LLC under the Apache License version 2.0.

## License

MIT

Copyright © 2019-2022 Takeshi Sone.
