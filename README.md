# Sonder

Sonder is a work-in-progress TCP chat application built to practice C++, Windows API, CMake, and Qt Quick/QML.

## Features

- Socket wrapper for IPv4
- Plain TCP over Winsock2 / POSIX sockets, no third-party dependencies (for console)
- Multithreaded message receiving
- CMake-based build system
- Qt/QML GUI
- Multiple clients at once
- Nicknames
- Message history
- Notifications in tray
- Framing with packet length, packet types, handshake with protocol version
- Linux compatible server in Docker container

## Requirements

- **OS:** Windows (links against `ws2_32`) or Linux (except gui)
- **Compiler:** MSVC, GCC, Clang
- **CMake:** 3.20 or newer
- **Qt:** Qt 6.10+ for GUI (modules: Quick, Widgets, Multimedia, Lottie)

## Build

```bash
git clone https://github.com/Sonight5358/Sonder.git
cd Sonder
cmake -S . -B build -DSONDER_BUILD_GUI=OFF
cmake --build build --config Release
```

## Usage

1. Start the server first:

   ```bash
   ./TCPServer
   ```

2. In another terminal, start the client:

   ```bash
   ./TCPClient
   ```
3. Or gui client:

   - Open the root CMakeLists.txt in Qt Creator
   ```bash
   ./Release/TCPChatClientQt/Sonder.exe
   ```

## Server in Docker

1. Clone repository on your server

   ```bash
   git clone https://github.com/Sonight5358/Sonder.git
   cd Sonder
   ```

2. Build the image and run the container

   ```bash
   docker build -t sonder-server .
   docker run -d --restart unless-stopped -p 5358:5358 --name sonder sonder-server
   ```

3. To update server

   ```bash
   git pull
   docker build -t sonder-server .
   docker rm -f sonder
   docker run -d --restart unless-stopped -p 5358:5358 --name sonder sonder-server
   ```

## Roadmap

- Photo, audio and video
- Timestamps
- Linux support for gui
- Avatars
- Selfhosted servers via containers
- Encryption
- Custom installer

## Resources

- [Microsoft Winsock documentation](https://learn.microsoft.com/en-us/windows/win32/winsock/windows-sockets-start-page-2)
- [CMake documentation](https://cmake.org/cmake/help/latest/)
- [Qt Quick documentation](https://doc.qt.io/qt-6/qtquick-index.html)

## License

Copyright (C) 2026 Sonight5358

Sonder is licensed under the [GNU Affero General Public License v3.0](LICENSE).
If you run a modified version of the server for other users, you must make your source code available to them.

Third-party components:

- [Qt](https://www.qt.io/) - the GUI uses Qt under LGPLv3; the Qt Lottie Animation and Qt Quick Timeline modules are GPLv3, see [licenses/Qt-LICENSE.txt](licenses/Qt-LICENSE.txt)
- [Lucide](https://lucide.dev/) icons - ISC License, see [licenses/lucide-LICENSE.txt](licenses/lucide-LICENSE.txt)