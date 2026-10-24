#include <iostream>
#include <thread>
#include <atomic>

#include "WinsockInit.h"
#include "Socket.h"
#include "Retry.h"
#include "Framing.h"

// Receive message from client (blocking fuction) in a separate thread
void ReceiveThread(Socket& ConnectionSocket, std::atomic<bool>& connected)
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

	connected = false;
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

	// Info about client address
	sockaddr_in ClientAddr{};

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

	std::string line;

	// Variable for threads without data race
	std::atomic<bool> connected = true;

	// Thread for receiving messages from client
	std::thread Thread1(ReceiveThread, std::ref(ConnectionSocket), std::ref(connected));

	while (true)
	{
		// Send
		std::getline(std::cin, line);

		if (connected == false)
		{
			std::cout << "Connection closed" << '\n';
			break;
		}

		if (line == "/exit")
		{	
			ConnectionSocket.Shutdown(SD_BOTH);
			break;
		}

		try 
		{
			// Send message from server on enter
			SendPacket(ConnectionSocket, line);
		}
		
		catch (const SocketError& e)
		{
			if (e.code() == WSAESHUTDOWN)
			{	
				std::cout << "Connection closed" << '\n';
				// To be able to go the join after /exit
				break;
			}

			std::cout << e.what() << '\n';
			break;
		}

		catch (const std::length_error&)
		{
			std::cout << "Message is too long" << '\n';
			continue;
		}
	}

	// Wait for the new thread to finish
	Thread1.join();

	return 0;
}