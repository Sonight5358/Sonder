#pragma once

#include "Socket.h"
#include "Type.h"
#include <string>
#include <string_view>
#include <cstdint>
#include <stdexcept>
#include <optional>

inline constexpr size_t MaxNameLen = 128; // bytes
inline constexpr uint32_t maxMessageSize = 64 * 1024; // 64kb

inline void SendPacket(Socket& socket, MessageType type, std::string_view message)
{	
	uint32_t len = static_cast<uint32_t>(message.size() + 1); // +1 for the type

	if (maxMessageSize < len)
	{
		throw std::length_error("Message length is too big");
	}

	uint32_t netLen = htonl(len);
	
	socket.SendAll(reinterpret_cast<const char*>(&netLen), sizeof(netLen)); // Header
	socket.SendAll(reinterpret_cast<const char*>(&type), sizeof(type)); // Type
	socket.SendAll(message.data(), message.size()); // Message
}

inline std::optional<Packet> RecvPacket(Socket& socket)
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

	if (len < 1)
	{
		throw std::length_error("Message length is too small");
	}

	Packet packet;

	Result = socket.RecvAll(reinterpret_cast<char*>(&packet.type), sizeof(packet.type)); // Type

	if (Result == false)
	{
		return std::nullopt;
	}

	std::string message(len - 1, '\0');

	Result = socket.RecvAll(message.data(), static_cast<int>(len - 1)); // Message

	if (Result == false)
	{
		return std::nullopt;
	}

	packet.content = std::move(message);

	return packet;
}