#pragma once

#include "Socket.h"
#include "Framing.h"
#include <string>
#include <string_view>
#include <optional>
#include <utility>
#include <mutex>

class Connection
{
private:
	Socket socket;
	std::mutex sendmtx;

public:
	explicit Connection(Socket&& sock) : socket(std::move(sock)) {}

	void Send(std::string_view message, MessageType type)
	{	
		std::lock_guard<std::mutex> lock(sendmtx);
		SendPacket(socket, type, message);
	}

	std::optional<Packet> Recv()
	{
		return RecvPacket(socket);
	}
};