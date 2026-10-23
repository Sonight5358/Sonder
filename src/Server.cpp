#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

constexpr unsigned int DEFAULT_BUFLEN = 1024;

#include <winsock2.h>
#include <windows.h>

#include <iostream>
#include <thread>
#include <atomic>
#include "Socket.h"
#include "Retry.h"

// Receive message from client (blocking fuction) in a separate thread
void ReceiveThread(Socket& ConnectionSocket, std::atomic<bool>& connected)
{
	// Message buffer
	char buffer[DEFAULT_BUFLEN];

	try
	{
		while (true)
		{
			int Result = ConnectionSocket.Recv(buffer, 0);

			if (Result == 0)
			{
				std::cout << "Connection closed." << '\n';
				break;
			}

			// In console
			std::cout << "Client: ";
			std::cout.write(buffer, Result);
			std::cout << '\n';
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
	// Info about Winsock init
	WSADATA WsaData;
	int Result;
	Result = WSAStartup(MAKEWORD(2, 2), &WsaData);

	// If Winsock init failed
	if (Result != 0)
	{
		std::cout << "Startup failed :(" << '\n';

		return 1;
	}

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

	// Message buffer
	char buffer[DEFAULT_BUFLEN];

	// Variable for threads without data race
	std::atomic<bool> connected = true;

	// Thread for receiving messages from client
	std::thread Thread1(ReceiveThread, std::ref(ConnectionSocket), std::ref(connected));

	while (true)
	{
		// Send
		std::cin.getline(buffer, DEFAULT_BUFLEN);

		if (connected == false)
		{
			std::cout << "Connection closed" << '\n';
			break;
		}

		if (strcmp(buffer, "/exit") == 0)
		{	
			ConnectionSocket.Shutdown(SD_BOTH);
			break;
		}

		try 
		{
			// Send message from server on enter
			ConnectionSocket.Send(buffer, 0);
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
	}

	// Wait for the new thread to finish (it doesnt work for now)
	Thread1.join();

	// WS2_32 terminate
	WSACleanup();
	return 0;
}