import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "black"

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
        font.pixelSize: 100
        font.family: pixelFont.name
        font.bold: true
        color: "white"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 80
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
        width: 250
        height: 250
        radius: 50
        color: "transparent"
        border.color: "#aa3333"
        border.width: 4
        anchors.top: clock.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50

        Image {
            id: avatar
            width: parent.width - 20
            height: parent.height - 20
            source: "user.jpg"  // Auto-load user avatar
            visible: true
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: avatar.width
                    height: avatar.height
                    radius: 25 // Make the mask circular
                    visible: false
                }
            }
        }
    }

    Text {
        id: welcome
        text: "Welcome " + (userModel.lastUser || "User")
        font.pixelSize: 50
        font.family: pixelFont.name
        font.bold: true
        color: "white"
        anchors.top: avatarContainer.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
    }

    Column {
        id: loginForm
        anchors.top: welcome.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
        spacing: 60

        Rectangle {
            width: 400
            height: 70
            color: "transparent"
            border.color: "#aa3333"
            border.width: 3
            radius: 15
            TextField {
                id: username
                placeholderText: "Username"
                text: userModel.lastUser || ""
                width: parent.width - 20
                font.pixelSize: 26
                font.family: pixelFont.name
                color: "white"
                background: Rectangle { color: "transparent" }
                anchors.centerIn: parent
                leftPadding: 15

                Keys.onReturnPressed: login()
                Keys.onEnterPressed: login()
            }
        }

        Rectangle {
            width: 400
            height: 70
            color: "transparent"
            border.color: "#aa3333"
            border.width: 3
            radius: 15
            TextField {
                id: password
                placeholderText: "Password"
                echoMode: TextInput.Password
                width: parent.width - 20
                font.pixelSize: 26
                font.family: pixelFont.name
                color: "white"
                background: Rectangle { color: "transparent" }
                anchors.centerIn: parent
                leftPadding: 15

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
        width: 400
        height: 50
        font.pixelSize: 26
        font.family: pixelFont.name
        model: sessionModel
        currentIndex: model.lastIndex
        
        anchors.top: loginForm.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20

        // Style the ComboBox
          background: Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 100
            width: 80
            height: 80
            Text {
                text: "⠶>"
                color: "#aa3333"
                font.pixelSize: 40
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
            leftPadding: 15
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
                border.width: 3
                radius: 15
            }
            
        }

        delegate: ItemDelegate {
            width: 800
            height: 50
            contentItem: Text {
                text: model.name
                font: sessionSelector.font
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 15
            }
            background: Rectangle {
                color: parent.highlighted ? "#aa3333" : "transparent"
                radius: 15
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
