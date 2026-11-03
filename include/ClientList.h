#pragma once

#include <mutex>
#include <vector>
#include <deque>
#include <memory>
#include <string>
#include <string_view>

#include "Connection.h"

class ClientList
{
private:
	std::vector<std::shared_ptr<Connection>> list;
	std::mutex mutex;
	std::deque<std::string> history;
	size_t maxMessageC = 100;

public:
	std::deque<std::string> Add(std::shared_ptr<Connection> client);

	void Broadcast(const std::shared_ptr<Connection>& sender, std::string_view text);

	void Remove(const std::shared_ptr<Connection>& client);
};