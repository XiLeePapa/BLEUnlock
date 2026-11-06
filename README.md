# BLEUnlock

BLEUnlock 在你带着 iPhone、Apple Watch 或其他蓝牙低功耗设备离开时锁定 Mac，回来时自动解锁。app 常驻菜单栏，手机端不需要装任何东西。

本仓库是 [ts1/BLEUnlock](https://github.com/ts1/BLEUnlock) 的 fork。保留原版功能，修复近期 macOS 上的问题，并加了几项改进。

![Downloads](https://img.shields.io/github/downloads/XiLeePapa/BLEUnlock/total.svg)
[![Buy me a coffee](img/buymeacoffee.svg)](https://www.buymeacoffee.com/tsone)

本文档也有[日文版](README.ja.md)。

## 这个 fork 改了什么

- **设备列表显示名称。** 你看到的是 `q phone`，不是 `197634CD-E57D-64DE-6DE0-26F579277F25`。近期 macOS 不再允许第三方 app 读取系统蓝牙记录，上游版本因此丢失了设备名。这个 fork 直接从设备获取名称。
- **菜单顶部行显示设备名。** 顶部那行标明哪台设备控制锁定和解锁，旁边是信号读数。之前只显示读数。
- **自定义标签。** 不广播名称的设备（大多数手环、传感器、信标）可以用你输入的名字标记。
- **距离估算。** 每行可以在 dBm 旁边显示 `≈0.5m`，基于你校准一次的参考值计算。
- **按信号排序。** 打开**设备列表**时按信号强度降序排列，最强的在最上面。
- **支持当前 Apple 硬件。** 机型表从 163 条扩充到 258 条，`iPhone18,4` 现在显示为 `iPhone Air`。
- **兼容 Xcode 27。** 部署目标从 10.13 升到 12.0，这是 Xcode 27 接受的最低版本。

## 系统要求

- 支持蓝牙低功耗的 Mac
- macOS 12 (Monterey) 或更高
- iPhone 5s 或更新机型、Apple Watch（所有型号），或其他定期从[静态 MAC 地址](#地址稳定性与设备名称)广播信号的 BLE 设备

## 安装

### Homebrew

```
brew tap xileepapa/tap
brew install --cask xileepapa/tap/bleunlock
```

必须带 `xileepapa/tap/` 前缀。不带前缀的 `bleunlock` 指向 Homebrew 官方 tap 里的上游版本。

两个 cask 都安装到 `/Applications/BLEUnlock.app`。先卸载你不用的那个，否则 Homebrew 会发现一个它没有安装的 app：

```
brew uninstall --cask bleunlock
```

### 手动下载

从 [Releases](https://github.com/XiLeePapa/BLEUnlock/releases) 下载 `BLEUnlock-1.13.0.zip`，解压后把 `BLEUnlock.app` 移到 `/Applications`。

这个构建使用 ad-hoc 签名，没有经过 Apple 公证。`spctl --assess` 会拒绝它，macOS 首次启动时会拦截。打开**系统设置 → 隐私与安全性**，在那里批准 BLEUnlock，然后启动 app。后续启动不再需要批准。

想跳过这一步，自己编译。Gatekeeper 不管本地编译的 app。见[从源码编译](#从源码编译)。

## 首次设置

首次启动会请求以下权限。前三项不授权就无法工作：

| 权限 | 为什么需要 |
|-----|--------|
| 蓝牙 | 扫描设备。 |
| 辅助功能 | 在锁屏界面输入密码。在**系统设置 → 隐私与安全性 → 辅助功能**中打开 BLEUnlock。 |
| 钥匙串 | 锁屏状态下读取存储的密码。选择**始终允许**，否则弹窗会阻塞解锁。 |
| 通知 | 可选。BLEUnlock 锁屏时发一条横幅通知，告诉你 Mac 为什么锁了。要在锁屏上看到通知，把 BLEUnlock 的**显示预览**设为**始终**。 |

旧版 macOS 要求的权限更少。macOS 把每项授权绑定到 app 的代码签名上，所以不同证书签名的构建会重新要求授权。用这个 fork 替换上游版本就属于这种情况。

BLEUnlock 接着会要求你的登录密码并存入钥匙串。如果只需要自动锁定，把**解锁 RSSI** 设为**禁用**即可跳过。

选择你的设备：

1. 点击菜单栏图标，然后点击**设备列表**。
2. 等待列表填充。你的设备会以名称显示，能解析 MAC 地址时还会附带地址。
3. 点击你的设备。它会打上勾，菜单顶部行开始显示信号读数。
4. 设置**解锁 RSSI**、**锁定 RSSI** 和**延迟锁定**。参考设备在口袋里和在房间另一头时的读数来设定。

## 选项

| 选项 | 说明 |
|-------|-------------|
| 立刻锁定屏幕 | 即使设备在附近也锁定屏幕。设备离开再回来后会自动解锁。适合离开座位前确保锁屏。 |
| 解锁 RSSI | 解锁所需的信号强度。值越大，设备需要越近才能解锁。选**禁用**则永不自动解锁。 |
| 锁定 RSSI | 判定为"离开"的信号强度。值越小，设备需要越远才会触发锁定。选**禁用**则永不自动锁定。 |
| 延迟锁定 | 设备离开后多久才锁定 Mac。如果在这段时间内设备回来了，什么都不发生。 |
| 无信号超时 | 最后一次收到信号到锁定之间的等待时间。如果"信号丢失"导致的锁定太频繁，调大这个值。 |
| 靠近唤醒 | 屏幕锁定时，设备靠近会唤醒显示器。 |
| 唤醒时不需解锁 | 显示器唤醒时 BLEUnlock 不执行解锁，无论是**靠近唤醒**触发的还是你手动唤醒的。配合 macOS 内置的 Apple Watch 解锁使用，或者你希望锁屏更快出现但不想自动解锁。 |
| 锁定时暂停"播放中" | 锁定和解锁时暂停和恢复**播放中**控件或 ⏯ 键控制的音乐或视频。 |
| 用屏保来锁定 | 启动屏保而不是锁定。需要在**系统设置 → 隐私与安全性**中设置**进入睡眠或开始屏幕保护程序后立即要求输入密码**，屏保才能真正锁住会话。 |
| 锁定时关闭屏幕 | 锁定时立即关闭显示器。 |
| 设置密码… | 更改登录密码后，用这个重新存储。 |
| 被动模式 | 只从广播包读取信号，不连接设备。默认模式会连接设备并直接读取信号，更稳定。如果蓝牙键盘、鼠标、触控板或个人热点出现异常，打开被动模式。2.4 GHz Wi-Fi 也会造成同样的干扰。 |
| 开机启动 | 登录时自动启动 BLEUnlock。 |
| 设置最小 RSSI | 信号低于此值的设备不出现在扫描列表中。 |
| 显示距离估算 | 在每个设备旁添加距离，如 `q phone (-52dBm ≈0.5m)`。距离由信号读数推算，仅供参考。阈值仍以 dBm 为准。 |
| 设置 1 米参考 RSSI… | 设备在正好一米处的信号值，仅用于距离估算。常见取值 -50 到 -70 dBm。调大（更接近 0）估算距离变大，调小则变小。iBeacon 自带这个值，忽略此设置。 |
| 重命名所选设备… | 给选中的设备起一个名字，显示在列表和菜单顶部行。留空则恢复设备自报的名称。 |

## 故障排除

### 设备名称没有更新

macOS 缓存蓝牙设备报告的名称。在 iPhone 上通过**设置 → 通用 → 关于本机**改名后，Mac 不会因为 BLEUnlock 重新扫描就拿到新名字。app 每次读到的都是同一个缓存值。在 iPhone 或 Mac 上把蓝牙关掉再开，等设备重新出现。如果旧名字仍然不变，用**重命名所选设备…**自己标记。

### 设备显示为 UUID

BLEUnlock 按以下顺序取第一个可用的名称：

1. 你用**重命名所选设备…**设的名字
2. CoreBluetooth 报告的设备名
3. macOS 12 及更早版本记录的名称
4. 设备广播包里的 Local Name
5. 设备通过 GATT 报告的型号，经 `BLEUnlock/appleDeviceNames.swift` 翻译
6. iBeacon 标签（适用于携带 proximity UUID 的信标）
7. MAC 地址
8. CoreBluetooth UUID

名称只有 `iPhone` 或 `iPad` 时视为无名，第 5 步优先。一行最终落到 UUID，说明设备没有提供任何可用信息。用**重命名所选设备…**给它起个名字。

标签按 CoreBluetooth 设备标识符存储，设备保持同一地址期间一直有效。轮换私有地址的设备看起来像新设备，需要重新标记。详见[地址稳定性与设备名称](#地址稳定性与设备名称)。

如果你的设备是非 Apple 产品且不广播名称，BLEUnlock 无法知道它是什么。把设备靠近和远离 Mac，观察哪一行的 dBm 值跟着变化。

### 列表里看不到任何设备

重置蓝牙模块。按住 Shift + Option 点击菜单栏的蓝牙图标，然后点击**重置蓝牙模块**。

macOS 12 (Monterey) 移除了这个选项。改用以下命令，输入登录密码：

```
sudo pkill bluetoothd
```

如果列表仍然为空，打开**被动模式**。

### 无法解锁

在**系统设置 → 隐私与安全性 → 辅助功能**中把 BLEUnlock 关掉再开。重新开关可以修复 macOS 不再信任的授权。

如果弹出钥匙串访问请求，选择**始终允许**。此时屏幕已锁定，没有人能应答弹窗。

### "信号丢失"频繁出现

调大**无信号超时**，或打开**被动模式**。

### 蓝牙键盘、鼠标或个人热点异常

按上面的方法重置蓝牙模块，然后打开**被动模式**。默认模式会保持与设备的连接，这个连接会和其他蓝牙流量竞争资源。

### Launchpad 显示两个 BLEUnlock 图标

磁盘上有两份 app，通常一份在 `/Applications`，一份在 `build/dd`。`make build` 会自动删除构建产物以避免这个问题。要修复残留，删掉 `build/dd` 下的副本，从 `/Applications` 重新启动。

## 锁定和解锁时运行脚本

锁定和解锁时，BLEUnlock 运行这个脚本：

```
~/Library/Application Scripts/jp.sone.BLEUnlock/event
```

第一个参数是事件类型：

| 事件 | 参数 |
|-----|--------|
| 信号低于**锁定 RSSI** 导致锁定 | `away` |
| **无信号超时**内未收到信号导致锁定 | `lost` |
| BLEUnlock 自动解锁 | `unlocked` |
| 手动解锁 | `intruded` |

要让 `intruded` 正常工作，在**系统设置 → 隐私与安全性**中设置**进入睡眠后立即要求输入密码**。

### 示例

这个脚本发送 LINE Notify 消息，手动解锁时附带一张 Mac 前置摄像头拍的照片：

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

`SnapshotUnlocker` 是用 Script Editor 从这个脚本创建的 app：

```
do shell script "/usr/local/bin/ffmpeg -f avfoundation -r 30 -i 0 -frames:v 1 -y /tmp/unlock-$(date +%Y%m%d_%H%M%S).jpg"
```

需要这个额外的 app 是因为 BLEUnlock 没有摄像头权限。把权限授给 `SnapshotUnlocker` 就能绕过这个限制。

## 地址稳定性与设备名称

与传统蓝牙不同，BLE 设备可以使用私有 MAC 地址，这个地址可以是随机的，而且会随时间变化。iPhone 和 Android 手机现在大约每 15 分钟轮换一次私有地址，目的是防止追踪。

BLEUnlock 只能跟踪地址不变的设备，因为它跟踪的是某一台特定射频的信号。登录了与 Mac 相同 Apple ID 的 Apple 设备，地址会被解析为真实的公开地址。其他厂商没有已知的解析方法，所以轮换地址的设备无法支持。

要检查地址是否正确解析，把 BLEUnlock **设备列表**中显示的 MAC 地址和你设备上显示的对比。

名称和地址来自同一个来源，这就是名称失效的原因。macOS 12 及更早版本中，BLEUnlock 从系统的蓝牙记录读取名称：`/Library/Bluetooth` 下的 SQLite 数据库，以及 `/Library/Preferences/com.apple.Bluetooth.plist` 中的缓存。近期 macOS 要么阻止第三方 app 访问这些文件，要么不再写入。所以 app 改为直接向设备询问。CoreBluetooth 报告设备自身的名称，在 iPhone 上就是你在**设置 → 通用 → 关于本机**里设的名字。在广播包里发布 Local Name 的设备从那里读取。两者都为空时，app 回退到 GATT 暴露的型号编号，通过 `BLEUnlock/appleDeviceNames.swift` 翻译。

距离估算反过来，从信号推算空间。它把两台射频之间的空间建模为自由空间，路径损耗指数为 2，所以信号每损失 6 dB，估算距离翻倍。墙壁、口袋、手持姿势对读数的影响都超过这个量级，所以阈值仍以 dBm 为准。

## 从源码编译

需要 Xcode。Command Line Tools 不够，因为 app 要用 `ibtool` 编译 `MainMenu.xib`，用 `actool` 编译 `Images.xcassets`，这两个工具不随 Command Line Tools 分发。

```
make build     # 编译，然后删除构建出的 .app，避免 Launchpad 出现重复图标
make deploy    # 编译 Debug 版本，替换 /Applications/BLEUnlock.app，然后启动
make clean     # 删除构建产物
```

`make deploy` 使用 ad-hoc 签名，和 Release 构建一样，但本地编译的 app 没有下载隔离标记，Gatekeeper 不会拦截。

## 发布新版本

`make dist` 用 ad-hoc 签名编译 Release 配置，打包到 `dist/`，打印 sha256 和完整的 `gh release create` 命令。它保留 `BLEUnlock/Info.plist` 中新的 `CFBundleVersion`，这个值由工程自带的构建阶段自增。

运行后：

1. 执行打印出的 `gh release create` 命令。它把 `dist/BLEUnlock-<version>.zip` 上传到形如 `v<version>-build<number>` 的 tag 下。
2. 更新 [XiLeePapa/homebrew-tap](https://github.com/XiLeePapa/homebrew-tap) 中 `Casks/bleunlock.rb` 的 `version`、`sha256` 和 URL 中的 build number。
3. 提交 `BLEUnlock/Info.plist`，让仓库里的 build number 和你发布的版本一致。
4. 在新 shell 中验证 tap：

   ```
   brew update
   brew info --cask xileepapa/tap/bleunlock
   ```

   如果 Homebrew 提示 tap 不受信任，先运行 `brew trust xileepapa/tap`。`brew install` 会为你指定的 cask 记录信任，但 `brew info` 拒绝加载不受信任的 tap。

Homebrew 每次安装都校验 sha256，所以 cask 没改但 zip 重新打包会导致安装失败。

发布前刷新 Apple 机型表：

```
./apple-device-names > BLEUnlock/appleDeviceNames.swift
```

它读取你运行它的 Mac 上的 CoreTypes bundle，所以表的时效取决于那台 Mac 的 macOS 版本。

## 赞助

Apple Developer Program 年费靠捐赠维持。如果你喜欢这个 app，可以通过 [Buy Me a Coffee](https://www.buymeacoffee.com/tsone) 或 [PayPal Me](https://www.paypal.com/paypalme/my/profile) 捐赠，帮助原作者继续维护。

## 致谢

- [ts1](https://github.com/ts1)：app 本身，以及下面未列出的所有内容
- [peiit](https://github.com/peiit)：中文翻译
- [wenmin-wu](https://github.com/wenmin-wu)：最小 RSSI 和移动平均
- [stephengroat](https://github.com/stephengroat)：CI
- [joeyhoer](https://github.com/joeyhoer)：Homebrew Cask
- [Skyearn](https://github.com/Skyearn)：Big Sur 风格图标
- [cyberclaus](https://github.com/cyberclaus)：德语、瑞典语、挪威语（书面语）和丹麦语本地化
- [alonewolfx2](https://github.com/alonewolfx2)：土耳其语本地化
- [wernjie](https://github.com/wernjie)：唤醒时不需解锁
- [tokfrans03](https://github.com/tokfrans03)：语言修正

图标基于 materialdesignicons.com 的 SVG，由 Google LLC 设计，Apache License 2.0 许可。

## 许可证

MIT

Copyright © 2019-2022 Takeshi Sone.
