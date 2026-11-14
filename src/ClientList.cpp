#include "ClientList.h"

#include <stdexcept>
#include <iostream>
#include <algorithm>
#include <chrono>

std::deque<HistoryMessage> ClientList::Add(std::shared_ptr<Connection> client)
{
	std::lock_guard<std::mutex> lock(mutex);
	list.push_back(std::move(client));

	return history;
}

void ClientList::Broadcast(const std::shared_ptr<Connection>& sender, std::string_view nick, std::string_view message)
{	
	uint64_t now = std::chrono::duration_cast<std::chrono::milliseconds>(
		std::chrono::system_clock::now().time_since_epoch()).count();

	std::vector<std::shared_ptr<Connection>> snapshot;

	std::string encoded = EncodeTimestamp(now, EncodeText(nick, message));

	{
		std::lock_guard<std::mutex> lock(mutex);

		snapshot = list;

		if (history.size() >= maxMessageC)
		{
			history.pop_front();
		}

		history.emplace_back(HistoryMessage{ std::string(nick), std::string(message), now });
	}

	Sender(snapshot, sender, encoded, MessageType::CTS);
}

void ClientList::BroadcastImage(const std::shared_ptr<Connection>& sender, std::string_view nick, std::string_view image)
{
	uint64_t now = std::chrono::duration_cast<std::chrono::milliseconds>(
		std::chrono::system_clock::now().time_since_epoch()).count();

	std::vector<std::shared_ptr<Connection>> snapshot;

	std::string encoded = EncodeTimestamp(now, EncodeText(nick, image));

	{
		std::lock_guard<std::mutex> lock(mutex);

		snapshot = list;
	}

	Sender(snapshot, sender, encoded, MessageType::CTSI);
}

void ClientList::Remove(const std::shared_ptr<Connection>& client)
{
	std::lock_guard<std::mutex> lock(mutex);

	auto exactEl = std::find(list.begin(), list.end(), client);
	if (exactEl != list.end())
	{
		list.erase(exactEl);
	}
}

void ClientList::Sender(const std::vector<std::shared_ptr<Connection>>& snapshot, const std::shared_ptr<Connection>& sender, std::string_view encoded, MessageType type)
{
	for (const std::shared_ptr<Connection>& x : snapshot)
	{
		if (x != sender)
		{
			try
			{
				x->Send(encoded, type);
			}

			catch (const std::exception& e)
			{
				std::cout << "Sending exception: " << e.what() << '\n';
			}
		}
	}
}