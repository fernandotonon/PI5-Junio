#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "converter.h"
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QCoreApplication::setApplicationName("AirCNC");
    QCoreApplication::setOrganizationName("Projeto Integrador");
    QCoreApplication::setOrganizationDomain("br.com.AirCNC");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    Converter *c = new Converter(&app);
    engine.rootContext()->setContextProperty("converter", c);


    return app.exec();
}
