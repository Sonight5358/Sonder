#include "chatclient.h"

ChatClient::ChatClient(QObject *parent) : QObject(parent)
{

}

void ChatClient::sendMessage(const QString &message)
{
    emit messageReceived(message);
}