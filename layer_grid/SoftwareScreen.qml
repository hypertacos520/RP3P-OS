import QtQuick 2.8
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2
import "../global"
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope
{
    ListView {
        //PUTS GAMES IN ORDER OF LAST PLAYED
        Item {
        id: root
            //Retropie Collection
            ListModel {
            id: retropieCollection
                function getRetropieIndex()
                {
                    var i = 0;
                    while(api.collections.get(i).shortName != null)
                    {
                        if (api.collections.get(i).shortName == "retropie")
                        {
                            return i;
                        }
                        i++;
                    }
                }
            }
            //Games filter
            property alias games: gamesFiltered
            function currentGame(index) { return api.allGames.get(lastPlayedGames.mapToSource(index)) }
            property int max: lastPlayedGames.count //Number of games total in list

            SortFilterProxyModel {
            id: lastPlayedGames

                sourceModel: api.allGames
                //sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
            }

            //Remove Retropie Items from List
            ListModel{
                id: removedRetropieItems
                function buildGameList(){
                    for (var i = 0; i < lastPlayedGames.count; i++){
                        for (var j = 0; j < api.collections.get(retropieCollection.getRetropieIndex()).games.count; j++){ //retropieCollection.count is always 0 for some reason???
                            if (lastPlayedGames.get(i).title != api.collections.get(retropieCollection.getRetropieIndex()).games.get(j).title){
                                if (j == api.collections.get(retropieCollection.getRetropieIndex()).games.count - 1){
                                    append(lastPlayedGames.get(i))
                                }
                            }
                            else{
                                break
                            }
                        }
                    }
                }
                Component.onCompleted: {
                    buildGameList();
                }
            }

            SortFilterProxyModel {
            id: gamesFiltered

                sourceModel: removedRetropieItems//lastPlayedGames
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
    }

    property int numcolumns: widescreen ? 6 : 3

    Item
    {
        id: softwareScreenContainer
        anchors.fill: parent
        anchors {
            left: parent.left; leftMargin: screenmargin
            right: parent.right; rightMargin: screenmargin
        }

        Keys.onPressed: {
            if (event.isAutoRepeat)
                return;

            if (api.keys.isDetails(event)) {
                event.accepted = true;
                return;
            }
            if (api.keys.isCancel(event)) {
                event.accepted = true;
                showHomeScreen();
                return;
            }
            if (api.keys.isFilters(event)) {
                event.accepted = true;
                return;
            }
        }

        // Top bar
        Item
        {
            id: topBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            height: Math.round(screenheight * 0.1222)
            z: 5

            Image
            {
                id: headerIcon
                width: Math.round(screenheight*0.0611)
                height: width
                source: "../assets/images/allsoft_icon.svg"
                sourceSize.width: vpx(128)
                sourceSize.height: vpx(128)

                anchors {
                    top: parent.top; topMargin: Math.round(screenheight*0.0416)
                    left: parent.left; leftMargin: vpx(38)
                }

                Text
                {
                    id: gamelibrary
                    text: "Library"//api.collections.get(collectionIndex).name
                    color: theme.text
                    font.family: titleFont.name
                    font.pixelSize: Math.round(screenheight*0.0277)
                    font.bold: true
                    anchors {
                        verticalCenter: headerIcon.verticalCenter
                        left: parent.right; leftMargin: vpx(12)
                    }
                }
            }

            ColorOverlay {
                anchors.fill: headerIcon
                source: headerIcon
                color: theme.text
                cached: true
            }

            MouseArea {
                anchors.fill: headerIcon
                hoverEnabled: true
                onEntered: {}
                onExited: {}
                onClicked: showHomeScreen();
            }

            // Line
            Rectangle {
                y: parent.height - vpx(1)
                anchors.left: parent.left; anchors.right: parent.right
                height: 1
                color: theme.secondary
            }
            

        }

        // this is the top black bar
        //Rectangle
        //{
        //    anchors {
        //        left: parent.left; top: parent.top; right: parent.right
        //    }
        //    color: theme.main
        //    height: topBar.height
        //    z: 4
        //    opacity: 0.5
        //}
        
        // Game grid
        GridView 
        {
            id: gameGrid
            focus: true

            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    launchSfx.play()
                    root.state = "playgame"
                    for (var k = 0; k < api.allGames.count; k++){
                        if (api.allGames.get(k).title == removedRetropieItems.get(currentIndex).title){
                            api.allGames.get(k).launch() //This code can launch games in the Most Recently Played Order without the items in the Retropie Collection
                        }
                    }
                }
            }

            Keys.onUpPressed:       { navSound.play(); moveCurrentIndexUp() }
            Keys.onDownPressed:     { navSound.play(); moveCurrentIndexDown() }
            Keys.onLeftPressed:     { navSound.play(); moveCurrentIndexLeft() }
            Keys.onRightPressed:    { navSound.play(); moveCurrentIndexRight() }

            onCurrentIndexChanged: {
                currentGameIndex = currentIndex;
                return;
            }

            anchors {
                left: parent.left; leftMargin: vpx(63)
                top: topBar.bottom; topMargin: vpx(20)
                right: parent.right; rightMargin: vpx(63)
                bottom: parent.bottom
            }
            
            cellWidth: width / numcolumns
            cellHeight: 1.5 * cellWidth
            preferredHighlightBegin: Math.round(screenheight*0.1388)
            preferredHighlightEnd: Math.round(screenheight*0.6527)
            highlightRangeMode: ListView.StrictlyEnforceRange // Highlight never moves outside the range
            snapMode: ListView.SnapToItem
            highlightMoveDuration: 200

            
            model: gamesFiltered //api.collections.get(collectionIndex).games
            delegate: gameGridDelegate            

            Component 
            {
                id: gameGridDelegate
                
                Item
                {
                    id: delegateContainer
                    property bool selected: delegateContainer.GridView.isCurrentItem
                    width: gameGrid.cellWidth - vpx(10)
                    height: 1.5*width
                    z: selected ? 10 : 0


                    Image {
                        id: screenshot
                        width: parent.width
                        height: parent.height
                        
                        asynchronous: true
                        //smooth: true
                        source: modelData.assets.screenshot
                        sourceSize { width: 256; height: 2*256 }
                        fillMode: Image.PreserveAspectCrop
                        
                    }//*/

                    Rectangle 
                    {
                        width: parent.width
                        height: parent.height
                        color: "black"
                        opacity: 0.2
                        visible: screenshot.source != ""
                    }

                    // Logo
                    Image {
                        id: gamelogo

                        width: screenshot.width
                        height: screenshot.height
                        anchors {
                            fill: parent
                            margins: vpx(6)
                        }

                        asynchronous: true

                        //opacity: 0
                        source: modelData.assets.logo ? modelData.assets.logo : ""
                        sourceSize { width: 256; height: 256 }
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: modelData.assets.logo ? modelData.assets.logo : ""
                        z:8
                    }

                    /*DropShadow {
                        id: logoshadow
                        anchors.fill: gamelogo
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 4.0
                        samples: 6
                        color: "#80000000"
                        source: gamelogo
                    }*/

                    MouseArea {
                        anchors.fill: screenshot
                        hoverEnabled: true
                        onEntered: {}
                        onExited: {}
                        onClicked: {
                            if (selected)
                            {
                                anim.start();
                                playGame();
                            }
                            else
                                gameGrid.currentIndex = index
                        }
                    }

                    NumberAnimation { id: anim; property: "scale"; to: 0.7; duration: 100 }
                    //NumberAnimation { property: "scale"; to: 1.0; duration: 100 }
                    
                    Rectangle {
                        id: outerborder
                        width: screenshot.width
                        height: screenshot.height
                        color: "white"//Utils.getPlatformColor(api.collections.get(collectionIndex).shortName)
                        z: -1

                        Rectangle
                        {
                            anchors.fill: outerborder
                            anchors.margins: vpx(4)
                            color: theme.main
                            z: 7
                        }

                        Text
                        {
                            text: modelData.title
                            x: vpx(8)
                            width: parent.width - vpx(16)
                            height: parent.height
                            font.family: titleFont.name
                            color: theme.text//"white"
                            font.pixelSize: Math.round(screenheight*0.0194)
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.Wrap
                            visible: !modelData.assets.logo
                            z: 10
                        }
                    }
                        

                    // Title bubble
                    Rectangle {
                        id: titleBubble
                        width: gameTitle.contentWidth + vpx(54)
                        height: Math.round(screenheight*0.0611)
                        color: "white"
                        radius: vpx(4)
                        
                        // Need to figure out how to stop it from clipping the margin
                        // mapFromItem and mapToItem are probably going to help
                        property int xpos: screenshot.width/2 - width/2
                        x: xpos
                        //y: highlightBorder.y//vpx(-63)
                        z: 10 * index

                        anchors {
                            horizontalCenter: bubbletriangle.horizontalCenter
                            bottom: bubbletriangle.top
                        }
                        
                        opacity: selected ? 0.95 : 0
                        //Behavior on opacity { NumberAnimation { duration: 50 } }

                        Text {
                            id: gameTitle                        
                            text: modelData.title
                            color: theme.accent
                            font.pixelSize: Math.round(screenheight*0.0222)
                            font.bold: true
                            font.family: titleFont.name
                            
                            anchors { 
                                verticalCenter: parent.verticalCenter
                                left: parent.left; leftMargin: vpx(27)
                            }
                            
                        }
                    }

                    Image {
                        id: bubbletriangle
                        source: "../assets/images/triangle.svg"
                        width: vpx(17)
                        height: Math.round(screenheight*0.0152)
                        opacity: titleBubble.opacity
                        x: screenshot.width/2 - width/2
                        anchors.bottom: screenshot.top
                    }

                    // Border
                    HighlightBorder
                    {
                        id: highlightBorder
                        width: screenshot.width + vpx(18)
                        height: 1.47*width

                        
                        anchors.centerIn: screenshot
                        
                        //x: vpx(-7)
                        //y: vpx(-7)
                        z: -10

                        selected: delegateContainer.GridView.isCurrentItem
                    }

                }
            }
        }

    }
}
