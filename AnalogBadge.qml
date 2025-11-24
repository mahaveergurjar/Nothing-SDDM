import QtQuick 2.15

Item {
    id: badge
    // Updated colors to match the second image (Darker brown surface, green/beige hands)
    property color accent: "#f4c16e"       // Beige/Orange (for Hour hand & Dots)
    property color surface: "#653E00"      // Dark Brown (Background Cookie)
    property color minuteColor: "#a8cf9c"  // Light Green (for Minute hand)
    
    property real minuteAngle: 0
    property real hourAngle: 0
    property string badgeLabel: ""
    property real secondAngle: 0

    function updateHandAngles(now) {
        const minutes = now.getMinutes();
        const hours = now.getHours() % 12;
        const seconds = now.getSeconds();
        minuteAngle = (minutes / 60) * 360;
        hourAngle = ((hours + minutes / 60) / 12) * 360;
        secondAngle = (seconds / 60) * 360;
        canvas.requestPaint();
    }

    Component.onCompleted: {
        const now = new Date();
        updateHandAngles(now);
        if (badgeLabel === "") {
            badgeLabel = Qt.formatDate(now, "dd");
        }
        
        // Timer to keep the clock live
        let timer = Qt.createQmlObject("import QtQuick 2.0; Timer { interval: 1000; running: true; repeat: true; onTriggered: parent.updateHandAngles(new Date()) }", badge);
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true 
        z: 0 // FIX: Set to 0 so it stays in the background
        
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            const centerX = width / 2;
            const centerY = height / 2;
            
            // --- DRAW WAVY COOKIE SHAPE ---
            const bumps = 12; 
            const baseRadius = width * 0.45; 
            const waveAmplitude = width * 0.04; 

            ctx.beginPath();
            for (let i = 0; i <= 360; i++) {
                const theta = i * Math.PI / 180;
                const r = baseRadius + waveAmplitude * Math.cos(bumps * theta);
                const x = centerX + r * Math.cos(theta);
                const y = centerY + r * Math.sin(theta);
                
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            ctx.closePath();
            
            ctx.fillStyle = surface;
            ctx.fill();

            ctx.strokeStyle = "rgba(0,0,0,0.1)";
            ctx.lineWidth = 2;
            ctx.stroke();
        }
    }

    // --- DATE BADGE ---
    Rectangle {
        id: dayBadge
        width: parent.width * 0.22
        height: width * 0.6
        radius: height / 2
        color: "#8F6B3C" 
        z: 1 // FIX: Set to 1 so it sits ON TOP of the background
        
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.05 
        
        Text {
            anchors.centerIn: parent
            text: badge.badgeLabel
            color: "#C4AB8F"
            font.bold: true
            font.pixelSize: parent.height * 0.6
        }
    }

    Item {
        id: handHub
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        z: 2 // FIX: Set to 2 so hands are above date and background

        // --- MINUTE HAND ---
        Rectangle {
            id: minuteHand
            width: parent.width * 0.08
            height: parent.height * 0.42
            radius: width
            color: minuteColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            antialiasing: true
            z: 1 // Inside hub, this is bottom
            
            transformOrigin: Item.Bottom
            rotation: badge.minuteAngle
        }

        // --- HOUR HAND ---
        Rectangle {
            id: hourHand
            width: parent.width * 0.10
            height: parent.height * 0.28
            radius: width
            color: accent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            antialiasing: true
            z: 2 // Above minute hand
            
            transformOrigin: Item.Bottom
            rotation: badge.hourAngle
        }

        // --- CENTER DOT ---
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.10
            height: width
            radius: width / 2
            color: accent
            z: 3 // Topmost part of the hands
            
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.3
                height: width
                radius: width / 2
                color: surface
            }
        }
    }

    Item {
        id: secondDotOrbit
        anchors.fill: parent
        transformOrigin: Item.Center
        z: 2 // Same level as hands
        
        transform: Rotation {
            origin.x: secondDotOrbit.width / 2
            origin.y: secondDotOrbit.height / 2
            angle: badge.secondAngle - 90
        }

        Rectangle {
            id: secondDot
            width: parent.width * 0.07
            height: width
            radius: width / 2
            color: accent
            opacity: 1.0
            
            x: parent.width / 2 + parent.width * 0.32 - width / 2
            y: parent.height / 2 - height / 2
            antialiasing: true
        }
    }
}