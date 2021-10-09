import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.11
import "../utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils
import "../global"
//import QtQml 2.0

FocusScope
{
    id: root
    Item
    {
        id: platformScreenContainer
        width: parent.width
        height: parent.height

        /*onVisibleChanged: {
            platformSwitcher.focus = true;
        }*/

        property var batteryStatus: isNaN(api.device.batteryPercent) ? "" : parseInt(api.device.batteryPercent*100);

        Item {
        id: topbar

            
            height: Math.round(screenheight * 0.2569)
            anchors {
                left: parent.left; leftMargin: vpx(60)
                right: parent.right; rightMargin: vpx(60)
                top: parent.top; topMargin: Math.round(screenheight * 0.0472)
            }

            // Top bar
            Image
            {
                id: profileIcon
                anchors
                {
                    top: parent.top;
                    left: parent.left;
                }
                width: Math.round(screenheight * 0.0833)
                height: width
                source: "../assets/users/" + settings.currentUser + ".png"
                sourceSize { width: 128; height:128 }
                smooth: true
                antialiasing: true
            }

            Text
            {
                id: username
                anchors
                {
                    top: sysTime.top//profileIcon.verticalCenter;
                    left: profileIcon.right; leftMargin: vpx(12)
                }
                text: settings.currentUser
                color: theme.text
                font.pixelSize: Math.round(screenheight*0.0277)
            }

            DropShadow {
                id: profileIconShadow
                anchors.fill: profileIcon
                horizontalOffset: 0
                verticalOffset: 0
                radius: 6.0
                samples: 6
                color: "#1F000000"
                source: profileIcon
            }

            Text
            {
                id: sysTime
                property var timeSetting: (settings.timeFormat === "12hr") ? "h:mmap" : "hh:mm";

                function set() {
                    sysTime.text = Qt.formatTime(new Date(), timeSetting)
                }

                Timer {
                    id: textTimer
                    interval: 60000 // Run the timer every minute
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: sysTime.set()
                }

                anchors {
                    verticalCenter: profileIcon.verticalCenter;
                    right: parent.right
                }
                color: theme.text
                font.pixelSize: Math.round(screenheight*0.0277)
                horizontalAlignment: Text.Right
            }
        }
        // Row{
        //     spacing: vpx(5)
            
        //     Text {
        //         id: batteryPercentage

        //         function set() {
        //             batteryPercentage.text = platformScreenContainer.batteryStatus+"%";
        //         }

        //         Timer {
        //             id: percentTimer
        //             interval: 60000 // Run the timer every minute
        //             repeat: isNaN(api.device.batteryPercent) ? false : showPercent
        //             running: isNaN(api.device.batteryPercent) ? false : showPercent
        //             triggeredOnStart: isNaN(api.device.batteryPercent) ? "" : showPercent
        //             onTriggered: batteryPercentage.set()
        //         }

        //         color: theme.text
        //         font.family: titleFont.name
        //         font.weight: Font.Bold
        //         font.letterSpacing: 1
        //         font.pixelSize: Math.round(screenheight*0.0277)
        //         horizontalAlignment: Text.Right
        //         Component.onCompleted: font.capitalization = Font.SmallCaps
        //         //font.capitalization: Font.SmallCaps
        //         visible: isNaN(api.device.batteryPercent) ? false : showPercent
        //     }

        //     BatteryIcon{
        //         id: batteryIcon
        //         width: height * 1.5
        //         height: sysTime.paintedHeight
        //         layer.enabled: true
        //         layer.effect: ColorOverlay {
        //             color: theme.text
        //             antialiasing: true
        //             cached: true
        //         }

        //         function set() {
        //             batteryIcon.level = platformScreenContainer.batteryStatus;
        //         }

        //         Timer {
        //             id: iconTimer
        //             interval: 60000 // Run the timer every minute
        //             repeat: true
        //             running: true
        //             triggeredOnStart: true
        //             onTriggered: batteryIcon.set()
        //         }

        //         visible: isNaN(api.device.batteryPercent) ? false : true

                
        //     }

        //     Image{
        //         id: chargingIcon

        //         property bool chargingStatus: api.device.batteryCharging

        //         width: height/2
        //         height: sysTime.paintedHeight
        //         fillMode: Image.PreserveAspectFit
        //         source: "../assets/images/charging.svg"
        //         sourceSize.width: 32
        //         sourceSize.height: 64
        //         smooth: true
        //         horizontalAlignment: Image.AlignLeft
        //         visible: chargingStatus && batteryIcon.level < 99
        //         layer.enabled: true
        //         layer.effect: ColorOverlay {
        //             color: theme.text
        //             antialiasing: true
        //             cached: true
        //         }

        //         function set() {
        //             chargingStatus = api.device.batteryCharging;
        //         }

        //         Timer {
        //             id: chargingIconTimer
        //             interval: 10000 // Run the timer every minute
        //             repeat: isNaN(api.device.batteryPercent) ? false : true
        //             running: isNaN(api.device.batteryPercent) ? false : true
        //             triggeredOnStart: isNaN(api.device.batteryPercent) ? false : true
        //             onTriggered: chargingIcon.set()
        //         }

        //     }

        // }

        // Platform menu
        PlatformBar
        {
            id: platformSwitcher
            anchors 
            {
                left: parent.left; leftMargin: vpx(98)
                right: parent.right
                top: topbar.bottom;
            }
            height: Math.round(screenheight * 0.3555)
            focus: true
        }

        // Button menu
        RowLayout {
            id: buttonMenu
            spacing: vpx(22)

            anchors { 
                top: parent.top;//platformSwitcher.bottom;
                bottom: platformSwitcher.top;//parent.bottom
            }
            
            x: parent.width/2 - buttonMenu.width/2
            //THESE ARE BUTTONS FOR MAIN MENU
            MenuButton {
                Image
                {
                    id: libraryIcon
                    width: parent.width / 1.75 //2.5
                    height: width
                    source: "../assets/images/allsoft_icon.svg"
                    sourceSize.width: vpx(120)
                    sourceSize.height: vpx(120)
                    z: 100
                    x: width/2.75 //3.75
                    y: width/2.75 //3.75

                    //anchors {
                    //    top: parent.top; topMargin: Math.round(screenheight*0.0416)
                    //    left: parent.left; leftMargin: vpx(38)
                    //}
                }

                id: libraryButton
                width: vpx(86); height: width;//vpx(86) 
                label: "Library";

                Keys.onPressed: {
                    if (api.keys.isAccept(event)) {
                        event.accepted = true;

                        showSoftwareScreen();
                    }
                
                }

                onClicked: { 
                    if (focus == false)
                    {
                        focus = true;
                        platformSwitcher.focus = false;
                        navSound.play();
                    }
                    else
                    {
                        showSoftwareScreen();
                    }
                }
            }
                                //Not yet implemented
            MenuButton {
                Image
                {
                    id: settingsIcon
                    width: parent.width / 1.75 //2.5
                    height: width
                    source: "../assets/images/settings_icon.png"
                    sourceSize.width: vpx(120)
                    sourceSize.height: vpx(120)
                    z: 100
                    x: width/2.75 //3.75
                    y: width/2.75 //3.75

                    //anchors {
                    //    top: parent.top; topMargin: Math.round(screenheight*0.0416)
                    //    left: parent.left; leftMargin: vpx(38)
                    //}
                }

                id: settingsButton
                width: vpx(86); height: vpx(86)
                label: "Settings";

                Keys.onPressed: {
                    if (api.keys.isAccept(event)) {
                        event.accepted = true;
                        showSettingsScreen();
                    }
                }

                onClicked: { 
                    if (focus == false)
                    {
                        focus = true;
                        platformSwitcher.focus = false;
                        navSound.play();
                    }
                    else
                    {
                        showSettingsScreen();
                    }
                }
            }
        }

        //Up / Down + Top Bar Navigation
        //Unfortunately most of this is hard coded but it could be adapted to be dynamic in the future
        function goToPlatformSwitcher(platformSwitcher){
            if (platformSwitcher.focus == false) {
                navSound.play(); platformSwitcher.focus = true; libraryButton.focus = false;
            }
        }
        function goToTopBar(platformSwitcher){
            if (platformSwitcher.focus == true) {
                navSound.play(); platformSwitcher.focus = false; libraryButton.focus = true;
            }
        }
        function goToSettings(libraryButton, settingsButton){
            if (libraryButton.focus == true) {
                navSound.play(); libraryButton.focus = false; settingsButton.focus = true;
            }
        }
        function goToLibrary(libraryButton, settingsButton){
            if (settingsButton.focus == true) {
                navSound.play(); libraryButton.focus = true; settingsButton.focus = false;
            }
        }

        //Run Functions
        Keys.onUpPressed: goToTopBar(platformSwitcher); // somehow move up to settings banner
        Keys.onRightPressed: goToSettings(libraryButton, settingsButton);
        Keys.onLeftPressed: goToLibrary(libraryButton, settingsButton);
        Keys.onDownPressed: goToPlatformSwitcher(platformSwitcher);
    }    
}
