#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class Clipboard : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Clipboard(QObject* parent = nullptr);

    Q_INVOKABLE void setText(const QString &text);
};