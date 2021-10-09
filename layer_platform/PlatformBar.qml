import QtQuick 2.8
import SortFilterProxyModel 0.2
import "../global"
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

ListView {
    //PUTS GAMES IN ORDER OF LAST PLAYED
    Item {
    id: root
        //Games filter
        property alias games: gamesFiltered
        function currentGame(index) { return api.allGames.get(lastPlayedGames.mapToSource(favoriteGames.mapToSource(index))) }
        property int max: lastPlayedGames.count //Max games in list. Change to 12 later

        SortFilterProxyModel {
        id: lastPlayedGames

            sourceModel: api.allGames
            sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
        }

        SortFilterProxyModel {
        id: favoriteGames

            sourceModel: lastPlayedGames
            sorters: FilterSorter { ValueFilter { roleName: "favorite"; value: false } }
        }

        SortFilterProxyModel {
        id: gamesFiltered

            sourceModel: favoriteGames
            filters: IndexFilter { maximumIndex: 11}//max - 1 } //- 1
        }

        property var collection: {
            return {
                name:       "Continue Playing",
                shortName:  "lastplayed",
                games:      gamesFiltered
            }
        }   
        function buildList() {
            gamesFiltered.append({
                "name":         "All Games", 
                "idx":          -3,
                "icon":         "assets/images/navigation/All Games.png",
                "background":   ""
            })
        }
    }
    //BEGIN CREATING MENU
    id: platformLayout
    property bool isCurrentMenu: focus
    //anchors.fill: parent
    spacing: vpx(14)
    orientation: ListView.Horizontal
    
    displayMarginBeginning: vpx(107)
    displayMarginEnd: vpx(107)

    preferredHighlightBegin: vpx(0)
    preferredHighlightEnd: vpx(1077)
    highlightRangeMode: ListView.StrictlyEnforceRange // Highlight never moves outside the range
    snapMode: ListView.SnapToItem
    highlightMoveDuration: 200
    highlightMoveVelocity: -1
    keyNavigationWraps: true

    onCurrentIndexChanged: {
      //navSound.play()
      return;
    }

    Keys.onLeftPressed: {   navSound.play(); decrementCurrentIndex(); buildList();} //moveCurrentIndexLeft();
    Keys.onRightPressed: {   navSound.play(); incrementCurrentIndex();  buildList();} //moveCurrentIndexRight();

    function gotoSoftware(game)
    {
            //jumpToCollection(currentIndex);
            //showSoftwareScreen();     //this event is being retired in favor of a game launching mechanic
            launchSfx.play()
            root.state = "playgame"
            api.allGames.get(lastPlayedGames.mapToSource(favoriteGames.mapToSource(currentIndex))).launch() //This code can launch games in the Most Recently Played Order
    }

    Keys.onPressed: {
         if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            gotoSoftware(ListView.currentItem);
        }
        
    }

    model: gamesFiltered//api.allGames
    delegate: platformBarDelegate

    Component {
        id: platformBarDelegate
        
        Rectangle {
            id: wrapper
            property bool selected: ListView.isCurrentItem

            width: platformLayout.height//vpx(256)
            height: 1.5*width//vpx(256* 1.5)
            color: eslogo.source ? "#cccccc" : Utils.getPlatformColor(modelData.shortName)

            Image {
                        id: screenshot
                        width: parent.width
                        height: parent.height
                        
                        asynchronous: true
                        //smooth: true
                        source: modelData.assets.screenshot
                        sourceSize { width: 256; height: 2*256 }
                        fillMode: Image.PreserveAspectCrop
                        
                    }

            Rectangle 
                    {
                        width: parent.width
                        height: parent.height
                        color: "black"
                        opacity: 0.2//0.5
                        visible: screenshot.source != ""
                    }

            Image {
                id: logo
                width: screenshot.width
                height: parent.height;//screenshot.height
                //width: parent.width - vpx(30)
                //height: vpx(75)
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: modelData.assets.logo 
                asynchronous: true
                anchors.fill: parent
                anchors.margins: vpx(6)
                antialiasing: true
                //sourceSize { width: 128; height: 128 }
                visible: eslogo.paintedWidth < 1
            }

            Text
            {
                text: modelData.title
                width: parent.width
                horizontalAlignment : Text.AlignHCenter
                font.family: titleFont.name
                color: theme.text
                font.pixelSize: Math.round(screenheight*0.025)
                font.bold: true

                anchors.centerIn: parent
                wrapMode: Text.Wrap
                visible: logo.paintedWidth < 1
                z: 10
            }

            Image {
                id: eslogo
                width: parent.width
                height: width
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: "../assets/images/logos-es/" + Utils.processPlatformName(modelData.shortName) + ".jpg"
                asynchronous: true
                sourceSize { width: 512; height: 512 }
            }


            MouseArea {
                anchors.fill: wrapper
                hoverEnabled: true
                onEntered: {}
                onExited: {}
                
                onClicked: {
                    if (platformSwitcher.focus == false)
                    {
                        settingsButton.focus = false;
                        libraryButton.focus = false;
                        platformLayout.currentIndex = index
                        platformSwitcher.focus = true;
                        navSound.play()
                    }
                    else
                    {
                        if (selected)
                        {
                            gotoSoftware();
                        }
                        else
                        {
                            navSound.play()
                            platformLayout.currentIndex = index
                        }
                    }
                }
            }

            Text {
                id: platformTitle
                text: modelData.title
                color: theme.accent
                font.family: titleFont.name
                font.pixelSize: Math.round(screenheight*0.03)
                elide: Text.ElideRight
                visible: platformLayout.isCurrentMenu

                anchors {
                    horizontalCenter: eslogo.horizontalCenter
                    bottom: eslogo.top; bottomMargin: Math.round(screenheight*0.02)
                }

                opacity: wrapper.ListView.isCurrentItem ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 75 } }
            }

            HighlightBorder
            {
                id: highlightBorder
                width: parent.width + vpx(18)//vpx(274)
                height: 1.47*width//vpx(274)

                x: vpx(-9)
                y: vpx(-9)
                z: -1

                selected: wrapper.ListView.isCurrentItem && platformLayout.isCurrentMenu;
            }

        }
    }
    
}

