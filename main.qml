import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.0
import QtWebSockets 1.1

ApplicationWindow {
    id:janela
    visible: true
    width: 640
    height: 480
    title: qsTr("PI5 - AirCNC")
    property var db ;
    property int usuarioID;

    WebSocket{
        id: socket
        active: true
        url:"ws://127.0.0.1:1234"

        onTextMessageReceived: {
            salasModel.clear();
            var result = JSON.parse(message)
            if(result.op==="login"){
                if(result.sucesso){
                    usuarioID=result.id
                    tabBar.visible=true
                    telaLogin.visible=false
                    buscaSalas("")
                } else {
                    msgLogin.text=result.mensagem
                }
            } else if (result.op==="buscaSalas"){
                for(let i = 0; i<result.list.length;i++){
                    var obj = JSON.parse(result.list[i])
                    var valor = JSON.parse(obj.valor)
                    valor.uid = obj.uid?obj.uid:0;
                    salasModel.append(valor)
                    console.log("obj.uid "+obj.uid)
                }
            }
        }

        onStatusChanged: {
            if(socket.status == WebSocket.Error){
                console.log("Erro: "+socket.errorString)
            } else if(socket.status == WebSocket.Open){
                var obj={};
                obj.op="buscar"
                obj.filtro=""
                sendTextMessage(JSON.stringify(obj))
            } else if(socket.status == WebSocket.Closed){
                console.log("Socket fechado")
            }
        }
    }

    ListModel{
        id:salasModel
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent

        Repeater {
                 model: salasModel
                 Loader {
                     active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                     sourceComponent: Sala {
                         nomeSala:nome;
                         descricaoSala: descricao;
                         fotosSala: fotos;
                         uidSala:uid;
                         Component.onCompleted: console.log("created:", index)
                         Component.onDestruction: console.log("destroyed:", index)
                     }
                 }
             }
    }

    Sala{
        id:novaSala
        visible: false
        edicao:true
    }

    Rectangle{
        id:filtroLayout
        anchors.fill: parent
        visible: false
        ColumnLayout{
            anchors.fill: parent
            Row{
                Layout.alignment:Qt.AlignCenter
                spacing: 20
                Text {
                    text: "Filtro:"
                }
                TextField{
                    id:filtro
                    width: 100; height: 30
                }
                Button{
                    width: 100
                    height: 30
                    text: "buscar"
                    onClicked: {
                        buscaSalas(filtro.text)
                        filtroLayout.visible=false
                    }
                }
            }
        }
    }

    Rectangle{
        id:telaLogin
        anchors.fill: parent
        Column{
            anchors.centerIn: parent
            spacing: 10

            Image{
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 200
                source: "http://www.univag.com.br/storage/cache/default/400x250/news/__acd372841289b14dade72301f2b57ba64c8506ed__/logounivag.jpg"
            }

            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    text:"Login: "
                }
                TextField{
                    id:loginField
                    width: 100; height: 30
                    focus: true
                }
            }
            Text {
                id: msgLogin
                text: " "
            }
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    text:"Senha: "
                }
                TextField{
                    id:senhaField
                    width: 100; height: 30
                    echoMode: TextInput.Password
                    onAccepted: btnEntrar.entrar()
                }
            }
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                Button{
                    id:btnEntrar
                    text: "Entrar"
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
    }

    footer: TabBar {
        id: tabBar
        visible: false

        TabButton {
            text: qsTr("Novo")
            onClicked: novaSala.visible=true
        }
        TabButton {
            text: qsTr("Filtrar")
            onClicked: filtroLayout.visible=true
        }
    }

    Component.onCompleted: {
        buscaSalas("")
    }

    function updateSala(nome, obj){
        var send={};
        send.op="atualizar"
        send.nome=nome
        send.obj=obj
        send.uid=usuarioID
        socket.sendTextMessage(JSON.stringify(send))
    }

    function removeSala(nome){
        var send={};
        send.op="remover"
        send.nome=nome
        send.uid=usuarioID
        socket.sendTextMessage(JSON.stringify(send))
    }

    function buscaSalas(filtro){
        var obj={};
        obj.op="buscar"
        obj.filtro=filtro
        socket.sendTextMessage(JSON.stringify(obj))
    }
}
