import QtQuick 2.15

Item {
    id: ticker
    property date time: new Date()
    signal tick(date time)

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            ticker.time = new Date();
            ticker.tick(ticker.time);
        }
    }
}
