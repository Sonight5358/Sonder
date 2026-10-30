#pragma once

#include "Socket.h"
#include <string>
#include <string_view>
#include <cstdint>
#include <stdexcept>
#include <optional>

inline constexpr size_t MaxNameLen = 32;
inline constexpr uint32_t maxMessageSize = 64 * 1024; // 64kb

inline void SendPacket(Socket& socket, std::string_view message)
{
	uint32_t len = static_cast<uint32_t>(message.size());

	if (maxMessageSize < len)
	{
		throw std::length_error("Message length is too big");
	}

	uint32_t netLen = htonl(len);
	
	socket.SendAll(reinterpret_cast<const char*>(&netLen), sizeof(netLen)); // Header
	socket.SendAll(message.data(), len); // Message
}

inline std::optional<std::string> RecvPacket(Socket& socket)
{
	uint32_t netLen;

	bool Result = socket.RecvAll(reinterpret_cast<char*>(&netLen), sizeof(netLen)); // Header

	if (Result == false)
	{
		return std::nullopt;
	}

	uint32_t len = ntohl(netLen);

	if (maxMessageSize < len)
	{
		throw std::length_error("Message length is too big");
	}

	std::string message(len, '\0');

	Result = socket.RecvAll(message.data(), static_cast<int>(len)); // Message

	if (Result == false)
	{
		return std::nullopt;
	}

	return message;
}