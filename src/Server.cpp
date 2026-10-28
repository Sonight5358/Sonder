#include <iostream>
#include <thread>
#include <memory>
#include <functional>

#include "WinsockInit.h"
#include "Socket.h"
#include "Retry.h"
#include "Connection.h"
#include "ClientList.h"

// Receive message from client (blocking fuction) in a separate thread
void ReceiveThread(std::shared_ptr<Connection> Client, ClientList& list)
{
	try
	{
		while (true)
		{	
			std::optional<std::string> message = Client->Recv();

			if (!message)
			{
				std::cout << "Connection closed" << '\n';
				break;
			}
			else
			{
				std::cout << "Client: " << *message << '\n';
			}

			list.Broadcast(Client, *message);
		}
	}

	catch (const SocketError& e)
	{
		if (e.code() == WSAESHUTDOWN)
		{
			std::cout << "Disconnected" << '\n';
		}
		else if (e.code() == WSAECONNRESET)
		{
			std::cout << "Peer disconnected" << '\n';
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
	// Winsock init
	WinsockInit winsock;

	// Socket
	Socket ListenSocket;

	// Struct with server info
	sockaddr_in ServAddr{};
	ServAddr.sin_family = AF_INET;			// IPv4
	ServAddr.sin_port = htons(5358);		// Converts to network byte order
	ServAddr.sin_addr.s_addr = INADDR_ANY;  // .sin_addr - struct with IP, .s_addr (unsigned long) - field of the .sin_addr for IP, INADDR_ANY - 0.0.0.0 (any address basically)

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

			clist.Add(NewClient);

			// Thread for receiving messages from client
			std::thread NewThread(ReceiveThread, std::move(NewClient), std::ref(clist));

			NewThread.detach();
		}

		catch (const std::exception& e)
		{
			std::cout << "Error: " << e.what() << '\n';
		}
	}

	return 0;
}