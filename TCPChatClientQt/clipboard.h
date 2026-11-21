#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QImage>
#include <QMimeData>

class Clipboard : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Clipboard(QObject* parent = nullptr);

    Q_INVOKABLE void setText(const QString& text);

    Q_INVOKABLE bool setImage(const QString& url);

    Q_INVOKABLE bool hasImage() const;
};