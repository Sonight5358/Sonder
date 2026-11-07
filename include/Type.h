#pragma once

#include <cstdint>
#include <string>
#include <string_view>
#include <optional>
#include <stdexcept>

enum class MessageType : uint8_t
{
	Handshake,  // This type for sending nickname on connection
	CTS,  // For sending text from client to serv
	STC, // For sending text and sender from serv to client
	History // To prevent notifiactions spam from history
};

struct Packet
{
	MessageType type;
	std::string content;
};

struct NickNText
{
	std::string nick;
	std::string text;
};

inline std::string EncodeText(std::string_view nick, std::string_view text)
{
	std::string out;

	if (nick.size() > 255)
	{
		throw std::length_error("Nick is too big");
	}

	uint8_t nicklen = static_cast<uint8_t>(nick.size());

	out += static_cast<char>(nicklen);
	out += nick;
	out += text;

	return out;
}

inline std::optional<NickNText> DecodeText(std::string_view str)
{
	if (str.empty())
	{	
		return std::nullopt;
	}

	uint8_t nicklen = static_cast<uint8_t>(str[0]);
	
	if (str.size() < nicklen + 1)
	{
		return std::nullopt;
	}

	std::string_view nick = str.substr(1, nicklen);
	std::string_view text = str.substr(1 + nicklen);

	NickNText out = { std::string(nick), std::string(text) };

	return out;
}