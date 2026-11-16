#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <atomic>
#include <thread>
#include <QFile>
#include <QUrl>
#include <QBuffer>
#include <QImageReader>

#include "WinsockInit.h"
#include "Socket.h"

struct UrlNSize
{
    QString url;
    QSize size;
};

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

    std::optional<UrlNSize> makeImageUrl(const QByteArray& bytes);

public:
    explicit ChatClient(QObject* parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &message);

    Q_INVOKABLE void sendImage(const QUrl& url);

    ~ChatClient() override;

    Q_INVOKABLE void connectToServer(const QString &address, const QString &nickname);

signals:
    void messageReceived(const QString& sender, const QString& text, qint64 timestamp, bool isHistory);
    void imageReceived(const QString& sender, const QString& url, qint64 timestamp, bool isHistory, const QSize size);
    void imageSent(const QString& url, const QSize size);

    void connected();
    void disconnected();
    void rejected(int code, const QString& why);
};