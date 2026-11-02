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
			std::cout << "No name" << '\n';
			return;
		}

		if (name->length() > MaxNameLen || name->empty())
		{
			std::cout << "Invalid name" << '\n';
			return;
		}

		list.Add(Client);
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
			std::cout << e.what() << '\n';
		}
	}

	catch (const std::exception& e)
	{
		std::cout << "Error: " << e.what() << '\n';
	}

	list.Remove(Client);
}

int main()
{	
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
			std::cout << "Option setting failed: " << e.what() << '\n';
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
				std::cout << "Error: " << e.what() << '\n';
			}
		}
	}
	catch (const std::exception& e)
	{
		std::cout << "Server start failed: " << e.what() << '\n';
		return 1;
	}

	return 0;
}