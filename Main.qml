import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import QtQuick.Window 2.15

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "black"

    property real scaleFactor: Math.min(width / 1920, height / 1080)

    FontLoader {
        id: pixelFont
        source: "Dot.ttf"
    }

    Image {
        id: background
        source: "background.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: clock
        font.pixelSize: 100 * scaleFactor
        font.family: pixelFont.name
        color: "white"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 150 * scaleFactor
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date();
            var hours = date.getHours();
            var minutes = date.getMinutes();
            clock.text = (hours < 10 ? "0" : "") + hours + ":" + (minutes < 10 ? "0" : "") + minutes;
        }
    }

    Rectangle {
        id: avatarContainer
        width: 250 * scaleFactor
        height: 250 * scaleFactor
        radius: 50 * scaleFactor
        color: "transparent"
        border.color: "#aa3333"
        border.width: 4 * scaleFactor
        anchors.top: clock.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 100 * scaleFactor

        Image {
            id: avatar
            width: parent.width - 20 * scaleFactor
            height: parent.height - 20 * scaleFactor
            source: "user.jpg"  // Auto-load user avatar
            visible: true
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: avatar.width
                    height: avatar.height
                    radius: 25 * scaleFactor // Make the mask circular
                    visible: false
                }
            }
        }
    }

    Text {
        id: welcome
        text: "welcome " + (userModel.lastUser || "User")
        font.pixelSize: 40 * scaleFactor
        font.family: pixelFont.name
        color: "white"
        anchors.top: avatarContainer.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50 * scaleFactor
    }

    Column {
        id: loginForm
        anchors.top: welcome.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50 * scaleFactor
        spacing: 20 * scaleFactor

        Rectangle {
            width: 300 * scaleFactor
            height: 50 * scaleFactor
            color: "#aa3333"
            border.color: "#aa3333"
            border.width: 3 * scaleFactor
            radius: 25 * scaleFactor
            TextField {
                id: username
                placeholderText: "Username"
                text: userModel.lastUser || ""
                width: parent.width - 20 * scaleFactor
                font.pixelSize: 26 * scaleFactor
                font.family: pixelFont.name
                color: "white"
                background: Rectangle { color: "transparent" }
                anchors.centerIn: parent
                leftPadding: 15 * scaleFactor

                // Auto-focus on password field when Enter/Return is pressed
                Keys.onReturnPressed: {
                    password.focus = true; // Focus on password field
                }
                Keys.onEnterPressed: {
                    password.focus = true; // Focus on password field
                }
            }
        }

        Rectangle {
            width: 300 * scaleFactor
            height: 50 * scaleFactor
            color: "#aa3333"
            border.color: "#aa3333"
            border.width: 3 * scaleFactor
            radius: 25 * scaleFactor
            TextField {
                id: password
                placeholderText: "Password"
                echoMode: TextInput.Password
                width: parent.width - 20 * scaleFactor
                font.pixelSize: 26 * scaleFactor
                font.family: pixelFont.name
                color: "white"
                background: Rectangle { color: "transparent" }
                anchors.centerIn: parent
                leftPadding: 15 * scaleFactor
                focus: true // Automatically focus on the password field when the screen loads

                // Trigger login when Enter/Return is pressed in the password field
                Keys.onReturnPressed: login()
                Keys.onEnterPressed: login()
            }
        }
    }

    property int sessionIndex: sessionSelector.currentIndex

    Connections {
        target: sddm
        function onLoginSucceeded() {
            console.log("Login succeeded.");
        }
        function onLoginFailed() {
            console.log("Login failed.");
            password.text = "";
        }
    }

   ComboBox {
        id: sessionSelector
        width: 300 * scaleFactor
        height: 50 * scaleFactor
        font.pixelSize: 26 * scaleFactor
        font.family: pixelFont.name
        model: sessionModel
        currentIndex: model.lastIndex
        
        anchors.top: loginForm.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20 * scaleFactor

        // Style the ComboBox
          background: Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 100 * scaleFactor
            width: 60 * scaleFactor
            height: 60 * scaleFactor
            Text {
                text: "⠶>"
                color: "#aa3333"
                font.pixelSize: 30 * scaleFactor
                font.family: pixelFont.name
                anchors.centerIn: parent
            }
        }

        contentItem: Text {
            text: sessionSelector.currentText
            font: sessionSelector.font
            color: "white"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: 15 * scaleFactor
        }

        popup: Popup {
            y: sessionSelector.height
            width: sessionSelector.width
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
                currentIndex: sessionSelector.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                color: "black"
                border.color: "#aa3333"
                border.width: 3 * scaleFactor
                radius: 15 * scaleFactor
            }
            
        }

        delegate: ItemDelegate {
            width: 800 * scaleFactor
            height: 50 * scaleFactor
            contentItem: Text {
                text: model.name
                font: sessionSelector.font
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 15 * scaleFactor
            }
            background: Rectangle {
                color: parent.highlighted ? "#aa3333" : "transparent"
                radius: 15 * scaleFactor
            }
        }

        indicator {
            visible: false
        }
    }

    function login() {
        console.log("Starting session:", sessionIndex);
        sddm.login(username.text, password.text, sessionIndex);
    }
}
