#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <atomic>
#include <thread>

#include "WinsockInit.h"
#include "Socket.h"

class ChatClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT

private:
    WinsockInit winsock;
    Socket clientSocket;
    std::thread clientThread;
    std::atomic<bool> isConnected = false;

    void receiveLoop(std::string address, std::string nickname);

public:
    explicit ChatClient(QObject* parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &message);

    ~ChatClient() override;

    Q_INVOKABLE void connectToServer(const QString &address, const QString &nickname);

signals:
    void messageReceived(const QString &message);

    void connected();
    void disconnected();
};