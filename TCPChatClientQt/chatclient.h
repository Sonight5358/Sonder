#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class ChatClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit ChatClient(QObject* parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &message);

signals:
    void messageReceived(const QString &message);
};