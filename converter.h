#ifndef CONVERTER_H
#define CONVERTER_H

#include <QObject>
#include <QImage>
#include <QBuffer>

class Converter : public QObject
{
    Q_OBJECT
public:
    explicit Converter(QObject *parent = 0){}
    Q_INVOKABLE QString toStr(QImage img){
        QByteArray byteArray;
        QBuffer buffer(&byteArray);
        img.save(&buffer,"PNG");

        QString imgBase64 = QString::fromLatin1(byteArray.toBase64().data());

        return imgBase64;
    }

};

#endif // CONVERTER_H
