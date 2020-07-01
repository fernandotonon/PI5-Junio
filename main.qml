import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("PI5 - AirCNC")
    property var db ;

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
                    width: 100
                    height: 30
                }
            }
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    text:"Senha: "
                }
                TextField{
                    width: 100
                    height: 30
                    echoMode: TextInput.Password
                }
            }
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                Button{
                    text: "Entrar"
                    onClicked: {
                        tabBar.visible=true
                        telaLogin.visible=false
                    }
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
        dbInit()
        buscaSalas("")

        //limpa o banco
        //db.transaction(function(tx){tx.executeSql('delete from sqlitedemotable');});
    }

    function dbInit(){
        console.log(" Iniciando banco...")

        db = LocalStorage.openDatabaseSync("c:/sqlitedemodb1", "1.0", "SQLite Demo", 100000);
        db.transaction( function(tx) {
            print('... Criando tabela')
            tx.executeSql('CREATE TABLE IF NOT EXISTS sqlitedemotable(nome TEXT, valor TEXT)');
        });
    }


    function updateSala(nome, obj){
        console.log(" Armazenando dados...")

        if (!db){
            return ;
        }console.log(JSON.stringify(obj))
        var salaObj={};
        salaObj.nome = obj.nome
        salaObj.descricao = obj.descricao
        salaObj.fotos = obj.fotos

        db.transaction(function(tx){
            var result = tx.executeSql('SELECT * from sqlitedemotable where nome = ?',[nome]);

            if ( result.rows.length ===1 ){
                console.log("Atualizando a tabela...")
                result = tx.executeSql('UPDATE sqlitedemotable set valor=? where nome=?',
                                        [JSON.stringify(salaObj),nome])
                console.log(JSON.stringify(result));
            }else{
                console.log("Adicionando uma linha...")
                result = tx.executeSql('INSERT INTO sqlitedemotable VALUES (?,?)',
                                        [nome, JSON.stringify(salaObj)])
            }

        });

    }

    function buscaSalas(filtro){
        console.log(" Lendo dados...")

        if (!db){
            return ;
        }

        salasModel.clear();

        filtro = "%"+filtro+"%"

        db.transaction( function(tx) {
            print('... Lendo dados do database')
            var result = tx.executeSql('select * from sqlitedemotable where valor like ?',
                                       [filtro]);

            for(let i = 0; i<result.rows.length;i++){
                var valor = result.rows[i].valor;
                var obj = JSON.parse(valor)
                salasModel.append(obj)
                console.log(JSON.stringify(obj))
            }

        });

    }
}
