#include "Socket.h"

Socket::Socket(int af, int type, int protocol)
{
	SocketDesc = socket(af, type, protocol);

	// If socket was not created
	if (SocketDesc == INVALID_SOCKET)
	{
		throw SocketError(WSAGetLastError());
	}
}

// Constructor for already existing socket descriptor
Socket::Socket(SOCKET createsock) : SocketDesc(createsock) {}

// Move constructor
Socket::Socket(Socket&& other) noexcept
{	
	SocketDesc = other.SocketDesc;
	other.SocketDesc = INVALID_SOCKET;
}

// Move asingment
Socket& Socket::operator = (Socket&& other) noexcept
{
	if (this != &other)
	{
		if (SocketDesc != INVALID_SOCKET)
		{
			closesocket(SocketDesc);
		}

		SocketDesc = other.SocketDesc;
		other.SocketDesc = INVALID_SOCKET;
	}

	return *this;
}

// Destructor
Socket::~Socket()
{
	closesocket(SocketDesc);
}

// Bind Ip and port with this exact socket (IPv4)
void Socket::Bind(const sockaddr_in& name) // Struct with server info
{
	// If binding failed
	if (bind(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SOCKET_ERROR)
	{
		throw SocketError(WSAGetLastError());
	}
}

// Bind Ip and port with this exact socket (IPv6)
void Socket::Bind(const sockaddr_in6& name) // Struct with server info
{
	// If binding failed
	if (bind(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SOCKET_ERROR)
	{
		throw SocketError(WSAGetLastError());
	}
}

// Listening
void Socket::Listen(int backlog)
{
	// If listening failed
	if (listen(SocketDesc, backlog) == SOCKET_ERROR) // Socket descriptor, max length of pending connection queue)
	{
		throw SocketError(WSAGetLastError());
	}
}

// Accept (IPv4)
Socket Socket::Accept(sockaddr_in& name)
{
	int addrlen = sizeof(name);

	// New socket class
	SOCKET newsock = INVALID_SOCKET;

	newsock = accept(SocketDesc, reinterpret_cast<sockaddr*>(&name), &addrlen);

	// If not accepted
	if (newsock == INVALID_SOCKET)
	{
		throw SocketError(WSAGetLastError());
	}

	/*Socket sock(newsock);
	return sock;*/
	
	return Socket(newsock);

}

// Accept (IPv6)
Socket Socket::Accept(sockaddr_in6& name)
{
	int addrlen = sizeof(name);

	// New socket class
	SOCKET newsock = INVALID_SOCKET;

	newsock = accept(SocketDesc, reinterpret_cast<sockaddr*>(&name), &addrlen);

	// If not accepted
	if (newsock == INVALID_SOCKET)
	{
		throw SocketError(WSAGetLastError());
	}

	/*Socket sock(newsock);
	return sock;*/

	return Socket(newsock);
}

// Connect (IPv4)
void Socket::Connect(const sockaddr_in& name)
{
	// If connection failed
	if (connect(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SOCKET_ERROR)
	{
		throw SocketError(WSAGetLastError());
	}
}

// Connect (IPv6)
void Socket::Connect(const sockaddr_in6& name)
{
	// If connection failed
	if (connect(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SOCKET_ERROR)
	{
		throw SocketError(WSAGetLastError());
	}
}

// Send message
int Socket::Send(const char* buf, int flag)
{	
	int total = strlen(buf);
	int sent = 0;

	while (sent < total)
	{	
		int sentBytes = send(SocketDesc, buf + sent, total - sent, flag);

		// If cant send
		if (sentBytes == SOCKET_ERROR)
		{
			throw SocketError(WSAGetLastError());
		}

		sent += sentBytes;
	}

	return sent;
}

// Receive in a template in .h

// Shutdown
int Socket::Shutdown(int how)
{	
	int Result = shutdown(SocketDesc, how);

	// If shutdown failed
	if (Result == SOCKET_ERROR)
	{
		throw SocketError(WSAGetLastError());
	}

	return Result;
}

// Receive entire package
bool Socket::RecvAll(char* buf, int len)
{
	int received = 0;

	while (received < len)
	{
		int Result = recv(SocketDesc, buf + received, len - received, 0);

		// If receive failed
		if (Result == SOCKET_ERROR)
		{
			throw SocketError(WSAGetLastError());
		}

		if (Result == 0)
		{
			return false;
		}
		
		received += Result;
	}

	return true;
}

// Send entire package
void Socket::SendAll(const char* buf, int len)
{
	int sent = 0;

	while (sent < len)
	{
		int sentBytes = send(SocketDesc, buf + sent, len - sent, 0);

		// If cant send
		if (sentBytes == SOCKET_ERROR)
		{
			throw SocketError(WSAGetLastError());
		}

		sent += sentBytes;
	}
}