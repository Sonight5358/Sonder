#include "chatclient.h"
#include "Framing.h"
#include "Address.h"
#include "Retry.h"
#include "HandshakeError.h"

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

        SendPacket(clientSocket, MessageType::CTS, message.toStdString());
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

void ChatClient::connectToServer(const QString &address, const QString &nickname)
{
    if (clientThread.joinable())
    {
        return;
    }

    clientThread = std::thread(&ChatClient::receiveLoop, this, address.toStdString(), nickname.toStdString()); // Info to loop
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

        SendPacket(clientSocket, MessageType::Handshake, EncodeHandshake(protocolVer, nickname));

        std::optional<Packet> packet = RecvPacket(clientSocket);

        if (!packet)
        {
            throw HandshakeError("No server respond");
        }

        if (packet->type == MessageType::Reject)
        {   
            std::optional<ErrorNReject> errorNreject = DecodeReject(packet->content);

            if (!errorNreject)
            {
                throw HandshakeError("Malformed reject packet");
            }

            emit rejected(static_cast<int>(errorNreject->code), QString::fromStdString(errorNreject->rejection));

            throw HandshakeError(errorNreject->rejection);
        }

        if (packet->type != MessageType::Welcome)
        {
            throw HandshakeError("Wrong packet type");
        }

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
            if (message->type != MessageType::STC && message->type != MessageType::History)
            {
                qWarning() << "Wrong message type";
                continue;
            }

            std::optional<NickNText> nickNtext = DecodeText(message->content);

            if (!nickNtext)
            {
                qWarning() << "Malformed packet";
                continue;
            }

            emit messageReceived(QString::fromStdString(nickNtext->nick), QString::fromStdString(nickNtext->text), message->type == MessageType::History);
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

    catch (const HandshakeError& e)
    {
        qWarning() << QString::fromStdString(e.what());
    }

	catch (const std::exception& e)
	{
		qWarning() << "Error: " << e.what();
	}

	isConnected = false;
	emit disconnected();
}