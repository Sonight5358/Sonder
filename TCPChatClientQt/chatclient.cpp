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

void ChatClient::sendImage(const QUrl& url)
{
    if (isConnected == false)
    {
        qWarning() << "Connection closed";
        return;
    }

    try
    {
        QFile file(url.toLocalFile());

        if (file.size() > maxImageSize)
        {
            qWarning() << "Image is too big";
            return;
        }

        bool result = file.open(QIODevice::ReadOnly);

        if (result == false)
        {
            qWarning() << "Image cant be opened";
            return;
        }

        QByteArray data = file.readAll();

        std::optional<UrlNSize> urlNsize = makeImageUrl(data);

        if (!urlNsize)
        {
            qWarning() << "Invalid url";
            return;
        }

        SendPacket(clientSocket, MessageType::CTSI, std::string_view(data.constData(), static_cast<size_t>(data.size())));

        emit imageSent(urlNsize->url, urlNsize->size);
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

            switch (message->type)
            {
            case MessageType::CTS: case MessageType::History:
            {
                std::optional<HistoryMessage> nickNtextNtime = DecodeHistory(message->content);

                if (!nickNtextNtime)
                {
                    qWarning() << "Malformed packet";
                    continue;
                }

                emit messageReceived(QString::fromStdString(nickNtextNtime->nick), QString::fromStdString(nickNtextNtime->text), static_cast<qint64>(nickNtextNtime->timestamp), message->type == MessageType::History);

                break;
            }

            case MessageType::CTSI:
            {
                std::optional<HistoryMessage> nickNtextNtime = DecodeHistory(message->content);

                if (!nickNtextNtime)
                {
                    qWarning() << "Malformed packet";
                    continue;
                }

                std::optional<UrlNSize> urlNsize = makeImageUrl(QByteArray::fromStdString(nickNtextNtime->text));

                if (!urlNsize)
                {
                    qWarning() << "Invalid url";
                    continue;
                }

                emit imageReceived(QString::fromStdString(nickNtextNtime->nick), urlNsize->url, static_cast<qint64>(nickNtextNtime->timestamp), message->type == MessageType::History, urlNsize->size);
            }

            case MessageType::Handshake: case MessageType::Reject: case MessageType::STC:
            case MessageType::Welcome:
            {
                qWarning() << "Wrong message type";
                break;
            }

            default:
            {
                qWarning() << "Unknown message type";
                break;
            }
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

std::optional<UrlNSize> ChatClient::makeImageUrl(const QByteArray& bytes)
{
    QBuffer buffer;
    buffer.setData(bytes);
    buffer.open(QIODeviceBase::ReadOnly);

    QImageReader reader(&buffer);

    QByteArray format(reader.format());

    if (format.isEmpty())
    {
        qWarning() << "Image format is null";
        return std::nullopt;
    }

    QImage image = reader.read();

    if (image.isNull())
    {
        qWarning() << "Failed to decode image: " << reader.errorString();
        return std::nullopt;
    }

    if (image.width() > 8192 || image.height() > 8192 ||
        image.width() <= 0 || image.height() <= 0)
    {
        qWarning() << "Image size is too big or invalid";
        return std::nullopt;
    }

    QString url(QString::fromLatin1("data:image/" + format + ";base64," + bytes.toBase64()));

    return UrlNSize{ url, reader.size() };
}