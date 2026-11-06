#include "chatclient.h"
#include "Framing.h"
#include "Address.h"
#include "Retry.h"

#include <QDebug>


ChatClient::ChatClient(QObject *parent) : QObject(parent)
{

}

void ChatClient::sendMessage(const QString &message)
{
    if (isConnected == false)
    {
        qWarning() << "Connection closed";
        return;
    }

    try
    {
        if (message == "/exit")
        {
            clientSocket.Shutdown(ShutBoth);
            return;
        }

        SendPacket(clientSocket, MessageType::Chat, message.toStdString());
    }

    catch (const SocketError& e)
    {
        if (e.code() == ConnShutdown)
        {
            qWarning() << "Connection closed";
        }

        else
        {
            qWarning() << e.what();
        }
    }

    catch (const std::length_error&)
    {
        qWarning() << "Message is too long";
    }
}

ChatClient::~ChatClient()
{
    try
    {
        clientSocket.Shutdown(ShutBoth);
    }

    catch (...)
    {

    }

    if (clientThread.joinable())
    {
        clientThread.join();
    }
}

void ChatClient::receiveLoop(std::string address, std::string nickname)
{
	try
    {
        // Client address
        sockaddr_in serverAddr = MakeAddress(address, 5358);

		// Connection to server
		RetryVoid(
			[&]()
			{
                clientSocket.Connect(serverAddr); // Lambda func
			},
			3,
			std::chrono::seconds(1)
		);

        SendPacket(clientSocket, MessageType::Handshake, nickname);

		isConnected = true;
		emit connected();

        
		while (true)
		{
			std::optional<Packet> message = RecvPacket(clientSocket);

			if (!message)
			{
				qWarning() << "Connection closed";
				break;
			}
            if (message->type != MessageType::Chat)
            {
                qWarning() << "Wrong message type";
                continue;
            }
			else
			{
				emit messageReceived(QString::fromStdString(message->content));
			}
		}
	}

	catch (const SocketError& e)
	{
		if (e.code() == ConnShutdown)
		{
			qWarning() << "Disconnected";
		}
		else if (e.code() == ECONNRESET)
		{
			qWarning() << "Peer disconnected";
		}
		else
		{
			qWarning() << e.what();
		}
	}

	catch (const std::exception& e)
	{
		qWarning() << "Error: " << e.what();
	}

	isConnected = false;
	emit disconnected();
}

void ChatClient::connectToServer(const QString &address, const QString &nickname)
{
    if (clientThread.joinable())
    {
        return;
    }

    clientThread = std::thread(&ChatClient::receiveLoop, this, address.toStdString(), nickname.toStdString());
}