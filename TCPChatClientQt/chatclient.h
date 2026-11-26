#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <atomic>
#include <thread>
#include <QFile>
#include <QUrl>
#include <QBuffer>
#include <QImageReader>
#include <QGuiApplication>
#include <QClipboard>
#include <queue>
#include <mutex>
#include <condition_variable>

#include "WinsockInit.h"
#include "Socket.h"

struct UrlNSize
{
    QString url;
    QSize size;
};

enum class SendType
{
    Text,
    Image
};

struct SendByType
{
    SendType type;
    QByteArray bytes;
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
    QByteArray staged;
    std::atomic<uint32_t> clientId = 0;

    std::thread sendThread;
    std::queue<SendByType> outgoing;
    std::mutex outgoingMutex;
    std::condition_variable outgoingReady;
    bool stopSending = false;

    void sendLoop();

    void receiveLoop(std::string address, std::string nickname);

    void stageBytes(const QByteArray& bytes);

    std::optional<UrlNSize> makeImageUrl(const QByteArray& bytes);

public:
    explicit ChatClient(QObject* parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &message);

    Q_INVOKABLE void stageImage(const QUrl& url);

    Q_INVOKABLE bool stageClipboard();

    Q_INVOKABLE void sendStaged();

    Q_INVOKABLE void clearStaged();

    ~ChatClient() override;

    Q_INVOKABLE void connectToServer(const QString &address, const QString &nickname);

signals:
    void messageReceived(const QString& sender, const QString& text, qint64 timestamp, bool isHistory);
    void imageReceived(const QString& sender, const QString& url, qint64 timestamp, bool isHistory, const QSize size);


    void stageChanged(const QString& url, const QSize size);
    void stageFailed(const QString& reason);

    // Image
    void imageSendStarted(const QString& url, const QSize size, quint32 totalBytes);
    void imageProgressChanged(quint32 sentBytes);
    void imageSent();
    void imageFailed();

    void connected();
    void disconnected();
    void rejected(int code, const QString& why);
};