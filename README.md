# NetMeter

A lightweight, blazing-fast network bandwidth monitor for Windows, built natively in [Zig](https://ziglang.org/).

## 🛑 The Problem: Windows 11 Limitations

For years, power users relied on "Taskbar Deskband" utilities to display real-time network speeds directly on their Windows taskbar. These tools hooked directly into the Windows Shell.

However, **Windows 11 completely removed support for Taskbar Deskbands**. This architectural change broke almost all legacy network monitors, leaving users without a native, unobtrusive way to keep an eye on their internet traffic without keeping Task Manager permanently open.

## 💡 The Solution: How NetMeter Works

Since we can no longer inject code directly into the taskbar, **NetMeter** uses a modern, clever workaround:

1. It creates a completely transparent, click-through overlay window.
2. It automatically tracks the exact position of the Windows System Tray (notification area).
3. It hovers seamlessly *above* the taskbar, perfectly mimicking the look and feel of a native Taskbar Band.

It actively filters out local virtual adapters (like Docker, WSL, or Hyper-V) by querying the Windows routing table, ensuring the speeds you see represent your **true internet bandwidth**, matching Task Manager's 1-second exact polling interval.



## ⚙️ Installation & Requirements

### Why you should build it yourself
This application interacts directly with lower-level Windows APIs. Because this is an open-source project without an expensive Code Signing Certificate, pre-compiled binaries downloaded from the internet will likely trigger Windows SmartScreen or antivirus warnings. 

**For your security and peace of mind, it is highly recommended to build the application yourself.**

### Build Instructions (Recommended)

1. Download and install [Zig](https://ziglang.org/download/) (Version 0.13.0 or later).
2. Clone this repository:
   ```bash
   git clone https://github.com/muhiminulhasan/netmeter-zig.git
   cd netmeter-zig
   ```
3. Build the release binary:
   ```bash
   zig build -Drelease=true
   ```

4. You will find the compiled `.exe` inside the `zig-out/bin/` directory.

### 🚀 Running on Startup

To have NetMeter start automatically when you log in to Windows:

1. Press `Win + R` to open the Run dialog.
2. Type `shell:startup` and press Enter. This opens your Startup folder.
3. Right-click inside the folder, select **New -> Shortcut**.
4. Browse to the location of your compiled `netmeter.exe` and create the shortcut.

*That's it! NetMeter will now launch quietly in your system tray on every boot.*

## 🤝 Contributing

Contributions are more than welcome! Whether it's fixing bugs, improving the Zig codebase, or adding new UI features (like custom fonts or colors), please feel free to fork the repository and submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**A.S. M. Muhiminul Hasan**  
🌐 [muhiminulhasan.com](https://muhiminulhasan.com)
