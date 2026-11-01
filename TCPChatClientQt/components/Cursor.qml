import QtQuick 2.15

Item{
    id: root

    readonly property real dpr: Screen.devicePixelRatio
    property color textColor
    property Item field

    Connections{
        target: root.field

        function onCursorPositionChanged(){
            root.restartCursor()
        }

        function onActiveFocusChanged(){
            root.restartCursor()
        }
    }

    function restartCursor(){
        cursorAnimation.stop()
        cursor.opacity = 0.9

        if (field.activeFocus){
            cursorAnimation.start()
        }
    }

    Rectangle{
        id: cursor

        x: Math.round(field.cursorRectangle.x * dpr) / dpr
        y: field.cursorRectangle.y

        width: Math.round(1 * dpr) / dpr
        height: field.cursorRectangle.height

        color: textColor
        visible: field.activeFocus

        opacity: 0.9

        Behavior on x{
            SmoothedAnimation{
                duration: 50
                velocity: -1
            }
        }
        Behavior on y{
            SmoothedAnimation{
                duration: 50
                velocity: -1
            }
        }

        SequentialAnimation on opacity{
            id: cursorAnimation

            running: false
            loops: Animation.Infinite

            PauseAnimation {
                duration: 500
            }
            NumberAnimation{
                to: 0
                duration: 150
                easing.type: Easing.OutCubic
            }
            PauseAnimation {
                duration: 500
            }
            NumberAnimation{
                to: 0.9
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}