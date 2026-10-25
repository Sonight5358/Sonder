#include <iostream>
#include <thread>

#include "WinsockInit.h"
#include "Socket.h"
#include "Retry.h"
#include "Framing.h"

// Receive message from client (blocking fuction) in a separate thread
void ReceiveThread(Socket ConnectionSocket)
{
	try
	{
		while (true)
		{	
			std::optional<std::string> message = RecvPacket(ConnectionSocket);

			if (!message)
			{
				std::cout << "Connection closed" << '\n';
				break;
			}
			else
			{
				std::cout << "Client: " << *message << '\n';
			}
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
}

int main()
{
	// Winsock init
	WinsockInit winsock;
	

	// Socket
	Socket ListenSocket; // IPv4, TCP, auto protocol

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

			Socket ConnectionSocket = std::move(ConnectionSocketOp.value()); // Using move constructor

			// Thread for receiving messages from client
			std::thread NewThread(ReceiveThread, std::move(ConnectionSocket));

			NewThread.detach();
		}

		catch (const std::exception& e)
		{
			std::cout << "Error: " << e.what() << '\n';
		}
	}

	return 0;
}