#pragma once

#include <mutex>
#include <vector>
#include <memory>

#include "Connection.h"

class ClientList
{
private:
	std::vector<std::shared_ptr<Connection>> list;
	std::mutex mutex;

public:
	void Add(std::shared_ptr<Connection> client)
	{
		std::lock_guard<std::mutex> lock(mutex);
		list.push_back(std::move(client));
	}
};