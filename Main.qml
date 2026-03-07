import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2 // Aliased to prevent naming conflicts
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects 1.0
import SddmComponents 2.0
import "."

Item {
    id: root
    width: Screen.width
    height: Screen.height

    // --- SESSION STATE MANAGEMENT ---
    property int currentSessionIndex: 0
    property bool sessionOpen: false
    // New property for keyboard state
    property bool keyboardOpen: false 
    
    property alias password: passwordBox.text

    readonly property color baseColor: "#c1883e"
    readonly property color surfaceColor: "#2c1b0d"
    readonly property color accentColor: "#f4c16e"
    readonly property color textColor: "#f2e7d5"
    readonly property color mutedText: "#d6c3a1"
    readonly property color fieldColor: "#3a2616"
    readonly property real blurRadius: isNaN(Number(config.blurRadius)) ? 12 : Number(config.blurRadius)

    focus: true

    TextConstants { id: textConstants }

    // --- INITIALIZE SESSION ---
    Component.onCompleted: {
        // Initialize Session Index
        if (sessionModel.lastIndex !== undefined && sessionModel.lastIndex >= 0 && sessionModel.lastIndex < sessionModel.count) {
            currentSessionIndex = sessionModel.lastIndex;
        } else {
            currentSessionIndex = 0;
        }
    }

    // --- AUTO FOCUS PASSWORD ---
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: passwordBox.forceActiveFocus()
    }

    function attemptLogin() {
        if (userModel.count === 0) {
            return;
        }
        // Use the selectors to get the correct indices
        const userIdx = userSelector.currentIndex;
        const sessionIdx = sessionSelector.currentIndex;
        
        // Safety check
        if (userIdx < 0 || sessionIdx < 0) return;

        // Use safe fallback for username
        const username = userModel.get ? userModel.get(userIdx).name : userSelector.currentText;
        sddm.login(username, passwordBox.text, sessionIdx);
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passwordBox.text = "";
            infoLabel.text = textConstants.failedLoginLabel;
            infoLabel.opacity = 1;
            infoFade.restart();
        }
        function onInformationMessage(message) {
            infoLabel.text = message;
            infoLabel.opacity = 1;
            infoFade.restart();
        }
    }

    // --- HIDDEN HELPERS FOR MODEL ACCESS ---
    
    QQC2.ComboBox {
        id: sessionSelector
        visible: false
        model: sessionModel
        textRole: "name"
        // Bind to root state
        currentIndex: root.currentSessionIndex
    }

    QQC2.ComboBox {
        id: userSelector
        visible: false
        model: userModel
        textRole: "name"
        currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    }

    Image {
        id: background
        anchors.fill: parent
        z: 0
        fillMode: Image.PreserveAspectCrop
        source: config.background
        onStatusChanged: {
            if (status === Image.Error && source !== config.defaultBackground) {
                source = config.defaultBackground;
            }
        }
    }

    FastBlur {
        anchors.fill: parent
        radius: blurRadius
        source: background
        z: 0
    }


    // --- VIRTUAL KEYBOARD INTEGRATION ---
    VirtualKeyboard {
        id: virtualKeyboard
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: root.height * 0.35 // Take up 35% of screen height
        z: 100 // Ensure it's on top
        
        visible: root.keyboardOpen
        
        // Pass theme colors
        btnColor: "#3b2513"
        textColor: root.textColor
        activeColor: root.accentColor
        
        onKeyClicked: {
            passwordBox.text += key
            passwordBox.forceActiveFocus()
        }
        
        onBackspaceClicked: {
            if (passwordBox.text.length > 0) {
                passwordBox.text = passwordBox.text.substring(0, passwordBox.text.length - 1)
            }
            passwordBox.forceActiveFocus()
        }
        
        onEnterClicked: {
            attemptLogin()
        }
    }

    Column {
        id: centerColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        // Animate up when keyboard is open
        anchors.verticalCenterOffset: root.keyboardOpen ? -150 : 0
        
        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        spacing: 12
        z: 1

        AnalogBadge {
            id: analogBadge
            width: root.height > root.width ? root.width * 0.25 : root.height * 0.25
            height: width
            accent: accentColor
            surface: surfaceColor
            badgeLabel: Qt.formatDate(new Date(), "dd")
        }

        Rectangle {
            width: 120
            height: 36
            radius: 18
            color: surfaceColor
            opacity: 0.85
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: "  Locked"
                    color: textColor
                    font.pixelSize: 16
                }
            }
        }

        Text {
            id: infoLabel
            width: parent.width
            text: ""
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            opacity: 0
        }
        NumberAnimation {
            id: infoFade
            target: infoLabel
            property: "opacity"
            from: 1
            to: 0
            duration: 2500
            running: false
        }
    }

    ClockTicker {
        id: analogUpdater
        onTick: {
            analogBadge.updateHandAngles(time);
            analogBadge.badgeLabel = Qt.formatDate(time, "dd");
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        enabled: root.sessionOpen
        onClicked: root.sessionOpen = false
    }

    Row {
        id: toolbar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        // Animate up when keyboard is open
        anchors.bottomMargin: root.keyboardOpen ? root.height * 0.35 + 20 : 64
        
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

        spacing: 18
        z: 2

        function pill(widthOpt) {
            return Math.min(root.width * 0.28, widthOpt);
        }

        // --- LEFT PILL: USER & SESSION ---
        Rectangle {
            height: 64
            // Increased width slightly to accommodate longer names
            width: toolbar.pill(350) 
            radius: height / 2
            color: surfaceColor
            opacity: 0.96
            border.color: "#3b2513"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 24
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "\uF2BD"
                    font.family: "Noto Sans"
                    font.pixelSize: 34
                    color: "#cccccc"
                    verticalAlignment: Text.AlignVCenter
                }

                // USER SELECTOR DISPLAY
                Item {
                    id: userSelectorContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        // FIXED: Added right anchor to enforce clipping/elision
                        anchors.right: parent.right 
                        text: userSelector.currentText || ""
                        color: textColor
                        font.pixelSize: 16
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: userSelector.popup.open()
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 24
                    color: "#4e3725"
                }

                Text {
                    text: "\uF108"
                    font.family: "Noto Sans"
                    font.pixelSize: 34
                    color: "#cccccc"
                    verticalAlignment: Text.AlignVCenter
                }

                // SESSION SELECTOR DISPLAY
                Item {
                    id: sessionContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        // FIXED: Added right anchor to enforce clipping/elision within the pill
                        anchors.right: parent.right
                        text: sessionSelector.currentText || ""
                        color: textColor
                        font.pixelSize: 16
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.sessionOpen = !root.sessionOpen
                    }
                    
                    Rectangle {
                        id: sessionPopup
                        visible: root.sessionOpen
                        z: 100
                        width: 220
                        height: Math.min(sessionModel.count * 45, 300)
                        
                        color: surfaceColor
                        border.color: "#3b2513"
                        border.width: 1
                        radius: 12
                        
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 15
                        anchors.horizontalCenter: parent.horizontalCenter

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true
                            model: sessionModel
                            
                            delegate: Rectangle {
                                width: parent.width
                                height: 40
                                color: "transparent"
                                radius: 8
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#3b2513"
                                    opacity: 0.5
                                    visible: index === root.currentSessionIndex || itemMouse.containsMouse
                                    radius: 8
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: name 
                                    color: textColor
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        root.currentSessionIndex = index
                                        sessionSelector.currentIndex = index
                                        root.sessionOpen = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- MIDDLE PILL: PASSWORD & PIXEL DOTS ---
        Rectangle {
            id: passwordWrapper
            height: 64
            width: toolbar.pill(340)
            radius: height / 2
            color: surfaceColor
            opacity: 0.96
            border.color: "#3b2513"
            border.width: 1

            // 1. VISUAL LAYER: Container to constrain the PixelDots
            Item {
                id: dotContainer
                anchors.left: parent.left
                anchors.right: submitRect.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                // Margins ensure dots don't bleed into rounded corners or hit the submit button
                anchors.leftMargin: 24 
                anchors.rightMargin: 10
                clip: true 

                PixelDots {
                    id: pixelDots
                    anchors.centerIn: parent
                    
                    dotCount: passwordBox.text.length
                    
                    dotColor: root.textColor
                    animColor: root.accentColor
                }
            }

            // 2. INPUT LAYER: The PasswordBox
            PasswordBox {
                id: passwordBox
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: submitRect.left
                anchors.leftMargin: 24
                anchors.rightMargin: 10
                
                echoMode: TextInput.Password
                
                textColor: "transparent"
                radius: height 
                color: "transparent"
                borderColor: "transparent"
                focusColor: "transparent"
                hoverColor: "transparent"
                font.pixelSize: 18
                focus: true
                
                Keys.onReturnPressed: attemptLogin()
                Keys.onEnterPressed: attemptLogin()
            }

            // Placeholder Text
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: qsTr("Enter password")
                color: mutedText
                font.pixelSize: 16
                visible: passwordBox.text.length === 0
            }

            Rectangle {
                id: submitRect
                height: 52
                width: 52
                radius: height / 2
                color: accentColor
                
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 6
                
                Text {
                    anchors.centerIn: parent
                    text: "→"
                    color: surfaceColor
                    font.pixelSize: 22
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: attemptLogin()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // --- RIGHT PILL: POWER, BATTERY & KEYBOARD ---
        Rectangle {
            height: 64
            width: toolbar.pill(280) // Increased width for Keyboard Toggle
            radius: height / 2
            color: surfaceColor
            opacity: 0.96
            border.color: "#3b2513"
            border.width: 1
            
            RowLayout {
                anchors.centerIn: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 36
                Layout.alignment: Qt.AlignVCenter


                // KEYBOARD TOGGLE BUTTON
                MouseArea {
                    width: 24
                    height: 24
                    onClicked: root.keyboardOpen = !root.keyboardOpen
                    cursorShape: Qt.PointingHandCursor
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⌨" // Keyboard Unicode Icon
                        font.pixelSize: 24
                        color: root.keyboardOpen ? accentColor : "#cccccc"
                    }
                }

                MouseArea {
                    width: 24
                    height: 24
                    enabled: sddm.canSuspend
                    opacity: enabled ? 1 : 0.3
                    onClicked: sddm.suspend()
                    cursorShape: Qt.PointingHandCursor
                    Text {
                        anchors.centerIn: parent
                        text: "☾" 
                        font.pixelSize: 34
                        color: "#cccccc"
                    }
                }

                MouseArea {
                    width: 24
                    height: 24
                    onClicked: sddm.powerOff()
                    cursorShape: Qt.PointingHandCursor
                    Text {
                        anchors.centerIn: parent
                        text: "⏻" 
                        font.pixelSize: 34
                        color: "#cccccc"
                    }
                }

                MouseArea {
                    width: 24
                    height: 24
                    onClicked: sddm.reboot()
                    cursorShape: Qt.PointingHandCursor
                    Text {
                        anchors.centerIn: parent
                        text: "⟲" 
                        font.pixelSize: 34
                        color: "#cccccc"
                    }
                }

            }
        }
    }

}