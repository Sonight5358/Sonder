#pragma once

#include <mutex>
#include <vector>
#include <memory>
#include <string>
#include <string_view>

#include "Connection.h"

class ClientList
{
private:
	std::vector<std::shared_ptr<Connection>> list;
	std::mutex mutex;

public:
	void Add(std::shared_ptr<Connection> client);

	void Broadcast(const std::shared_ptr<Connection>& sender, std::string_view text);
};