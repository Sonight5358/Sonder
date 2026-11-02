#include "Socket.h"

Socket::Socket() : Socket(AF_INET, SOCK_STREAM, 0) {}

Socket::Socket(int af, int type, int protocol)
{
	SocketDesc = socket(af, type, protocol);

	// If socket was not created
	if (SocketDesc == InvalidSocket)
	{
		throw SocketError(LastSocketError());
	}
}

// Constructor for already existing socket descriptor
Socket::Socket(SocketP createsock) : SocketDesc(createsock) {}

// Move constructor
Socket::Socket(Socket&& other) noexcept
{	
	SocketDesc = other.SocketDesc;
	other.SocketDesc = InvalidSocket;
}

// Move asingment
Socket& Socket::operator = (Socket&& other) noexcept
{
	if (this != &other)
	{
		if (SocketDesc != InvalidSocket)
		{
			CloseSock(SocketDesc);
		}

		SocketDesc = other.SocketDesc;
		other.SocketDesc = InvalidSocket;
	}

	return *this;
}

// Destructor
Socket::~Socket()
{	
	if (SocketDesc != InvalidSocket)
	{
		CloseSock(SocketDesc);
	}
}

// Options
void Socket::SetSocketOption(int level, int optname, int optvalue)
{
	if (setsockopt(SocketDesc, level, optname, reinterpret_cast<const char*>(&optvalue), sizeof(optvalue)) == SocketFailed)
	{
		throw SocketError(LastSocketError());
	}
}

// Bind Ip and port with this exact socket (IPv4)
void Socket::Bind(const sockaddr_in& name) // Struct with server info
{
	// If binding failed
	if (bind(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SocketFailed)
	{
		throw SocketError(LastSocketError());
	}
}

// Bind Ip and port with this exact socket (IPv6)
void Socket::Bind(const sockaddr_in6& name) // Struct with server info
{	
	// If binding failed
	if (bind(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SocketFailed)
	{
		throw SocketError(LastSocketError());
	}
}

// Listening
void Socket::Listen(int backlog)
{
	// If listening failed
	if (listen(SocketDesc, backlog) == SocketFailed) // Socket descriptor, max length of pending connection queue)
	{
		throw SocketError(LastSocketError());
	}
}

// Accept (IPv4)
Socket Socket::Accept(sockaddr_in& name)
{
	SocketPLen addrlen = sizeof(name);

	// New socket class
	SocketP newsock = InvalidSocket;

	newsock = accept(SocketDesc, reinterpret_cast<sockaddr*>(&name), &addrlen);

	// If not accepted
	if (newsock == InvalidSocket)
	{
		throw SocketError(LastSocketError());
	}

	/*Socket sock(newsock);
	return sock;*/
	
	return Socket(newsock);

}

// Accept (IPv6)
Socket Socket::Accept(sockaddr_in6& name)
{
	SocketPLen addrlen = sizeof(name);

	// New socket class
	SocketP newsock = InvalidSocket;

	newsock = accept(SocketDesc, reinterpret_cast<sockaddr*>(&name), &addrlen);

	// If not accepted
	if (newsock == InvalidSocket)
	{
		throw SocketError(LastSocketError());
	}

	/*Socket sock(newsock);
	return sock;*/

	return Socket(newsock);
}

// Connect (IPv4)
void Socket::Connect(const sockaddr_in& name)
{
	// If connection failed
	if (connect(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SocketFailed)
	{
		throw SocketError(LastSocketError());
	}
}

// Connect (IPv6)
void Socket::Connect(const sockaddr_in6& name)
{
	// If connection failed
	if (connect(SocketDesc, reinterpret_cast<const sockaddr*>(&name), sizeof(name)) == SocketFailed)
	{
		throw SocketError(LastSocketError());
	}
}

// Shutdown
int Socket::Shutdown(int how)
{	
	int Result = shutdown(SocketDesc, how);

	// If shutdown failed
	if (Result == SocketFailed)
	{
		throw SocketError(LastSocketError());
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
		if (Result == SocketFailed)
		{
			throw SocketError(LastSocketError());
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
		int sentBytes = send(SocketDesc, buf + sent, len - sent, SendFlags);

		// If cant send
		if (sentBytes == SocketFailed)
		{
			throw SocketError(LastSocketError());
		}

		sent += sentBytes;
	}
}