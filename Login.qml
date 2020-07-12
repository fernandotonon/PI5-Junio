import QtQuick 2.15
import QtQuick.Controls 2.5
import Qt.labs.settings 1.1

Rectangle{
    anchors.fill: parent
    property int tWidth: 50
    property alias servidor: servidorField.text

    Settings{
        category: "AirCNC"
        fileName: "config.ini"

        property alias servidorField: servidorField.text
    }

    Image{
        anchors.fill:parent
        source: "index.jpeg"
    }

    Column{
        anchors.centerIn: parent
        spacing: 10

        Image{
            anchors.horizontalCenter: parent.horizontalCenter
            height: 100
            fillMode: Image.PreserveAspectFit
            source: "logo.png"
        }

        Text{
            anchors.horizontalCenter: parent.horizontalCenter
            text:"AirCNC"
            color: "white"
            font.bold: true
            font.pixelSize: 30
        }

        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                anchors.verticalCenter: parent.verticalCenter
                width: tWidth
                text:"Servidor: "
                color: "white"
            }
            TextField{
                id:servidorField
                width: 100; height: 30
                text:"127.0.0.1"
            }
        }

        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                anchors.verticalCenter: parent.verticalCenter
                width: tWidth
                text:"Login: "
                color: "white"
            }
            TextField{
                id:loginField
                width: 100; height: 30
                focus: true
            }
        }
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                anchors.verticalCenter: parent.verticalCenter
                width: tWidth
                text:"Senha: "
                color: "white"
            }
            TextField{
                id:senhaField
                width: 100; height: 30
                echoMode: TextInput.Password
                onAccepted: btnEntrar.entrar()
            }
        }
        Text {
            id: msgLogin
            text: " "
        }
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            Button{
                id:btnEntrar
                text: "Entrar"
                function entrar(){
                    socket.active=true
                    var send={}
                    send.op="login"
                    send.login=loginField.text
                    send.senha=Qt.md5(senhaField.text)
                    socket.sendTextMessage(JSON.stringify(send))
                }
                onClicked: entrar()
            }
        }
        Button{
            anchors.horizontalCenter: parent.horizontalCenter
            id:btnCadastrar
            text: "Cadastrar"
            function entrar(){
                var send={}
                send.op="login"
                send.login=loginField.text
                send.senha=Qt.md5(senhaField.text)
                socket.sendTextMessage(JSON.stringify(send))
            }
            onClicked: entrar()
        }
    }
}
