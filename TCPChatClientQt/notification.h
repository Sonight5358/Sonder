#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QSystemTrayIcon>

class Notification : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

private:
    QSystemTrayIcon trayIcon;

public:
    explicit Notification(QObject* parent = nullptr);

    Q_INVOKABLE void notify(const QString &nickname, const QString &text);

signals:
    void trayIconClicked();
};