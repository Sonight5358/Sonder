#include <iostream>
#include <thread>
#include <string>
#include <atomic>

#include "WinsockInit.h"
#include "Socket.h"
#include "Retry.h"
#include "Framing.h"
#include "Address.h"

// Receive message from server (blocking fuction) in a separate thread
void ReceiveThread(Socket& ConnectionSocket, std::atomic<bool>& connected)
{
	try
	{
		while (true)
		{
			std::optional<Packet> message = RecvPacket(ConnectionSocket);

			if (!message)
			{
				std::cerr << "Connection closed" << '\n';
				break;
			}
			else
			{	
				if (message->type != MessageType::STC && message->type != MessageType::History)
				{
					std::cerr << "Wrong message type" << '\n';
					continue;
				}

				std::optional<NickNText> nickNtext = DecodeText(message->content);

				if (!nickNtext)
				{
					std::cerr << "Malformed packet" << '\n';
					continue;
				}

				std::cerr << nickNtext->nick << ": " << nickNtext->text << '\n';
			}
		}
	}

	catch (const SocketError& e)
	{
		if (e.code() == ConnShutdown)
		{
			std::cerr << "Disconnected" << '\n';
		}
		else if (e.code() == ConnReset)
		{
			std::cerr << "Peer disconnected" << '\n';
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

	connected = false;
}

int main()
{	
	// Winsock init
	WinsockInit winsock;

	// Socket
	Socket ConnectionSocket;

	// Server address
	sockaddr_in ServerAddr = MakeAddress("127.0.0.1", 5358);

	std::string nickname;

	while (true)
	{
		std::getline(std::cin, nickname);

		if (!nickname.empty() && nickname.length() <= MaxNameLen)
		{
			break;
		}
		else
		{
			std::cerr << "Invalid nickname, try again" << '\n';
		}
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

	// Name
	try
	{
		// Send message from client
		SendPacket(ConnectionSocket, MessageType::Handshake, EncodeHandshake(protocolVer, nickname));

		std::optional<Packet> packet = RecvPacket(ConnectionSocket);

		if (!packet)
		{
			std::cerr << "No server respond" << '\n';
			return 1;
		}
		
		if (packet->type == MessageType::Reject)
		{
			std::cerr << packet->content << '\n';
			return 1;
		}

		if (packet->type != MessageType::Welcome)
		{
			std::cerr << "Wrong packet type" << '\n';
			return 1;
		}
	}

	catch (const SocketError& e)
	{
		if (e.code() == ConnShutdown)
		{
			std::cerr << "Connection closed" << '\n';
			// To be able to go the join after /exit
		}

		std::cout << e.what() << '\n';
	}

	catch (const std::length_error&)
	{
		std::cerr << "Message is too long" << '\n';
	}


	// Message text
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
			std::cerr << "Connection closed" << '\n';
			break;
		}

		if (line == "/exit")
		{
			ConnectionSocket.Shutdown(ShutBoth);
			break;
		}

		try
		{
			// Send message from client
			SendPacket(ConnectionSocket, MessageType::CTS, line);
		}

		catch (const SocketError& e)
		{
			if (e.code() == ConnShutdown)
			{
				std::cerr << "Connection closed" << '\n';
				// To be able to go the join after /exit
				break;
			}

			std::cout << e.what() << '\n';
			break;
		}

		catch (const std::length_error&)
		{
			std::cerr << "Message is too long" << '\n';
			continue;
		}
	}

	// Wait for the new thread to finish
	Thread1.join();

	return 0;
}