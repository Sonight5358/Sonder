#pragma once

#include <mutex>
#include <vector>
#include <deque>
#include <memory>
#include <string>
#include <string_view>
#include <cstdint>
#include <atomic>

#include "Connection.h"

class ClientList
{
private:
	std::vector<std::shared_ptr<Connection>> list;
	std::mutex mutex;
	std::deque<HistoryMessage> history;
	size_t maxMessageC = 100;
	std::atomic<uint32_t> clientID = 0;

	static void Sender(const std::vector<std::shared_ptr<Connection>>& snapshot, const std::shared_ptr<Connection>& sender, std::string_view encoded, MessageType type);

public:
	std::deque<HistoryMessage> Add(std::shared_ptr<Connection> client);

	void Broadcast(const std::shared_ptr<Connection>& sender, std::string_view nick, std::string_view message);

	void BroadcastImage(const std::shared_ptr<Connection>& sender, std::string_view nick, std::string_view image);

	void BroadcastFile(const std::shared_ptr<Connection>& sender, std::string_view nick, std::string_view file);

	void Remove(const std::shared_ptr<Connection>& client);

	uint32_t NextId();
};