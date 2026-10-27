#include "ClientList.h"

#include <stdexcept>
#include <iostream>

void ClientList::Add(std::shared_ptr<Connection> client)
{
	std::lock_guard<std::mutex> lock(mutex);
	list.push_back(std::move(client));
}

void ClientList::Broadcast(const std::shared_ptr<Connection>& sender, std::string_view text)
{
	std::lock_guard<std::mutex> lock(mutex);

	for (const std::shared_ptr<Connection>& x : list)
	{	
		if (x != sender)
		{
			try
			{
				x->Send(text);
			}

			catch (const std::exception& e)
			{
				std::cout << "Sending exception: " << e.what() << '\n';
			}
		}
	}
}