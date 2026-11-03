#include "notification.h"

Notification::Notification(QObject* parent)
{
    trayIcon.setIcon(QIcon(":/qt/qml/TCPChatClientQt/assets/sonder.ico"));
    trayIcon.show();
    connect(&trayIcon, &QSystemTrayIcon::messageClicked, this, &Notification::trayIconClicked);
}

void Notification::notify(const QString &nickname, const QString &text)
{
    trayIcon.showMessage(nickname, text, QIcon(":/qt/qml/TCPChatClientQt/assets/sonder.ico"), 5000);
}