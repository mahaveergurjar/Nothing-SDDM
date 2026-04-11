import QtQuick 2.15
import SddmComponents 2.0
import QtGraphicalEffects 1.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 1920
    height: 1080

    // Timers & System Logic
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var d = new Date()
            timeLabel.text = Qt.formatDateTime(d, "hh:mm")
            dayLabel.text = Qt.formatDateTime(d, "ddd").toUpperCase()
            dateLabel.text = Qt.formatDateTime(d, "dd MMMM, yyyy")
            
            var hr = d.getHours()
            var greeting = "Good Evening"
            if (hr < 12) greeting = "Good Morning"
            else if (hr < 18) greeting = "Good Afternoon"
            
            greetingLabel.text = "<b> </b> " + greeting + ", mahaveer"
        }
    }

    // Wallpaper
    Image {
        id: bg
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
        }
    }

    FastBlur {
        id: bgBlur
        anchors.fill: bg
        source: bg
        radius: 64
        visible: false
    }

    Item {
        anchors.centerIn: parent

        // =======================
        // LEFT COLUMN (-200)
        // =======================

        // 1. LOGIN CARD
        BlurredCard {
            width: 360; height: 380; radius: 25
            blurSource: bgBlur
            absoluteX: 580; absoluteY: 190
            color: Qt.rgba(0, 0, 0, 0.3)
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -200
            anchors.verticalCenterOffset: -160

            Text {
                text: sddm.hostName
                color: "#B9AFA5"
                font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -140
            }
            Text {
                text: "Log in"
                color: "#F0E6DC"
                font.pixelSize: 42; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -80
            }
            
            // Username Dropdown Wrapper
            ComboBox {
                id: userListId
                width: 320; height: 70
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 30
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex

                background: Rectangle {
                    color: "#BA3D3D"
                    radius: 20
                }

                contentItem: Item {
                    Text {
                        text: "username <b></b>"
                        color: "#191414"
                        font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.leftMargin: 20
                    }
                    
                    Text {
                        text: "<b>" + userListId.currentText + "</b>"
                        color: "#191414"
                        font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.bottomMargin: 14
                        anchors.leftMargin: 20
                    }
                }

                delegate: ItemDelegate {
                    width: userListId.width
                    height: 50
                    contentItem: Text {
                        text: "<b>" + model.name + "</b>"
                        color: highlighted ? "#F0E6DC" : "#191414"
                        font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }
                    background: Rectangle {
                        color: parent.highlighted ? Qt.rgba(0,0,0,0.3) : "transparent"
                        radius: 15
                    }
                }

                popup: Popup {
                    y: userListId.height + 5
                    width: userListId.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 10

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: userListId.popup.visible ? userListId.delegateModel : null
                        currentIndex: userListId.highlightedIndex
                    }

                    background: Rectangle {
                        color: "#BA3D3D"
                        radius: 20
                        layer.enabled: true
                        layer.effect: DropShadow {
                            radius: 8
                            color: Qt.rgba(0,0,0,0.5)
                        }
                    }
                }
            }

            // Password Field Wrapper
            Rectangle {
                width: 320; height: 70; radius: 20
                color: "#BA3D3D"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 120
                z: 3

                Text {
                    text: "password"
                    color: "#191414"
                    font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.leftMargin: 20
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 8
                    anchors.topMargin: 25
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignLeft
                    color: "#191414"
                    font.pixelSize: 26; font.family: "JetBrainsMono Nerd Font"
                    font.letterSpacing: 4
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    focus: true
                    onAccepted: {
                        sddm.login(userListId.currentText, passwordInput.text, sessionListId.currentIndex)
                    }
                }
            }
        }

        // 2. CLOCK CARD
        BlurredCard {
            width: 360; height: 160; radius: 25
            blurSource: bgBlur
            absoluteX: 580; absoluteY: 600
            color: Qt.rgba(0, 0, 0, 0.3)
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -200
            anchors.verticalCenterOffset: 140

            Text {
                id: timeLabel
                text: "<b>00:00</b>"
                color: "#F0E6DC"
                font.pixelSize: 72; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -15
            }
            Text {
                id: greetingLabel
                text: "<b> </b> Welcome back, mahaveer"
                color: "#B9AFA5"
                font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 55
            }
        }

        // =======================
        // RIGHT COLUMN (200)
        // =======================

        // 3. PROFILE CARD
        BlurredCard {
            width: 360; height: 380; radius: 25
            blurSource: bgBlur
            absoluteX: 980; absoluteY: 190
            color: Qt.rgba(0, 0, 0, 0.3)
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 200
            anchors.verticalCenterOffset: -160
            z: 1

            Image {
                source: "file:///home/mahaveer/.config/hyprlock/wallpapers/me.jpeg"
                width: 120; height: 120
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -100
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: 120; height: 120; radius: 20
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 4
                    border.color: "#BA3D3D"
                    radius: 20
                }
            }

            Text {
                id: dayLabel
                text: "<b>DAY</b>"
                color: "#F0E6DC"
                font.pixelSize: 38; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 10
            }
            Text {
                id: dateLabel
                text: "Date"
                color: "#B9AFA5"
                font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 60
            }
        }

        // 4. SYSTEM CARD
        BlurredCard {
            width: 360; height: 320; radius: 25
            blurSource: bgBlur
            absoluteX: 980; absoluteY: 520
            color: Qt.rgba(35/255, 31/255, 31/255, 0.8)
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 200
            anchors.verticalCenterOffset: 140
            z: 10 

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 6
                samples: 12
                color: Qt.rgba(0, 0, 0, 0.5)
            }

            // Operating System Metadata
            Text {
                text: " <b></b> "
                color: "#BA3D3D"
                font.pixelSize: 22; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -130
            }
            Text {
                text: "Arch Linux"
                color: "#F0E6DC"
                font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -95
            }
            Text {
                text: sddm.hostName + " Environment"
                color: "#B9AFA5"
                font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -75
            }

            // Power Control Pill (Left)
            Rectangle {
                width: 150; height: 75; radius: 20
                color: "#CCA47C"
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -85
                anchors.verticalCenterOffset: -10
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.reboot()
                }
            }
            Text {
                text: "<b></b>"
                color: "#191414"
                font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -85
                anchors.verticalCenterOffset: -20
                z: 2
            }
            Text {
                text: "Restart"
                color: "#191414"
                font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -85
                anchors.verticalCenterOffset: 5
                z: 2
            }

            // Power Control Pill (Right)
            Rectangle {
                width: 150; height: 75; radius: 20
                color: "#CCA47C"
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 85
                anchors.verticalCenterOffset: -10
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.powerOff()
                }
            }
            Text {
                text: "<b></b>"
                color: "#191414"
                font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 85
                anchors.verticalCenterOffset: -20
                z: 2
            }
            Text {
                text: "Shutdown"
                color: "#191414"
                font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 85
                anchors.verticalCenterOffset: 5
                z: 2
            }

            // Session Selector Block
            Rectangle {
                width: 320; height: 100; radius: 25
                color: "#BA3D3D"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 95

                ComboBox {
                    id: sessionListId
                    anchors.fill: parent
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex

                    background: Rectangle {
                        color: "transparent"
                    }

                    contentItem: Item {
                        Text {
                            text: "Desktop Environment <b></b>"
                            color: "#191414"
                            font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 15
                        }
                        Text {
                            text: "<b>" + sessionListId.currentText + "</b>"
                            color: "#191414"
                            font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 10
                        }
                    }

                    delegate: ItemDelegate {
                        width: sessionListId.width
                        height: 50
                        contentItem: Text {
                            text: "<b>" + model.name + "</b>"
                            color: highlighted ? "#F0E6DC" : "#191414"
                            font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: parent.highlighted ? Qt.rgba(0,0,0,0.3) : "transparent"
                            radius: 15
                        }
                    }

                    popup: Popup {
                        y: sessionListId.height + 5
                        width: sessionListId.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 10

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: sessionListId.popup.visible ? sessionListId.delegateModel : null
                            currentIndex: sessionListId.highlightedIndex
                        }

                        background: Rectangle {
                            color: "#BA3D3D"
                            radius: 20
                            layer.enabled: true
                            layer.effect: DropShadow {
                                radius: 8
                                color: Qt.rgba(0,0,0,0.5)
                            }
                        }
                    }
                }
            }
            
            // SDDM Required Battery Connection Engine
            Connections {
                target: sddm
                function onLoginSucceeded() {}
                function onLoginFailed() {
                    passwordInput.text = ""
                    passwordInput.color = "#FF0000"
                }
            }
        }
    }
}
