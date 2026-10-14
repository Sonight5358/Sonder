#include "Chatclient.h"

ChatClient::ChatClient(QObject *parent) : QObject(parent)
{

}

Q_INVOKABLE void ChatClient::sendMessage(const QString &message)
{
    emit messageReceived(message);
}