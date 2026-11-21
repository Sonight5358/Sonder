#include "clipboard.h"
#include <QClipboard>
#include <QGuiApplication>

Clipboard::Clipboard(QObject* parent) : QObject(parent)
{

}

void Clipboard::setText(const QString& text)
{
    QClipboard* clipboard = QGuiApplication::clipboard();
    clipboard->setText(text);
}

bool Clipboard::setImage(const QString& url)
{
    int afterComma = url.indexOf(',') + 1;
    QByteArray imageBytes = QByteArray::fromBase64(url.mid(afterComma).toLatin1());

    QImage image = QImage::fromData(imageBytes);

    if (image.isNull())
    {
        qWarning() << "Failed to copy picture";
        return false;
    }

    QClipboard* clipboard = QGuiApplication::clipboard();
    clipboard->setImage(image);

    return true;
}

bool Clipboard::hasImage() const
{
    return QGuiApplication::clipboard()->mimeData()->hasImage();
}