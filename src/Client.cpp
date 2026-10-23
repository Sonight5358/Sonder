#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>

#include <iostream>
#include <thread>
#include <cstring>
#include <string>
#include <atomic>

#include "Socket.h"
#include "Retry.h"
#include "Framing.h"

// Receive message from server (blocking fuction) in a separate thread
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
				std::cout << "Server: " << *message << '\n';
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
	Socket ConnectionSocket;

	// Struct with server info
	sockaddr_in ServerAddr{};
	ServerAddr.sin_family = AF_INET;		// IPv4
	ServerAddr.sin_port = htons(5358);		// Converts to network byte order

	// Converting string address to binary
	Result = inet_pton(AF_INET, "127.0.0.1", &ServerAddr.sin_addr);

	// If converting failed
	if (Result != 1)
	{
		std::cout << "pton failed!" << '\n';
		WSACleanup();
		return 1;
	}

	// Connection to server
	RetryVoid(
		[&]() 
		{
			ConnectionSocket.Connect(ServerAddr); // Lambda func
		},
		3,
		std::chrono::seconds(1)
	);

	std::string line;

	// Variable for threads without data race
	std::atomic<bool> connected = true;

	// Thread for receiving messages from server
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
			// Send message from client on enter
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

	// Wait for the new thread to finish (it doesnt work for now)
	Thread1.join();

	// WS2_32 terminate
	WSACleanup();
	return 0;
}