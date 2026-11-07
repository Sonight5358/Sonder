#include "ClientList.h"

#include <stdexcept>
#include <iostream>
#include <algorithm>

std::deque<NickNText> ClientList::Add(std::shared_ptr<Connection> client)
{
	std::lock_guard<std::mutex> lock(mutex);
	list.push_back(std::move(client));

	return history;
}

void ClientList::Broadcast(const std::shared_ptr<Connection>& sender, std::string_view nick, std::string_view message)
{	
	std::vector<std::shared_ptr<Connection>> snapshot;

	std::string encoded = EncodeText(nick, message);

	{
		std::lock_guard<std::mutex> lock(mutex);

		snapshot = list;

		if (history.size() >= maxMessageC)
		{
			history.pop_front();
		}

		history.emplace_back(NickNText{ std::string(nick), std::string(message) });
	}

	for (const std::shared_ptr<Connection>& x : snapshot)
	{	
		if (x != sender)
		{
			try
			{
				x->Send(encoded, MessageType::STC);
			}

			catch (const std::exception& e)
			{
				std::cout << "Sending exception: " << e.what() << '\n';
			}
		}
	}
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