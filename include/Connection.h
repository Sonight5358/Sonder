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

	void Send(std::string_view message)
	{	
		std::lock_guard<std::mutex> lock(sendmtx);
		SendPacket(socket, message);
	}

	std::optional<std::string> Recv()
	{
		return RecvPacket(socket);
	}
};