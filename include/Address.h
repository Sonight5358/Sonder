#pragma once

#include <ws2tcpip.h>
#include "SocketError.h"
#include <cstdint>
#include <string>
#include <stdexcept>

inline sockaddr_in MakeAddress(const std::string& ip, uint16_t port)
{
	// Struct with server info
	sockaddr_in addr{};
	addr.sin_family = AF_INET;		// IPv4
	addr.sin_port = htons(port);		// Converts to network byte order

	// Converting string address to binary
	int Result = inet_pton(AF_INET, ip.c_str(), &addr.sin_addr);

	// If converting failed
	if (Result == -1)
	{
		throw SocketError(WSAGetLastError());
	}

	else if (Result == 0)
	{
		throw std::invalid_argument("Incorrect address");
	}

	return addr;
}