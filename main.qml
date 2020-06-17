import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.15
import QtQuick.LocalStorage 2.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Tabs")
    property var db ;

    FileDialog{
        id: fileDialog
        fileMode: fileDialog.OpenFiles
        onAccepted: console.log(files)
    }

    ListModel{
        id:salasModel
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Repeater {
                 model: 6
                 Loader {
                     active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                     sourceComponent: Text {
                         text: index
                         Component.onCompleted: console.log("created:", index)
                         Component.onDestruction: console.log("destroyed:", index)
                     }
                 }
             }
    }

    Rectangle{
        id:novaSala
        anchors.fill: parent
        visible: false
        ColumnLayout{
            anchors.fill: parent
            Row{
                Text {
                    text: "Fotos:"
                }
                Button{
                    text: "Adicionar"
                }
            }

        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Novo")
            onClicked: novaSala.visible=true
        }
        TabButton {
            text: qsTr("Filtrar")
        }
    }

    Component.onCompleted: {
        dbInit()
        leDados()
    }

    Component.onDestruction: {
        gravaDados()
    }

    function dbInit(){
        console.log(" Iniciando banco...")

        db = LocalStorage.openDatabaseSync("c:/sqlitedemodb1", "1.0", "SQLite Demo", 100000);
        db.transaction( function(tx) {
            print('... Criando tabela')
            tx.executeSql('CREATE TABLE IF NOT EXISTS sqlitedemotable(nome TEXT, valor TEXT)');
        });
    }


    function gravaDados(){
        console.log(" Armazenando dados...")

        if (!db){
            return ;
        }

        db.transaction(function(tx){
            var result = tx.executeSql('SELECT * from sqlitedemotable where nome = "sqlitedemo"');

            var obj = { x: rootId.x, y: rootId.y,
                width : rootId.width,height : rootId.height,
                colorred : containedRectId.color.r,colorgreen : containedRectId.color.g ,
                colorblue : containedRectId.color.b };

            if ( result.rows.length ===1 ){
                console.log("Atualizando a tabela...")
                result = tx.executeSql('UPDATE sqlitedemotable set valor=? where nome="sqlitedemo"',
                                        [JSON.stringify(obj)])
                console.log(JSON.stringify(result));
            }else{
                console.log("Adicionando uma linha...")
                result = tx.executeSql('INSERT INTO sqlitedemotable VALUES (?,?)',
                                        ['sqlitedemo', JSON.stringify(obj)])
            }

        });

    }


    function leDados(){
        console.log(" Lendo dados...")

        if (!db){
            return ;
        }

        db.transaction( function(tx) {
            print('... Lendo dados do database')
            var result = tx.executeSql('select * from sqlitedemotable where nome="sqlitedemo"');

            if(result.rows.length === 1){

                var valor = result.rows[0].valor;
                var obj = JSON.parse(valor)

                rootId.x = obj.x;
                rootId.y = obj.y;
                rootId.width= obj.width;
                rootId.height = obj.height
                containedRectId.color= Qt.rgba(obj.colorred,obj.colorgreen,obj.colorblue,1)
            }

        });

    }
}
