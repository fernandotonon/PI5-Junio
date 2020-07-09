import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.0
import QtQuick.Dialogs 1.3
import QtWebSockets 1.1

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Server - PI5 - AirCNC - Server")
    property var db ;

    WebSocketServer {
        id: server
        listen: true
        host: "0.0.0.0"
        port: 1234
        accept: true
        onClientConnected: {
            webSocket.onTextMessageReceived.connect(function (message) {
                console.log(message)
                var obj = JSON.parse(message)
                if(obj.op==="buscar"){
                    webSocket.sendTextMessage(buscaSalas(obj.filtro))
                } else if(obj.op==="atualizar"){
                    updateSala(obj.nome,obj.obj,obj.uid)
                } else if(obj.op==="remover"){
                    removeSala(obj.nome,obj.uid)
                } else if(obj.op==="login"){
                    webSocket.sendTextMessage(login(obj.login,obj.senha,obj.uid))
                }
            })
        }
        onErrorStringChanged: {
            console.log(errorString);
        }
        Component.onCompleted: {
            console.log(url)
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
                         Component.onCompleted: console.log("created:", index)
                         Component.onDestruction: console.log("destroyed:", index)
                     }
                 }
             }
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
    MessageDialog{
        id:dialog
        text:"deseja excluir todos os dados?"
        onAccepted: db.transaction(function(tx){tx.executeSql('delete from sqlitedemotable');});
    }
    footer: TabBar {
        id: tabBar
        TabButton {
            text: qsTr("Limpar Dados")
            onClicked: dialog.open()
        }
        TabButton {
            text: qsTr("Filtrar")
            onClicked: filtroLayout.visible=true
        }
    }

    Component.onCompleted: {
        dbInit()
        buscaSalasServer("")
    }

    function dbInit(){
        console.log(" Iniciando banco...")

        db = LocalStorage.openDatabaseSync("c:/PI5AirCNC", "1.0", "SQLite AirCNC", 100000);
        db.transaction( function(tx) {
            print('... Criando tabela')
            tx.executeSql('CREATE TABLE IF NOT EXISTS salas(nome TEXT, valor TEXT, usuarioID INTEGER)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, login TEXT, senha TEXT)');
        });
    }


    function updateSala(nome, obj, usuario){
        console.log(" Armazenando dados...")

        if (!db){
            return ;
        }

        var salaObj={};
        salaObj.nome = obj.nome
        salaObj.descricao = obj.descricao
        salaObj.fotos = obj.fotos

        db.transaction(function(tx){
            var result = tx.executeSql('SELECT * from salas where nome = ?',[nome]);

            if ( result.rows.length ===1 ){
                console.log("Atualizando a tabela...")
                result = tx.executeSql('UPDATE salas set valor=? where nome=? and usuarioID = ?',
                                        [JSON.stringify(salaObj),nome, usuario])
                console.log(JSON.stringify(result));
            }else{
                console.log("Adicionando uma linha...")
                result = tx.executeSql('INSERT INTO salas VALUES (?,?,?)',
                                        [nome, JSON.stringify(salaObj),usuario])
            }

        });

    }

    function removeSala(nome, usuario){
        if (!db){
            return ;
        }

        db.transaction(function(tx){
            var result = tx.executeSql('DELETE FROM salas WHERE nome = ? and usuarioID = ?',[nome,usuario]);
        });

    }

    function buscaSalas(filtro){
        console.log(" Lendo dados...")

        if (!db){
            return ;
        }

        salasModel.clear();

        filtro = "%"+filtro+"%"
        var obj = {}
        obj.op = "buscaSalas"
        obj.list = []

        db.transaction( function(tx) {
            print('... Lendo dados do database')
            var result = tx.executeSql('select * from salas where valor like ?',
                                       [filtro]);

            for(let i = 0; i<result.rows.length;i++){
                obj.list.push(JSON.stringify({"valor":result.rows[i].valor,"uid":result.rows[i].usuarioID}))
            }
        });

        return JSON.stringify(obj);
    }


    function buscaSalasServer(filtro){
        console.log(" Lendo dados...")

        if (!db){
            return ;
        }

        salasModel.clear();

        filtro = "%"+filtro+"%"

        db.transaction( function(tx) {
            print('... Lendo dados do database')
            var result = tx.executeSql('select * from salas where valor like ?',
                                       [filtro]);

            for(let i = 0; i<result.rows.length;i++){
                var valor = result.rows[i].valor;
                var obj = JSON.parse(valor)
                salasModel.append(obj)
                console.log(JSON.stringify(obj))
            }

        });
    }

    function login(login, senha){
        var obj = {}
        obj.op="login"
        obj.sucesso = false
        if (!db){
            obj.messagem="Erro no servidor"
            return JSON.stringify(obj)
        }
        console.log(login)
        console.log(senha)
        db.transaction(function(tx){
            var result = tx.executeSql('SELECT * from usuarios where login = ?',[login]);


             console.log(result.rows[0].senha)
            if ( result.rows.length >= 1 ){
                obj.sucesso=(result.rows[0].senha===senha)
                if(obj.sucesso)
                    obj.id=result.rows[0].id
                else
                    obj.mensagem="Erro ao autenticar, tente novamente."
            }else{
                result = tx.executeSql('INSERT INTO usuarios (login,senha) VALUES (?,?)',
                                        [login,senha])
                obj.sucesso=true
                console.log("novo usuário")
            }

        });
        return JSON.stringify(obj)
    }
}
