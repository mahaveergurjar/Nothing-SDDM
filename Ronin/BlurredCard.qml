import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: control
    property int radius: 25
    property color color: Qt.rgba(0, 0, 0, 0.3)
    property var blurSource: null
    property real absoluteX: 0
    property real absoluteY: 0

    // The mask for the rounded corners
    Rectangle {
        id: mask
        anchors.fill: parent
        radius: control.radius
        visible: false
    }

    // The blurred background segment
    ShaderEffectSource {
        id: blurSourceItem
        sourceItem: control.blurSource
        sourceRect: Qt.rect(control.absoluteX, control.absoluteY, control.width, control.height)
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: blurSourceItem
        maskSource: mask
    }

    // The color overlay
    Rectangle {
        anchors.fill: parent
        radius: control.radius
        color: control.color
    }
}
