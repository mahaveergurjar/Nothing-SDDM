import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: kbd
    width: parent.width
    height: 320 // Taller for comfortable typing
    color: "#1e120a" // Deep background color (Material Surface)
    radius: 24       // Rounded top corners
    
    // Signal for Main.qml to handle
    signal keyClicked(string key)
    signal backspaceClicked()
    signal enterClicked()

    property bool showSymbols: false
    property bool isShifted: false
    
    // Material Design 3 Style Palette
    property color keyBgColor: "#452f1e"        // Standard keys (Surface Container)
    property color funcBgColor: "#2c1b0d"       // Function keys (Surface)
    property color accentColor: "#f4c16e"       // Active/Enter (Primary)
    property color accentTextColor: "#1e120a"   // Text on Accent (Renamed from onAccentColor to avoid QML conflict)
    property color textColor: "#f2e7d5"         // Text on Standard keys

    // Compatibility aliases for Main.qml
    // These ensure Main.qml can still set properties like 'activeColor' and 'btnColor'
    // without causing "non-existent property" errors.
    property alias activeColor: kbd.accentColor 
    property alias btnColor: kbd.keyBgColor
    
    // Key definition helper
    component KeyButton: Rectangle {
        id: keyBtn
        property string label: ""
        property string shiftLabel: label.toUpperCase()
        property string symLabel: "" 
        property real keyWidth: 1
        
        Layout.fillHeight: true
        Layout.fillWidth: true 
        Layout.preferredWidth: keyWidth
        
        // Material visual style: lightens when pressed
        color: inputArea.pressed ? Qt.lighter(keyBgColor, 1.4) : keyBgColor
        radius: 6

        Text {
            anchors.centerIn: parent
            text: {
                if (kbd.showSymbols && symLabel !== "") return symLabel
                if (kbd.isShifted) return shiftLabel
                return label
            }
            color: textColor
            font.pixelSize: 20
            font.family: "Noto Sans"
            font.weight: Font.Medium
        }

        MouseArea {
            id: inputArea
            anchors.fill: parent
            onClicked: {
                var output = keyBtn.label
                if (kbd.showSymbols && keyBtn.symLabel !== "") output = keyBtn.symLabel
                else if (kbd.isShifted) output = keyBtn.shiftLabel
                
                kbd.keyClicked(output)
            }
        }
    }

    // Functional Key helper (Backspace, Shift, Enter)
    component FuncButton: Rectangle {
        id: funcBtn
        property string icon: ""
        property string textLabel: ""
        property var action: null
        property bool active: false
        property bool isEnter: false // Special handling for Enter key
        
        Layout.fillHeight: true
        Layout.fillWidth: true 
        Layout.preferredWidth: isEnter ? 2.0 : 1.5 // Enter is wider
        
        // Logic for background color: 
        // 1. Enter key & Active toggles get accent color.
        // 2. Otherwise standard function dark color.
        color: {
            if (active || isEnter) return inputAreaFunc.pressed ? Qt.darker(accentColor, 1.1) : accentColor
            return inputAreaFunc.pressed ? Qt.lighter(funcBgColor, 1.4) : funcBgColor
        }
        
        radius: 12 // Rounder for function keys (Pill shape)

        Text {
            anchors.centerIn: parent
            text: icon !== "" ? icon : textLabel
            // Text color logic: Dark text on accent keys, Light text on dark keys
            color: (active || isEnter) ? accentTextColor : textColor
            font.pixelSize: isEnter ? 16 : 20
            font.family: "Noto Sans"
            font.bold: isEnter
        }

        MouseArea {
            id: inputAreaFunc
            anchors.fill: parent
            onClicked: if (action) action()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8 
        spacing: 10 

        // Row 1
        RowLayout {
            spacing: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            KeyButton { label: "q"; symLabel: "1" }
            KeyButton { label: "w"; symLabel: "2" }
            KeyButton { label: "e"; symLabel: "3" }
            KeyButton { label: "r"; symLabel: "4" }
            KeyButton { label: "t"; symLabel: "5" }
            KeyButton { label: "y"; symLabel: "6" }
            KeyButton { label: "u"; symLabel: "7" }
            KeyButton { label: "i"; symLabel: "8" }
            KeyButton { label: "o"; symLabel: "9" }
            KeyButton { label: "p"; symLabel: "0" }
        }

        // Row 2
        RowLayout {
            spacing: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            Item { Layout.preferredWidth: 0.5; Layout.fillWidth: true; Layout.fillHeight: true } 
            KeyButton { label: "a"; symLabel: "@" }
            KeyButton { label: "s"; symLabel: "#" }
            KeyButton { label: "d"; symLabel: "$" }
            KeyButton { label: "f"; symLabel: "%" }
            KeyButton { label: "g"; symLabel: "&" }
            KeyButton { label: "h"; symLabel: "-" }
            KeyButton { label: "j"; symLabel: "+" }
            KeyButton { label: "k"; symLabel: "(" }
            KeyButton { label: "l"; symLabel: ")" }
            Item { Layout.preferredWidth: 0.5; Layout.fillWidth: true; Layout.fillHeight: true } 
        }

        // Row 3
        RowLayout {
            spacing: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            FuncButton {
                icon: "⇧" // Shift
                active: kbd.isShifted
                action: function() { kbd.isShifted = !kbd.isShifted }
            }
            
            KeyButton { label: "z"; symLabel: "*" }
            KeyButton { label: "x"; symLabel: "\"" }
            KeyButton { label: "c"; symLabel: "'" }
            KeyButton { label: "v"; symLabel: ":" }
            KeyButton { label: "b"; symLabel: ";" }
            KeyButton { label: "n"; symLabel: "!" }
            KeyButton { label: "m"; symLabel: "?" }
            
            FuncButton {
                icon: "⌫" // Backspace
                action: function() { kbd.backspaceClicked() }
            }
        }

        // Row 4
        RowLayout {
            spacing: 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            FuncButton {
                textLabel: "?123"
                active: kbd.showSymbols
                action: function() { kbd.showSymbols = !kbd.showSymbols }
            }

            KeyButton { 
                label: ","
                symLabel: ","
                keyWidth: 1
            }

            KeyButton { 
                label: " "
                symLabel: " "
                keyWidth: 4 
            }

            KeyButton { 
                label: "."
                symLabel: "."
                keyWidth: 1
            }

            FuncButton {
                icon: "⏎" // Enter Icon
                isEnter: true // Makes it use accent color
                action: function() { kbd.enterClicked() }
            }
        }
    }
}