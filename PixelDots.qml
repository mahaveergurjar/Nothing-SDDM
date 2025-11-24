import QtQuick 2.15

Row {
    id: root
    
    // Properties to control the appearance
    property int dotCount: 0
    property color dotColor: "#f2e7d5"
    property color animColor: "#f4c16e" // Kept for compatibility, though unused now

    spacing: 14

    Repeater {
        model: root.dotCount

        delegate: Item {
            id: charItem
            width: 14
            height: 14
            
            // Randomize shape based on index
            property int shapeType: index % 5 

            Canvas {
                id: shapeCanvas
                anchors.centerIn: parent
                width: 16
                height: 16
                
                // Set static properties (Animation removed)
                opacity: 1
                scale: 1
                
                // Rotation for some shapes
                rotation: shapeType === 1 ? 45 : 0 // Rotate Diamond

                // Set color directly to the final color
                property color currentColor: root.dotColor

                onCurrentColorChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = shapeCanvas.currentColor;

                    var cx = width / 2;
                    var cy = height / 2;
                    var r = width / 2;

                    ctx.beginPath();
                    
                    if (shapeType === 0) { 
                        // Circle
                        ctx.arc(cx, cy, r, 0, Math.PI * 2);
                    } else if (shapeType === 1) { 
                        // Square / Diamond (rotated via item property)
                        ctx.rect(0, 0, width, height); 
                    } else if (shapeType === 2) { 
                        // Triangle
                        ctx.moveTo(cx, 0);
                        ctx.lineTo(width, height);
                        ctx.lineTo(0, height);
                        ctx.closePath();
                    } else if (shapeType === 3) { 
                        // Clover / Cloud (4 circles)
                        var kr = r * 0.6;
                        ctx.arc(cx - kr/2, cy - kr/2, kr, 0, Math.PI * 2);
                        ctx.arc(cx + kr/2, cy - kr/2, kr, 0, Math.PI * 2);
                        ctx.arc(cx - kr/2, cy + kr/2, kr, 0, Math.PI * 2);
                        ctx.arc(cx + kr/2, cy + kr/2, kr, 0, Math.PI * 2);
                    } else { 
                        // Star / Burst
                        ctx.moveTo(cx, 0);
                        ctx.lineTo(width * 0.8, height);
                        ctx.lineTo(0, height * 0.4);
                        ctx.lineTo(width, height * 0.4);
                        ctx.lineTo(width * 0.2, height);
                        ctx.closePath();
                    }
                    
                    ctx.fill();
                }
            }
        }
    }
}