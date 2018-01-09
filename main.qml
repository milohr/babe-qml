import QtQuick 2.9
import QtQuick.Controls 2.2
import QtLocation 5.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

//import org.kde.kirigami 2.0 as Kirigami

import "utils/Icons.js" as MdiFont
import "utils/Player.js" as Player
import "utils"
import "view_models"
import "widgets"

//Kirigami.ApplicationWindow
ApplicationWindow
{
    id: root
    visible: true
    width: 400
    height: 500
    title: qsTr("Babe")


    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }


    //    property int columnWidth: Kirigami.Units.gridUnit * 13
    property int columnWidth: 200

    property int currentView : 0
    property int iconSize

    property var currentTrack
    property string currentArtwork

    //    minimumWidth: columnWidth

    //    pageStack.defaultColumnWidth: columnWidth
    //    pageStack.initialPage: [playlistPage, views]

    function play(track)
    {
        Player.playTrack(track)
        playIcon.text = MdiFont.Icon.pause

        if(con.getTrackBabe(currentTrack.url))
        {
            babeBtnIcon.text = MdiFont.Icon.heartOutline
            babeBtnIcon.color = "#E91E63"

        }else
        {
            babeBtnIcon.text = MdiFont.Icon.heartOutline
            babeBtnIcon.color = myPalette.dark
        }

    }

    function pause()
    {
        Player.pauseTrack()
        playIcon.text= MdiFont.Icon.play
    }

    function resume()
    {
        Player.resumeTrack()
        playIcon.text= MdiFont.Icon.pause
    }

    function appendTrack(track)
    {
        var empty = mainPlaylistTable.count
        mainPlaylistTable.model.append(track)
        mainPlaylistTable.positionViewAtEnd()

        if(empty === 0 && mainPlaylistTable.count>0)
        {
            play(mainPlaylistTable.model.get(0))
        }
    }

    onClosing: Player.savePlaylist()


    Connections
    {
        target: player
        onPos: progressBar.value = pos
        onFinished: Player.nextTrack()
    }

    Connections
    {
        target: set
        onRefreshTables:
        {
            console.log(JSON.stringify(tables))

            tracksView.clearTable()

            albumsView.clearGrid()

            artistsView.clearGrid()

            tracksView.populate()
            albumsView.populate()
            artistsView.populate()
        }
    }

    header: BabeBar
    {
        id: mainToolbar
        visible: true
        size: iconSize
        currentIndex: currentView

        onPlaylistViewClicked: currentView = 0
        onTracksViewClicked: currentView = 1
        onAlbumsViewClicked: currentView = 2
        onArtistsViewClicked: currentView = 3
        onPlaylistsViewClicked: currentView = 4
        onSettingsViewClicked: currentView = 5
    }



    Page
    {
        id: views
        width: parent.width
        height: parent.height
        //        clip: true

        Column
        {
            width: parent.width
            height: parent.height

            SwipeView
            {
                id: swipeView
                width: parent.width
                height: parent.height - searchBox.height

                currentIndex: currentView

                Item
                {
                    id: playlistPage

                    //                    Component.onCompleted:
                    //                    {
                    //                        if(mainPlaylistTable.count>0)
                    //                            root.width = columnWidth
                    //                        else
                    //                            root.width = columnWidth*3
                    //                    }

                    GridLayout
                    {
                        id: playlistLayout
                        width: parent.width
                        height: parent.height
                        columns: 1
                        rows: 4
                        rowSpacing: 0

                        Rectangle
                        {
                            id: coverPlay
                            Layout.row: 1
                            height: columnWidth
                            width: parent.width
                            Layout.fillWidth: true

                            visible: mainPlaylistTable.count>0

                            FastBlur
                            {
                                anchors.fill: coverPlay
                                source: artwork
                                radius: 100
                            }

                            Image
                            {
                                id: artwork
                                width: parent.width < columnWidth ? parent.width : columnWidth
                                height: parent.height
                                anchors.centerIn: parent
                                source: currentArtwork ? "file://"+encodeURIComponent(currentArtwork)  : "qrc:/assets/cover.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Slider
                        {
                            id: progressBar
                            Layout.fillWidth: true
                            Layout.row: 3
                            height: 16
                            from: 0
                            to: 1000
                            value: 0
                            visible: mainPlaylistTable.count>0
                            spacing: 0

                            onMoved:
                            {
                                player.seek(player.duration() / 1000 * value);
                            }
                        }

                        Rectangle
                        {
                            id: playbackControls
                            Layout.fillWidth: true
                            Layout.row: 2
                            height: 48
                            visible: mainPlaylistTable.count>0

                            RowLayout
                            {
                                width: parent.width
                                height: parent.height
                                anchors.fill: parent
                                Row
                                {
                                    anchors.centerIn: parent

                                    ToolButton
                                    {
                                        Icon
                                        {
                                            id: babeBtnIcon
                                            text: MdiFont.Icon.heartOutline
                                            color: myPalette.dark
                                        }

                                        onClicked:
                                        {
                                            if(con.getTrackBabe(currentTrack.url))
                                            {
                                                con.babeTrack(currentTrack.url, false)
                                                babeBtnIcon.text = MdiFont.Icon.heartOutline
                                                babeBtnIcon.color = myPalette.dark

                                            }else
                                            {
                                                con.babeTrack(currentTrack.url, true)
                                                babeBtnIcon.text = MdiFont.Icon.heartOutline
                                                babeBtnIcon.color = "#E91E63"
                                            }
                                        }
                                    }

                                    ToolButton
                                    {
                                        id: previousBtn
                                        Icon {text: MdiFont.Icon.skipPrevious}
                                        onClicked: Player.previousTrack()
                                    }

                                    ToolButton
                                    {
                                        id: playBtn
                                        Icon {id: playIcon; text: MdiFont.Icon.play }
                                        onClicked:
                                        {
                                            if(player.isPaused()) resume()
                                            else pause()
                                        }
                                    }

                                    ToolButton
                                    {
                                        id: nextBtn
                                        Icon{text: MdiFont.Icon.skipNext}
                                        onClicked: Player.nextTrack()

                                    }

                                    ToolButton
                                    {
                                        id: shuffleBtn
                                        Icon{text: MdiFont.Icon.shuffle}
                                    }
                                }
                            }
                        }

                        Rectangle
                        {
                            id: mainPlaylist
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Layout.row: 4

                            BabeTable
                            {
                                id: mainPlaylistTable
                                width: parent.width
                                height: parent.height
                                onRowClicked:
                                {
                                    play(model.get(index))
                                }

                                Component.onCompleted:
                                {
                                    var list = util.lastPlaylist()
                                    for(var i in list)
                                    {
                                        var track = con.get("select * from tracks where url = \""+list[i]+"\"")
                                        appendTrack(track[0])
                                    }

                                }
                            }
                        }
                    }
                }



                TracksView
                {
                    id: tracksView
                    onRowClicked: appendTrack(model.get(index))
                }

                AlbumsView
                {
                    id: albumsView
                    onRowClicked: appendTrack(track)
                    onPlayAlbum:
                    {
                        mainPlaylistTable.clearTable()
                        for(var i in tracks)
                            appendTrack(tracks[i])
                        play(mainPlaylistTable.model.get(0))
                    }
                    onAppendAlbum:
                    {
                        for(var i in tracks)
                            appendTrack(tracks[i])
                    }

                }

                ArtistsView
                {
                    id: artistsView
                    onRowClicked: appendTrack(track)
                    onPlayAlbum:
                    {
                        mainPlaylistTable.clearTable()
                        for(var i in tracks)
                            appendTrack(tracks[i])
                        play(mainPlaylistTable.model.get(0))
                    }
                    onAppendAlbum:
                    {
                        for(var i in tracks)
                            appendTrack(tracks[i])
                    }
                }

                PlaylistsView {}

                SettingsView
                {
                    onIconSizeChanged: iconSize = size
                }

                onCurrentIndexChanged:
                {
                    currentView = currentIndex
                }
            }

            Rectangle
            {
                id: searchBox
                width: parent.width
                height: 32
                color: "white"
                TextInput
                {
                    id: searchInput
                    anchors.fill: parent
                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter

                    property string placeholderText: "Search..."

                    Label
                    {
                        anchors.fill: parent
                        text: searchInput.placeholderText
                        visible: !(searchInput.focus || searchInput.text)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:  Text.AlignVCenter
                        font.bold: true
                    }

                }
            }
        }


    }
}
