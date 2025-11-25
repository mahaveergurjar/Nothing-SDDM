import QtQuick 2.15

Row {
    id: root
    
    // --- Properties ---
    property int dotCount: 0
    property color dotColor: "#f2e7d5"
    
    // Keeps SDDM happy (prevents "non-existent property" error)
    property color animColor: "#f4c16e" 

    spacing: 14
    
    // Center the entire row of dots
    anchors.horizontalCenter: parent.horizontalCenter

    Repeater {
        model: root.dotCount

        delegate: Item {
            id: charItem
            width: 20
            height: 20
            
            // Animation removed. Scale is static 1.
            scale: 1 

            // --- SHAPE SELECTION (8 types) ---
            property int shapeType: index % 8 

            Canvas {
                id: shapeCanvas
                anchors.centerIn: parent
                width: 26
                height: 26
                
                property color currentColor: root.dotColor
                onCurrentColorChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = shapeCanvas.currentColor;

                    var cx = width / 2;
                    var cy = height / 2;
                    var baseSize = width * 0.9; 

                    ctx.beginPath();
                    
                    if (shapeType === 0) { 
                        // 1. Circle
                        var r = baseSize / 2; 
                        ctx.arc(cx, cy, r, 0, Math.PI * 2);

                    } else if (shapeType === 1) { 
                        // 2. Diamond
                        var dSize = baseSize * 1.1; 
                        var half = dSize / 2;
                        ctx.moveTo(cx, cy - half);
                        ctx.lineTo(cx + half, cy);
                        ctx.lineTo(cx, cy + half);
                        ctx.lineTo(cx - half, cy);
                        ctx.closePath();

                    } else if (shapeType === 2) { 
                        // 3. Triangle
                        var tSize = baseSize * 1.15;
                        var tHeight = (Math.sqrt(3)/2) * tSize;
                        var yOffset = tHeight / 6; 
                        ctx.moveTo(cx, cy - (tHeight/2) - yOffset);
                        ctx.lineTo(cx + (tSize/2), cy + (tHeight/2) - yOffset);
                        ctx.lineTo(cx - (tSize/2), cy + (tHeight/2) - yOffset);
                        ctx.closePath();

                    } else if (shapeType === 3) { 
                        // 4. Squircle (Pixel Style)
                        var sqSize = baseSize * 0.85; 
                        var offset = sqSize / 2;
                        var radius = sqSize * 0.4; 
                        ctx.moveTo(cx - offset + radius, cy - offset);
                        ctx.lineTo(cx + offset - radius, cy - offset);
                        ctx.quadraticCurveTo(cx + offset, cy - offset, cx + offset, cy - offset + radius);
                        ctx.lineTo(cx + offset, cy + offset - radius);
                        ctx.quadraticCurveTo(cx + offset, cy + offset, cx + offset - radius, cy + offset);
                        ctx.lineTo(cx - offset + radius, cy + offset);
                        ctx.quadraticCurveTo(cx - offset, cy + offset, cx - offset, cy + offset - radius);
                        ctx.lineTo(cx - offset, cy - offset + radius);
                        ctx.quadraticCurveTo(cx - offset, cy - offset, cx - offset + radius, cy - offset);
                        ctx.closePath();

                    } else if (shapeType === 4) { 
                        // 5. Star
                        var outerRadius = baseSize * 0.75; 
                        var innerRadius = baseSize * 0.32; 
                        var spikes = 5;
                        var step = Math.PI / spikes;
                        var rot = Math.PI / 2 * 3;
                        var x = cx; var y = cy;
                        ctx.moveTo(cx, cy - outerRadius);
                        for (var i = 0; i < spikes; i++) {
                            x = cx + Math.cos(rot) * outerRadius;
                            y = cy + Math.sin(rot) * outerRadius;
                            ctx.lineTo(x, y);
                            rot += step;
                            x = cx + Math.cos(rot) * innerRadius;
                            y = cy + Math.sin(rot) * innerRadius;
                            ctx.lineTo(x, y);
                            rot += step;
                        }
                        ctx.lineTo(cx, cy - outerRadius);
                        ctx.closePath();

                    } else if (shapeType === 5) {
                        // 6. Pentagon
                        var pRadius = baseSize * 0.55;
                        var pAngle = (Math.PI * 2) / 5;
                        var startAngle = -Math.PI / 2; 
                        ctx.moveTo(cx + pRadius * Math.cos(startAngle), cy + pRadius * Math.sin(startAngle));
                        for (var i = 1; i <= 5; i++) {
                            ctx.lineTo(cx + pRadius * Math.cos(startAngle + i * pAngle), 
                                       cy + pRadius * Math.sin(startAngle + i * pAngle));
                        }
                        ctx.closePath();

                    } else if (shapeType === 6) {
                        // 7. Hexagon
                        var hRadius = baseSize * 0.5;
                        var hAngle = (Math.PI * 2) / 6;
                        var hStart = -Math.PI / 2; 
                        ctx.moveTo(cx + hRadius * Math.cos(hStart), cy + hRadius * Math.sin(hStart));
                        for (var i = 1; i <= 6; i++) {
                            ctx.lineTo(cx + hRadius * Math.cos(hStart + i * hAngle), 
                                       cy + hRadius * Math.sin(hStart + i * hAngle));
                        }
                        ctx.closePath();

                    } else {
                        // 8. Flower / Scallop
                        var fRadius = baseSize * 0.5;
                        var petals = 8;
                        var step = (Math.PI * 2) / petals;
                        
                        for (var i = 0; i < petals; i++) {
                            var theta1 = i * step;
                            var theta2 = (i + 1) * step;
                            
                            var cpRadius = fRadius * 1.25; 
                            var cpTheta = (theta1 + theta2) / 2;

                            var startX = cx + fRadius * Math.cos(theta1);
                            var startY = cy + fRadius * Math.sin(theta1);
                            var endX = cx + fRadius * Math.cos(theta2);
                            var endY = cy + fRadius * Math.sin(theta2);
                            var cpX = cx + cpRadius * Math.cos(cpTheta);
                            var cpY = cy + cpRadius * Math.sin(cpTheta);

                            if (i === 0) ctx.moveTo(startX, startY);
                            ctx.quadraticCurveTo(cpX, cpY, endX, endY);
                        }
                        ctx.closePath();
                    }
                    
                    ctx.fill();
                }
            }
        }
    }
}