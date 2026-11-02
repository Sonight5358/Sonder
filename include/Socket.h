#pragma once

#include <string>

#include "SelectPlatform.h"
#include "SocketError.h"

class Socket
{
private: 
	SocketP SocketDesc = InvalidSocket;

public:
	// New TCP/IPv4 socket
	Socket();

	// New socket with params
	Socket(int af, int type, int protocol = 0);

	// Ownership of an existing descriptor
	explicit Socket(SocketP createsock);

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

	// Options
	void SetSocketOption(int level, int optname, int optvalue);

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

	int Shutdown(int how);

	// Receive entire package
	bool RecvAll(char* buf, int len);

	// Send entire package
	void SendAll(const char* buf, int len);
};