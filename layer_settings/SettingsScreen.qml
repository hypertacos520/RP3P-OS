import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2
import "../global"
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

FocusScope {
id: root
    ListModel {
    id: retropieCollection
        function createListElement(retropieIndex, j) {
            return {
                settingName:       api.collections.get(retropieIndex).games.get(j).title,
                settingSubtitle:       "",
                setting: "Launch External Tool", 
                path:              api.collections.get(retropieIndex).games.get(j)
            }
        }

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

        function generateRetropieCollection()
        {
            var retropieIndex = getRetropieIndex();
            for(var j=0; j<api.collections.get(retropieIndex).games.count; j++)
            {
                append(createListElement(retropieIndex, j));
            }
        }

        Component.onCompleted: {
            generateRetropieCollection();
        }
    }

    property var osPage: {
        return {
            pageName: "Operating System",
            listmodel: retropieCollection
        }
    }

    ListModel {
        id: homeSettingsModel
        function getThemesList(){
            var fs = require('fs');
            var files = fs.readdirSync('/assets/themes/');
            print(files);
        }
        ListElement {
            settingName: "Theme"
            settingSubtitle: ""
            setting: "Default"
        }
        ListElement {
            settingName: "Time Format"
            settingSubtitle: ""
            setting: "12hr,24hr"
        }
        ListElement {
            settingName: "Active User"
            settingSubtitle: "(Blank for no user)"
            setting: "Hypertacos,"
        }
        // ListElement {
        //     settingName: "Display Battery Life"
        //     settingSubtitle: "(Currently Unavailable)"
        //     setting: "No,Yes"
        // }
    }

    property var homePage: {
        return {
            pageName: "Home Screen",
            listmodel: homeSettingsModel
        }
    }

    function makeSettingsList(){
        if (osPage.listmodel.count){
            return [homePage, osPage];
        }
        else{
            return [homePage];
        }
    }
    
    property var settingsArr: makeSettingsList();

    property real itemheight: vpx(50)

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
            source: "../assets/images/settings_icon.png"
            sourceSize.width: vpx(128)
            sourceSize.height: vpx(128)

            anchors {
                top: parent.top; topMargin: Math.round(screenheight*0.0416)
                left: parent.left; leftMargin: vpx(38)
            }

            Text
            {
                id: collectionTitle
                text: "Settings"
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
                anchors.fill: parent
                hoverEnabled: false
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

    ListView {
    id: pagelist
    
        focus: true
        anchors {
            top: topBar.bottom
            bottom: parent.bottom; //bottomMargin: helpMargin
            left: parent.left; //leftMargin: globalMargin
        }
        width: vpx(300)
        model: settingsArr
        delegate: Component {
        id: pageDelegate
        
            Item {
            id: pageRow

                property bool selected: ListView.isCurrentItem

                width: ListView.view.width
                height: itemheight

                // Page name
                Text {
                id: pageNameText
                
                    text: modelData.pageName
                    color: theme.text
                    //font.family: subtitleFont.name
                    font.pixelSize: vpx(22)
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    opacity: selected ? 1 : 0.2

                    width: contentWidth
                    height: parent.height
                    anchors {
                        left: parent.left; leftMargin: vpx(25)
                    }
                }

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                    onEntered: { /*navSound.play();*/}
                    onClicked: {
                        navSound.play();
                        pagelist.currentIndex = index;
                        settingsList.focus = true;
                    }
                }

            }
        } 

        Keys.onUpPressed: { navSound.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { navSound.play(); incrementCurrentIndex() }
        Keys.onPressed: {
            // Accept
            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                event.accepted = true;
                navSound.play();
                settingsList.focus = true;
            }
            // Back
            if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                event.accepted = true;
                showHomeScreen();
            }
        }

    }

    Rectangle {
        anchors {
            left: pagelist.right;
            top: pagelist.top; bottom: pagelist.bottom
        }
        width: vpx(1)
        color: theme.text
        opacity: 0.1
    }

    ListView {
    id: settingsList

        model: settingsArr[pagelist.currentIndex].listmodel
        delegate: settingsDelegate
        
        anchors {
            top: topBar.bottom; bottom: parent.bottom; 
            left: pagelist.right; //leftMargin: globalMargin
            right: parent.right; //rightMargin: globalMargin
        }
        width: vpx(500)

        spacing: vpx(0)
        orientation: ListView.Vertical

        preferredHighlightBegin: settingsList.height / 2 - itemheight
        preferredHighlightEnd: settingsList.height / 2
        highlightRangeMode: ListView.ApplyRange
        highlightMoveDuration: 100
        clip: false

        Component {
        id: settingsDelegate
        
            Item {
            id: settingRow

                property bool selected: ListView.isCurrentItem && settingsList.focus
                property variant settingList: setting.split(',')
                property int savedIndex: api.memory.get(settingName + 'Index') || 0

                function saveSetting() {
                    api.memory.set(settingName + 'Index', savedIndex);
                    api.memory.set(settingName, settingList[savedIndex]);
                }

                function nextSetting() {
                    if (savedIndex != settingList.length -1)
                        savedIndex++;
                    else
                        savedIndex = 0;
                }

                function prevSetting() {
                    if (savedIndex > 0)
                        savedIndex--;
                    else
                        savedIndex = settingList.length -1;
                }

                width: ListView.view.width
                height: itemheight

                // Setting name
                Text {
                id: settingNameText
                
                    text: settingSubtitle != "" ? settingName + " " + settingSubtitle + ": " : settingName + ": "
                    color: theme.text
                    //font.family: subtitleFont.name
                    font.pixelSize: vpx(20)
                    verticalAlignment: Text.AlignVCenter
                    opacity: selected ? 1 : 0.2

                    width: contentWidth
                    height: parent.height
                    anchors {
                        left: parent.left; leftMargin: vpx(25)
                    }
                }
                // Setting value
                Text { 
                id: settingtext; 
                
                    text: settingList[savedIndex]; 
                    color: theme.accent
                    //font.family: subtitleFont.name
                    font.pixelSize: vpx(20)
                    verticalAlignment: Text.AlignVCenter
                    opacity: selected ? 1 : 0.2

                    height: parent.height
                    anchors {
                        right: parent.right; rightMargin: vpx(25)
                    }
                }

                Rectangle {
                    anchors { 
                        left: parent.left; leftMargin: vpx(25)
                        right: parent.right; rightMargin: vpx(25)
                        bottom: parent.bottom
                    }
                    color: theme.text
                    opacity: selected ? 0.1 : 0
                    height: vpx(1)
                }

                // Input handling
                // Next setting
                Keys.onRightPressed: {
                    //selectSfx.play()
                    nextSetting();
                    saveSetting();
                    if (settingName == "Theme")
                    {
                        bgmLoop.play()
                    }
                }
                // Previous setting
                Keys.onLeftPressed: {
                    //selectSfx.play();
                    prevSetting();
                    saveSetting();
                    if (settingName == "Theme")
                    {
                        bgmLoop.play()
                    }
                }

                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        if (settingsList.focus == true) {
                            path.launch();
                        }
                        event.accepted = true;
                        selectSfx.play()
                        nextSetting();
                        saveSetting();
                    }
                    // Back
                    if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        navSound.play()
                        pagelist.focus = true;
                    }
                }

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false //settings.MouseHover == "Yes"
                    onEntered: { /*navSound.play();*/ }
                    onClicked: {
                        if(selected){
                            selectSfx.play();
                            nextSetting();
                            saveSetting();
                        } else {
                            navSound.play();
                            settingsList.focus = true;
                            settingsList.currentIndex = index;
                        }
                    }
                }
            }
        } 

        Keys.onUpPressed: { navSound.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { navSound.play(); incrementCurrentIndex() }
    }

}