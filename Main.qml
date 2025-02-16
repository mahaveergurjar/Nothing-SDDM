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
            layer.enabled: true
            layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: avatar.width
                height: avatar.height
                radius: 25 // Make the mask circular
                visible: false // Hide the mask itself
            }
            }
        }

    }

    Text {
        id: welcome
        text: "WELCOME " + (userModel.lastUser || "USER")  // Auto-load username
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
                text: userModel.lastUser || ""  // Auto-fill username field
                width: parent.width - 20
                font.pixelSize: 26
                font.family: pixelFont.name
                color: "white"
                background: Rectangle { color: "transparent" }
                anchors.centerIn: parent
                leftPadding: 15

                // Handle Enter key press
                Keys.onReturnPressed: {
                    login();
                }
                Keys.onEnterPressed: {
                    login();
                }
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

                // Handle Enter key press
                Keys.onReturnPressed: {
                    login();
                }
                Keys.onEnterPressed: {
                    login();
                }
            }
        }
    }

    property string defaultSession: "hyprland.desktop" // Fallback session
    property string selectedSession: sessionSelector.currentText || defaultSession

    Connections {
        target: sddm
        function onLoginSucceeded() {
            console.log("Login succeeded.");
        }
        function onLoginFailed() {
            console.log("Login failed.");
            password.text = ""; // Clear the password field on failure
        }
    }

    ComboBox {
        id: sessionSelector
        width: 400
        height: 50
        font.pixelSize: 26
        font.family: pixelFont.name
        model: sessionModel
        textRole: "name" // Display the session name
        currentIndex: sessionModel.lastIndex
        anchors.top: loginForm.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20

        // Style the ComboBox
        background: Rectangle {
            color: "transparent"
            border.color: "#aa3333"
            border.width: 3
            radius: 15
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
            width: sessionSelector.width
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
    }

    Button {
        id: loginButton
        width: 80
        height: 80
        background: Rectangle {
            color: "white"
            radius: 55
        }
        contentItem: Text {
            text: "⠶>"
            font.pixelSize: 40
            color: "#aa3333"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        anchors.top: sessionSelector.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20

        onClicked: {
            login();
        }
    }

    // Function to handle login logic
    function login() {
        selectedSession = sessionSelector.currentText || defaultSession;
        console.log("Login attempt:", username.text, password.text, selectedSession);

        if (username.text.length === 0 || password.text.length === 0) {
            console.log("Username or password is empty.");
            return;
        }

        if (!selectedSession || selectedSession.length === 0) {
            console.log("Selected session is invalid. Using fallback:", defaultSession);
            selectedSession = defaultSession;
        }

        console.log("Starting session:", selectedSession);
        sddm.login(username.text, password.text, selectedSession);
    }
}