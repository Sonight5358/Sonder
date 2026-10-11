#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QSGRendererInterface>

#include <dwmapi.h>

int main(int argc, char *argv[])
{
    // Setting api
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("TCPChatClientQt", "Main");

    // Setting windows acryl
    const auto rootObjects = engine.rootObjects();
    auto *window = qobject_cast<QQuickWindow *>(rootObjects.first());

    // Window desc
    HWND hwnd = reinterpret_cast<HWND>(window->winId());
    int backdrop = DWMSBT_TRANSIENTWINDOW;
    DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &backdrop, sizeof(backdrop));

    BOOL dark = TRUE;
    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark, sizeof(dark));

    return QGuiApplication::exec();
}