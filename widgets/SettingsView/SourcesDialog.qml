import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../../view_models"
import "../../view_models/FolderPicker"
import "../../view_models/BabeDialog"

BabePopup
{

    property string pathToRemove : ""

    function scanDir(folderUrl)
    {
        bae.scanDir(folderUrl)
        close()
    }


    FolderDialog
    {
        id: folderDialog
        folder: bae.homeDir()
        onAccepted:
        {
            var path = folder.toString().replace("file://","")

            listModel.append({url: path})
            scanDir(path)
        }
    }

    FolderPicker
    {
        id: folderPicker

        Connections
        {
            target: folderPicker
            onPathClicked: folderPicker.load(path)

            onAccepted:
            {
                listModel.append({url: path})
                scanDir(path)
            }

            onGoBack: folderPicker.load(path)
        }
    }

    BabeMessage
    {
        id: confirmationDialog
        onAccepted:
        {
            if(pathToRemove.length>0)
                if(bae.removeSource(pathToRemove))
                    bae.refreshCollection()

        }
    }


    BabeList
    {
        id: sources
        anchors.fill: parent
        headerBarVisible: true
        headerBarExit: true
        headerBarTitle: qsTr("Sources")
        Layout.fillWidth: true
        Layout.fillHeight: true
        width: parent.width

        onExit: close()

        ListModel { id: listModel }

        model: listModel

        delegate: BabeDelegate
        {
            id: delegate
            label: url

            Connections
            {
                target: delegate
                onClicked: sources.currentIndex = index
            }
        }

        headerBarRight: [

            BabeButton
            {
                iconName: "list-remove"
                onClicked:
                {
                    close()
                    var index = sources.currentIndex
                    var url = sources.list.model.get(index).url

                    confirmationDialog.title = "Remove source"

                    if(bae.defaultSources().indexOf(url)<0)
                    {
                        pathToRemove = url
                        confirmationDialog.message = "Are you sure you want to remove the source: \n "+url
                    }
                    else
                    {
                        pathToRemove = ""
                        confirmationDialog.message = url+"\nis a default source and cannot be removed"
                    }

                    confirmationDialog.open()
                }
            },

            BabeButton
            {
                iconName: "list-add"
                onClicked:
                {
                    if(bae.isMobile())
                    {
                        folderPicker.open()
                        folderPicker.load(bae.homeDir())
                    }else
                        folderDialog.open()
                }
            }
        ]
    }

    onOpened: getSources()

    function getSources()
    {
        sources.clearTable()
        var folders = bae.getSourcesFolders()
        for(var i in folders)
            sources.model.append({url : folders[i]})
    }
}
