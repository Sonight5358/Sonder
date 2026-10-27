#pragma once

#include "Socket.h"
#include "Framing.h"
#include <string>
#include <string_view>
#include <optional>
#include <utility>

class Connection
{
private:
	Socket socket;

public:
	explicit Connection(Socket&& sock) : socket(std::move(sock)) {}

	void Send(std::string_view message)
	{
		SendPacket(socket, message);
	}

	std::optional<std::string> Recv()
	{
		return RecvPacket(socket);
	}
};