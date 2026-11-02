#pragma once

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>

using SocketP = SOCKET;
using SocketPLen = int;

inline constexpr SocketP InvalidSocket = INVALID_SOCKET;
inline constexpr int ConnReset = WSAECONNRESET;
inline constexpr int SocketFailed = SOCKET_ERROR;
inline constexpr int ShutBoth = SD_BOTH;
inline constexpr int SendFlags = 0;
inline constexpr int ConnShutdown = WSAESHUTDOWN;

inline int LastSocketError()
{
    return WSAGetLastError();
}
inline int CloseSock(SocketP sock)
{
    return closesocket(sock);
}
	

#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <cerrno>

using SocketP = int;
using SocketPLen = socklen_t;

inline constexpr SocketP InvalidSocket = -1;
inline constexpr int ConnReset = ECONNRESET;
inline constexpr int SocketFailed = -1;
inline constexpr int ShutBoth = SHUT_RDWR;
inline constexpr int SendFlags = MSG_NOSIGNAL;
inline constexpr int ConnShutdown = ESHUTDOWN;

inline int LastSocketError()
{
    return errno;
}
inline int CloseSock(SocketP sock)
{
    return close(sock);
}

#endif