#pragma once

#include "Socket.h"
#include "Framing.h"
#include <string>
#include <string_view>
#include <optional>
#include <utility>
#include <mutex>
#include <cstdint>

class Connection
{
private:
	Socket socket;
	std::mutex sendmtx;
	const uint32_t id;

public:
	explicit Connection(Socket&& sock, uint32_t clid) : socket(std::move(sock)), id(clid) {}

	void Send(std::string_view message, MessageType type)
	{	
		std::lock_guard<std::mutex> lock(sendmtx);
		SendPacket(socket, type, message);
	}

	std::optional<Packet> Recv()
	{
		return RecvPacket(socket);
	}

	uint32_t GetId() const
	{
		return id;
	}
};