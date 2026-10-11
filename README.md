# Sonder

Sonder is a work-in-progress TCP chat application built to practice C++, Windows API, CMake, and Qt Quick/QML.

## Features

- Socket wrapper for IPv4 and IPv6
- Plain TCP over Winsock2, no third-party dependencies
- Retry mechanism for failed operations
- Multithreaded message receiving
- Graceful connection shutdown with /exit
- CMake-based build system

## Requirements

- **OS:** Windows (links against `ws2_32`)
- **Compiler:** any C++17-capable one (MSVC, MinGW-w64)
- **CMake:** 3.20 or newer

## Build

```bash
git clone https://github.com/Sonight5358/Sonder.git
cd TCP-Socket-chat-on-CPP

cmake -S . -B build
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

## Roadmap

- Qt/QML GUI
- Multiple clients at once
- Nicknames and timestamps
- Linux support (POSIX sockets)

## Resources

[Microsoft Winsock documentation](https://learn.microsoft.com/en-us/windows/win32/winsock/windows-sockets-start-page-2)
[CMake documentation](https://cmake.org/cmake/help/latest/)
[Qt Quick documentation](https://doc.qt.io/qt-6/qtquick-index.html)