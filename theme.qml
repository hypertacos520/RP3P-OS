// SwitchOS

import QtQuick 2.0
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import "qrc:/qmlutils" as PegasusUtils
import "utils.js" as Utils
import "layer_platform"
import "layer_grid"
import "layer_help"
import "layer_settings"

FocusScope
{
    id: root
    property int collectionIndex: 0
    property int currentGameIndex: 0
    property int screenmargin: vpx(30)
    property real screenwidth: width
    property real screenheight: height
    property bool widescreen: ((height/width) < 0.75)
    property real helpbarheight: Math.round(screenheight * 0.1041) // Calculated manually based on mockup
    // Load settings
    property var settings: {
        return {
            bgTheme:                api.memory.has("Theme") ? api.memory.get("Theme") : "Default",
            currentUser:            api.memory.has("Active User") ? api.memory.get("Active User") : "Hypertacos",
            timeFormat:             api.memory.has("Time Format") ? api.memory.get("Time Format") : "12hr",
            batteryPercentSetting:  api.memory.has("Display Battery Percentage") ? api.memory.get("Display Battery Percentage") : "No",
        }
    }

    function modulo(a,n) {
        return (a % n + n) % n;
    }

    function nextCollection () {
        jumpToCollection(collectionIndex + 1);
    }

    function prevCollection() {
        jumpToCollection(collectionIndex - 1);
    }

    function jumpToCollection(idx) {
        api.memory.set('gameCollIndex' + collectionIndex, currentGameIndex); // save game index of current collection
        collectionIndex = modulo(idx, api.collections.count); // new collection index
        currentGameIndex = 0; // Jump to the top of the list each time collection is changed
    }

    function showSoftwareScreen()
    {
        /*platformScreen.visible = false;
        softwareScreen.visible = true;*/
        softwareScreen.focus = true;
        toSoftware.play();
    }

    function showHomeScreen()
    {
        platformScreen.focus = true;
        backSfx.play();
        /*platformScreen.visible = true;
        softwareScreen.visible = false;*/
        //platformScreen.focus = true;
    }

    function showSettingsScreen()
    {
        settingsScreen.focus = true;
        toSoftware.play();
        /*platformScreen.visible = true;
        softwareScreen.visible = false;*/
        //platformScreen.focus = true;
    }

    function playGame()
    {
        root.state = "playgame"

        launchSfx.play()
    }

    function launchGame()
    {
        api.allGames.get(currentGameIndex).launch();
    }

    // Theme settings
    FontLoader { id: titleFont; source: "fonts/Nintendo_Switch_UI_Font.ttf" }

    // Theme colors have actually been swapped. Wanted dark to be default but didn't wanna go modify every file
    property var themeDark: {
        return {
            main: "#EBEBEB",
            secondary: "#2D2D2D",
            accent: "#10AEBE",
            highlight: "white",
            text: "#2C2C2C",
            button: "white"
        }
    }

    property var themeLight: {
        return {
            main: "#2D2D2D",
            secondary: "#EBEBEB",
            accent: "#10AEBE",
            highlight: "black",
            text: "white",
            button: "#515151"
        }
    }

    // Do this properly later
    property var theme: {
        return {
            main: api.memory.get('themeBG') || themeLight.main,
            secondary: api.memory.get('themeSecondary') || themeLight.secondary,
            accent: api.memory.get('themeAccent') || themeLight.accent,
            highlight: api.memory.get('themeHighlight') || themeLight.highlight,
            text: api.memory.get('themeText') || themeLight.text,
            button: api.memory.get('themeButton') || themeLight.button
        }
    }

    // State settings
    states: [
        State {
            name: "platformscreen"; when: platformScreen.focus == true
        },
        State {
            name: "softwarescreen"; when: softwareScreen.focus == true
        },
        State {
            name: "settingsscreen"; when: settingsScreen.focus == true
        },
        State {
            name: "playgame";
        }
    ]

    transitions: [
        Transition {
            from: "platformscreen"; to: "softwarescreen"
            SequentialAnimation {
                PropertyAnimation { target: platformScreen; property: "opacity"; to: 0; duration: 200}
                PropertyAction { target: platformScreen; property: "visible"; value: false }
                PropertyAction { target: softwareScreen; property: "visible"; value: true }
                PropertyAnimation { target: softwareScreen; property: "opacity"; to: 1; duration: 200}
            }
        },
        Transition {
            from: "platformscreen"; to: "settingsscreen"
            SequentialAnimation {
                PropertyAnimation { target: platformScreen; property: "opacity"; to: 0; duration: 200}
                PropertyAction { target: platformScreen; property: "visible"; value: false }
                PropertyAction { target: settingsScreen; property: "visible"; value: true }
                PropertyAnimation { target: settingsScreen; property: "opacity"; to: 1; duration: 200}
            }
        },
        Transition {
            from: "softwarescreen"; to: "platformscreen"
            SequentialAnimation {
                PropertyAnimation { target: softwareScreen; property: "opacity"; to: 0; duration: 200}
                PropertyAction { target: softwareScreen; property: "visible"; value: false }
                PropertyAction { target: platformScreen; property: "visible"; value: true }
                PropertyAnimation { target: platformScreen; property: "opacity"; to: 1; duration: 200}
            }
        },
        Transition {
            from: "settingsscreen"; to: "platformscreen"
            SequentialAnimation {
                PropertyAnimation { target: settingsScreen; property: "opacity"; to: 0; duration: 200}
                PropertyAction { target: settingsScreen; property: "visible"; value: false }
                PropertyAction { target: platformScreen; property: "visible"; value: true }
                PropertyAnimation { target: platformScreen; property: "opacity"; to: 1; duration: 200}
            }
        },
        Transition {
            to: "playgame"
            SequentialAnimation {
                PropertyAnimation { target: softwareScreen; property: "opacity"; to: 0; duration: 200}
                PauseAnimation { duration: 200 }
                ScriptAction { script: launchGame() }
            }
        },
        Transition {
            from: ""; to: "platformscreen"
            ParallelAnimation {
                NumberAnimation { target: platformScreen; property: "scale"; from: 1.2; to: 1.0; duration: 200; easing.type: Easing.OutQuad }
                NumberAnimation { target: platformScreen; property: "opacity"; from: 0; to: 1; duration: 200 }
            }
        }
    ]


    // Background
    Video {
        id: background
        anchors
        {
            left: parent.left; right: parent.right
            top: parent.top; bottom: parent.bottom
        }
        source: "assets/themes/" + settings.bgTheme + "/bgv.mp4";
        loops: MediaPlayer.Infinite
        autoPlay: true
        fillMode: VideoOutput.Stretch
        flushMode: VideoOutput.LastFrame
    }
    

    Component.onCompleted: {
        state: "platformscreen"
        homeSfx.play()
        bgmLoop.play()
    }

    // Platform screen
    PlatformScreen
    {
        id: platformScreen
        focus: true
        anchors
        {
            left: parent.left; right: parent.right
            top: parent.top; bottom: helpBar.top
        }
    }

    // All Software screen
    SoftwareScreen {
        id: softwareScreen
        opacity: 0
        visible: false
        anchors
        {
            left: parent.left;// leftMargin: screenmargin
            right: parent.right;// rightMargin: screenmargin
            top: parent.top; bottom: helpBar.top
        }
    }

    // Settings screen
    SettingsScreen {
        id: settingsScreen
        opacity: 0
        visible: false
        anchors
        {
            left: parent.left;// leftMargin: screenmargin
            right: parent.right;// rightMargin: screenmargin
            top: parent.top; bottom: helpBar.top
        }
    }

    // Help bar
    Item
    {
        id: helpBar
        anchors
        {
            left: parent.left; leftMargin: screenmargin
            right: parent.right; rightMargin: screenmargin
            bottom: parent.bottom
        }
        height: helpbarheight

        /*Rectangle {

            anchors.fill: parent
            color: theme.main
        }*/

        /*Rectangle {
            anchors.left: parent.left; anchors.right: parent.right
            height: 1
            color: theme.secondary
        }*/

        ControllerHelp {
            id: controllerHelp
            width: parent.width
            height: parent.height
            anchors {
                bottom: parent.bottom;
            }
            showBack: !platformScreen.focus
        }

    }

    SoundEffect {
      id: navSound
      source: "assets/audio/move.wav"
      volume: 1.0
    }

    SoundEffect {
      id: toSoftware
      source: "assets/audio/select.wav"
      volume: 1.0
    }

    SoundEffect {
      id: fillList
      source: "assets/audio/Icons.wav"
      volume: 1.0
    }

    SoundEffect {
      id: backSfx
      source: "assets/audio/back.wav"
      volume: 1.0
    }

    SoundEffect {
        id: launchSfx
        source: "assets/audio/select.wav"
        volume: 1.0
    }

    SoundEffect {
        id: homeSfx
        source: "assets/audio/startup.wav"
        volume: 1.0
    }

    SoundEffect {
        id: bgmLoop
        source: "assets/themes/" + settings.bgTheme + "/bgmLoop.wav"; //change to .wav when finished
        volume: 0.8
        loops: SoundEffect.Infinite
    }

}
