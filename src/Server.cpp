#include <iostream>
#include <thread>
#include <memory>
#include <functional>

#include "WinsockInit.h"
#include "Socket.h"
#include "Retry.h"
#include "Connection.h"
#include "ClientList.h"
#include "Address.h"

// Receive message from client (blocking fuction) in a separate thread
void ReceiveThread(std::shared_ptr<Connection> Client, ClientList& list)
{	
	// Name
	std::optional<std::string> name;

	try
	{	
		name = Client->Recv();

		if (!name)
		{
			std::cerr << "No name" << '\n';
			return;
		}

		if (name->length() > MaxNameLen || name->empty())
		{
			std::cerr << "Invalid name" << '\n';
			return;
		}

		// Copy of history from ClientList
		std::deque<std::string> hist = list.Add(Client);

		for (const std::string& x : hist)
		{
			Client->Send(x);
		}

		std::cout << *name << " joined" << '\n';

		while (true)
		{	
			std::optional<std::string> message = Client->Recv();

			if (!message)
			{
				std::cout << *name << " closed connection" << '\n';
				break;
			}
			else
			{
				std::cout << *name << ": " << *message << '\n';
			}

			list.Broadcast(Client, *name + ": " + *message);
		}
	}

	catch (const SocketError& e)
	{
		if (e.code() == ConnShutdown)
		{
			std::cout << "Disconnected" << '\n';
		}
		else if (e.code() == ConnReset)
		{	
			if (name)
			{
				std::cout << *name << " disconnected" << '\n';
			}
		}
		else
		{
			std::cerr << e.what() << '\n';
		}
	}

	catch (const std::exception& e)
	{
		std::cerr << "Error: " << e.what() << '\n';
	}

	list.Remove(Client);
}

int main()
{	
	std::cout << std::unitbuf;

	try
	{
		// Winsock init
		WinsockInit winsock;

		// Socket
		Socket ListenSocket;

#ifndef _WIN32
		try
		{
			ListenSocket.SetSocketOption(SOL_SOCKET, SO_REUSEADDR, 1);
		}
		catch (const SocketError& e)
		{
			std::cerr << "Option setting failed: " << e.what() << '\n';
		}
#endif

		// Server info
		sockaddr_in ServAddr = MakeAddress("0.0.0.0", 5358);

		// Bind Ip and port with this exact socket
		RetryVoid(
			[&]()
			{
				ListenSocket.Bind(ServAddr);
			},
			3,
			std::chrono::seconds(1)
		);

		// Listening
		RetryVoid(
			[&]()
			{
				ListenSocket.Listen(); // Max length of pending connection queue by default
			},
			3,
			std::chrono::seconds(1)
		);



		// List of clients
		ClientList clist;

		while (true)
		{
			// Info about client address
			sockaddr_in ClientAddr{};

			try
			{
				// Accept of incoming connection attempt and saving the same parameters as a client socket
				std::optional<Socket> ConnectionSocketOp = Retry<Socket>(
					[&]()
					{
						return ListenSocket.Accept(ClientAddr); // accept() will populate second field with client address
					},
					3,
					std::chrono::seconds(1),
					true
				);

				// New shared_ptr for every client
				std::shared_ptr<Connection> NewClient = std::make_shared<Connection>(std::move(ConnectionSocketOp.value()));

				// Thread for receiving messages from client
				std::thread NewThread(ReceiveThread, std::move(NewClient), std::ref(clist));

				NewThread.detach();
			}

			catch (const std::exception& e)
			{
				std::cerr << "Error: " << e.what() << '\n';
			}
		}
	}
	catch (const std::exception& e)
	{
		std::cerr << "Server start failed: " << e.what() << '\n';
		return 1;
	}

	return 0;
}