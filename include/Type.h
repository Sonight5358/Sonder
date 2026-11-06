#pragma once

#include <cstdint>
#include <string>

enum class MessageType : uint8_t
{
	Handshake,
	Chat
};

struct Packet
{
	MessageType type;
	std::string content;
};