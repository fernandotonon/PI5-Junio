import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.0

Rectangle{
    id:sala
    anchors.fill: parent
    property bool edicao: false
    property alias nomeSala:nome.text
    property alias descricaoSala:descricao.text
    property var fotosSala

    onFotosSalaChanged: {
        console.log("fotos: "+fotosSala)
        console.log("fotos: "+fotosSala.count)
        for(let i =0;i<fotosSala.count;i++){
            fotosModel.append(fotosSala.get(i))
            console.log("fotos: "+fotosSala.get(i))
        }
    }

    FileDialog{
        id: fileDialog
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            for(let i=0; i<files.length;i++)
                fotosModel.append({"foto":files[i]})
        }
        nameFilters: "Imagens (*.bmp *.jpg *.jpeg *.png *.svg *.gif)"
    }

    ListModel{
        id:fotosModel
    }

    ColumnLayout{
        anchors.fill: parent
        Row{
            Layout.alignment:Qt.AlignHCenter
            spacing: 20
            Text {
                text: "Fotos:"
            }
            Button{
                width: 20
                height: 20
                visible: edicao
                text: "+"
                onClicked: fileDialog.open()
            }
        }

        TableView{
            id:fotosView
            Layout.alignment:Qt.AlignHCenter
            width: 300;height: 200
            contentWidth:100
            contentHeight: 100
            columnSpacing: 1
            rowSpacing: 1
            clip: true
            model:fotosModel
            delegate:
                Rectangle{
                    implicitWidth: 100; implicitHeight:100
                    Image {
                        width: 100;height: 100
                        source: foto
                    }
            }
        }

        Row{
            Layout.alignment:Qt.AlignHCenter
            spacing: 10
            Text {
                text: "Nome:"
            }
            TextField{
                id:nome
                width: 100; height: 30
                enabled: edicao
            }
        }
        Row{
            Layout.alignment:Qt.AlignHCenter
            spacing: 10
            Text {
                text: "Descrição:"
            }
            ScrollView{
                width: sala.width-100; height: 100
                TextArea{
                    id:descricao
                    anchors.fill: parent
                    implicitWidth: sala.width-100
                    implicitHeight: 100
                    enabled: edicao
                    background: Rectangle{
                        anchors.fill: parent
                        border.width: 1
                    }
                }
            }
        }
        Button{
            Layout.alignment:Qt.AlignHCenter
            width: sala.width; height: 30
            text: "Salvar"
            visible: edicao
            onClicked: {
                var fotos=[]
                for(let i =0;i<fotosModel.count;i++){
                    fotos.push(fotosModel.get(i))
                }

                updateSala(nome.text,{"nome":nome.text,"descricao":descricao.text,"fotos":fotos})
                sala.visible=false
                salasModel.append({"nome":nome.text,"descricao":descricao.text,"fotos":fotos})
            }
        }
    }
}
