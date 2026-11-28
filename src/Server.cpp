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
#include "Type.h"

// Receive message from client (blocking fuction) in a separate thread
void ReceiveThread(std::shared_ptr<Connection> Client, ClientList& list)
{	
	// Name
	std::optional<std::string> name;

	try
	{	
		std::optional<Packet> packetName = Client->Recv();

		if (!packetName)
		{
			std::cerr << "No name" << '\n';
			return;
		}

		if (packetName->type != MessageType::Handshake)
		{
			std::cerr << "Wrong name type" << '\n';
			return;
		}

		std::optional<ProtocolNNick> protocolNnick = DecodeHandshake(packetName->content);

		if (!protocolNnick)
		{
			std::cerr << "No name" << '\n';
			return;
		}

		uint8_t verCheck = protocolNnick->protocol;

		if (verCheck != protocolVer)
		{
			Client->Send(EncodeReject(RejectType::OldClient, "Please update your client"), MessageType::Reject);
			std::cerr << "Old client" << '\n';
			return;
		}

		name = protocolNnick->nick;

		if (name->length() > MaxNameLen || name->empty())
		{	
			Client->Send(EncodeReject(RejectType::WrongNick, "Invalid name"), MessageType::Reject);
			std::cerr << "Invalid name" << '\n';
			return;
		}

		Client->Send(EncodeUint32(Client->GetId()), MessageType::Welcome);

		// Copy of history from ClientList
		std::deque<HistoryMessage> hist = list.Add(Client);

		for (const HistoryMessage& x : hist)
		{	
			std::string encoded = EncodeTimestamp(x.timestamp, EncodeText(x.nick, x.text));
			Client->Send(encoded, MessageType::History);
		}

		std::cout << *name << " joined" << '\n';

		size_t fileSize = 0;
		std::string file;
		bool isSending = false;

		while (true)
		{	
			std::optional<Packet> message = Client->Recv();

			if (!message)
			{
				std::cout << *name << " closed connection" << '\n';
				break;
			}
			
			switch (message->type)
			{
			case MessageType::CTS:
			{
				std::cout << *name << ": " << message->content << '\n';
				list.Broadcast(Client, *name, message->content);
				break;
			}

			case MessageType::CTSI:
			{
				std::cout << *name << ": image" << '\n';
				list.BroadcastImage(Client, *name, message->content);
				break;
			}

			case MessageType::FileBegin:
			{	
				if (isSending == true)
				{
					std::cerr << "Currently sending" << '\n';
					break;
				}

				std::cout << *name << ": file begin" << '\n';

				std::optional<uint32_t> decoded = DecodeUint32(message->content);
				if (!decoded || *decoded <= 0 || *decoded > maxFileSize)
				{
					std::cerr << "Cant decode file begin" << '\n';
					break;
				}

				isSending = true;
				fileSize = static_cast<size_t>(*decoded);
				break;
			}

			case MessageType::FileChunk:
			{	
				if (!isSending)
				{	
					std::cerr << "Not sending" << '\n';
					break;
				}

				if (message->content.size() + file.size() > fileSize)
				{
					std::cerr << "Chunk is bigger than required size" << '\n';
					fileSize = 0;
					isSending = false;
					file.clear();
					break;
				}

				//std::cout << *name << ": file chunk" << '\n';
				file.append(message->content);

				if (isSending && file.size() == fileSize)
				{
					std::cout << *name << ": file complete" << '\n';
					list.BroadcastFile(Client, *name, file);
					fileSize = 0;
					isSending = false;
					file.clear();
				}

				break;
			}

			case MessageType::Handshake: case MessageType::Reject: case MessageType::STC:
			case MessageType::History: case MessageType::STCI: case MessageType::Welcome:
			{
				std::cerr << "Wrong message type" << '\n';
				break;
			}

			default:
			{
				std::cerr << "Unknown message type" << '\n';
				break;
			}
			}
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

				uint32_t id = clist.NextId();

				// New shared_ptr for every client
				std::shared_ptr<Connection> NewClient = std::make_shared<Connection>(std::move(ConnectionSocketOp.value()), id);

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