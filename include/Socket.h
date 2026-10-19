#pragma once

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <winsock2.h>
#include <windows.h>

#include <string>
#include <cstring>
#include <ws2tcpip.h>
#include "SocketError.h"

class Socket
{
private: 
	SOCKET SocketDesc = INVALID_SOCKET;

public:
	Socket(int af = AF_INET, int type = SOCK_STREAM, int protocol = 0);

	// Constructor for already existing socket descriptor
	Socket(SOCKET createsock);

	// Move constructor
	Socket(Socket&& other) noexcept;

	// Move asingment
	Socket& operator = (Socket&& other) noexcept;

	// Copy constructor
	Socket(const Socket& other) = delete;

	//Copy asingment
	Socket& operator = (const Socket& other) = delete;

	// Destructor
	~Socket();

	// Bind Ip and port with this exact socket (IPv4)
	void Bind(const sockaddr_in& name); // Struct with server info

	// Bind Ip and port with this exact socket (IPv6)
	void Bind(const sockaddr_in6& name); // Struct with server info

	// Listening
	void Listen(int backlog = SOMAXCONN);

	// Accept (IPv4)
	Socket Accept(sockaddr_in& name);

	// Accept (IPv6)
	Socket Accept(sockaddr_in6& name);

	// Connect (IPv4)
	void Connect(const sockaddr_in& name);

	// Connect (IPv6)
	void Connect(const sockaddr_in6& name);

	// Send message
	int Send(const char* buf, int flag);

	// Receive
	template <size_t T>
	int Recv(char (&buf)[T], int flag)
	{	
		int Result = recv(SocketDesc, buf, T, flag);

		// If receive failed
		if (Result == SOCKET_ERROR)
		{
			throw SocketError(WSAGetLastError());
		}

		return Result;
	}

	int Shutdown(int how);
};