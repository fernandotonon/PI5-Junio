import QtQuick 2.15
import QtQuick.Controls 2.5
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.14

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
    ListModel{
        id:fotosConvertidasModel
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
                width: 100
                height: 20
                visible: edicao
                text: "Galeria"
                onClicked: fileDialog.open()
            }
            Button{
                width: 100
                height: 20
                visible: edicao
                text: "Nova Foto"
                onClicked: videoOutput.visible = true
            }
        }

        VideoOutput{
            id: videoOutput
            width: 300
            height: 200
            source: camera
            visible: false

            Button{
                width: 100
                height: 20
                visible: edicao
                text: "Tirar Foto"
                onClicked: {camera.imageCapture.capture()
                videoOutput.visible=false}
            }

            Camera{
                id:camera
                imageCapture.onImageSaved: fotosModel.append({"foto": "file:///"+path})
            }
        }

        GridView{
            id:fotosView
            Layout.alignment:Qt.AlignHCenter
            width: 300;height: 200
            contentWidth:100
            contentHeight: 100
            clip: true
            model:fotosModel
            delegate:
                Rectangle{
                    implicitWidth: 100; implicitHeight:100
                    border.width: 1
                    Image {
                        anchors.fill: parent
                        source: foto
                        Component.onCompleted: grabToImage(result=>{
                                                           fotosConvertidasModel.append({"foto":"data:image/png;base64," + converter.toStr(result.image)})

                                                           })
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
                var count = 0;
                for(let i =0;i<fotosConvertidasModel.count;i++){
                    fotos.push(fotosConvertidasModel.get(i))
                }
                updateSala(nome.text,{"nome":nome.text,"descricao":descricao.text,"fotos":fotos})
                sala.visible=false
                salasModel.append({"nome":nome.text,"descricao":descricao.text,"fotos":fotos})
            }
        }
    }
}
