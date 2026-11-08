#pragma once

#include <cstdint>
#include <string>
#include <string_view>
#include <optional>
#include <stdexcept>

inline constexpr uint8_t protocolVer = 3;

enum class MessageType : uint8_t
{
	Handshake,  // This type for sending nickname on connection
	CTS,  // For sending text from client to serv
	STC, // For sending text and sender from serv to client
	History, // To prevent notifiactions spam from history
	Welcome,
	Reject
};

enum class RejectType : uint8_t
{
	OldClient,
	WrongNick
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

struct ProtocolNNick
{
	uint8_t protocol;
	std::string nick;
};

struct ErrorNReject
{
	RejectType code;
	std::string rejection;
};

struct Timestamp
{
	uint64_t time;
	std::string other;
};

struct HistoryMessage
{
	std::string nick;
	std::string text;
	uint64_t timestamp;
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

inline std::string EncodeHandshake(uint8_t prot, std::string_view nick)
{
	std::string out;

	out += static_cast<char>(prot);
	out += nick;

	return out;
}

inline std::optional<ProtocolNNick> DecodeHandshake(std::string_view str)
{
	if (str.empty())
	{
		return std::nullopt;
	}

	uint8_t protoc = static_cast<uint8_t>(str[0]);
	std::string_view nick = str.substr(1);

	ProtocolNNick out = { protoc, std::string(nick)};

	return out;
}

inline std::string EncodeReject(RejectType code, std::string_view rejection)
{
	std::string out;

	out += static_cast<char>(code);
	out += rejection;

	return out;
}

inline std::optional<ErrorNReject> DecodeReject(std::string_view str)
{
	if (str.empty())
	{
		return std::nullopt;
	}
	
	uint8_t raw = static_cast<uint8_t>(str[0]);

	if (raw > static_cast<uint8_t>(RejectType::WrongNick))
	{
		return std::nullopt;
	}

	RejectType code = static_cast<RejectType>(raw);

	std::string_view rejection = str.substr(1);

	ErrorNReject out = { code, std::string(rejection) };

	return out;
}

inline std::string EncodeTimestamp(uint64_t time, std::string_view other)
{
	std::string out;

	for (int i = 56; i >= 0; i -= 8)
	{
		out += static_cast<char>((time >> i) & 0xFF); // (time / 256 ^ (i / 8)) % 256
	}

	out += other;

	return out;
}

inline std::optional<Timestamp> DecodeTimestamp(std::string_view str)
{
	if (str.size() < 8)
	{
		return std::nullopt;
	}

	uint64_t time = 0;

	for (int i = 0; i < 8; ++i)
	{
		time += static_cast<uint64_t>(static_cast<uint8_t>(str[7 - i])) << (i * 8);
	}
	
	std::string_view other = str.substr(8);

	Timestamp out = { time, std::string(other) };

	return out;
}

inline std::optional<HistoryMessage> DecodeHistory(std::string_view str)
{
	std::optional<Timestamp> timeDec = DecodeTimestamp(str);

	if (!timeDec)
	{
		return std::nullopt;
	}

	std::optional<NickNText> otherNNT = DecodeText(timeDec->other);
	
	if (!otherNNT)
	{
		return std::nullopt;
	}

	HistoryMessage out = { std::move(otherNNT->nick), std::move(otherNNT->text), timeDec->time };

	return out;
}