import QtQuick 2.15
import QtQuick.Effects

Item{
    id: root

    property color panelsColor
    property color mainColor
    property color textColor
    property color borderColor
    property double opacityPanels
    property font appTextFont
    property string connectionStatus
    property int marginChatsField

    property bool collapsed: false
    property real collapse: collapsed ? 1 : 0

    property double chatTopMargin: 35 - 20 * root.collapse
    property double chatLeftMargin: 160 + 60 * root.collapse
    property double chatRightMargin: 160 + 60 * root.collapse
    property bool isAppShown
    property int startupDuration

    opacity: isAppShown ? 1 : 0
    height: 50 - 10 * root.collapse

    Behavior on collapse{
        NumberAnimation{
            duration: root.collapsed ? 800 : 500
            easing.type: Easing.OutCubic
        }
    }

    RectangularShadow{
        id: rectShadow

        anchors.fill: chatInfoBottom

        radius: chatInfoBottom.radius
        blur: 30
        spread: 5
        color: Qt.rgba(0, 0, 0, opacityPanels - 0.1)

        opacity: 1 - 1 * root.collapse
    }

    Rectangle{
        id: chatInfoBottom
        anchors.fill: parent

        color: Qt.alpha(panelsColor, opacityPanels)
        radius: root.height / 2
        opacity: 1 - 0.6 * root.collapse

        Rectangle{
            id: chatInfoTop
            anchors.fill: parent
            anchors.margins: root.marginChatsField
            color: Qt.alpha(mainColor, opacityPanels)
            radius: chatInfoBottom.radius - root.marginChatsField

            opacity: 1 - 1 * root.collapse
        }

        Text{
            text: connectionStatus
            font: appTextFont
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        HoverHandler{
            id: hoverHandler

            onHoveredChanged: {
                if (hovered){
                    hideTimer.stop()
                    root.collapsed = false
                }
                else{
                    hideTimer.restart()
                }
            }
        }
    }

    Timer{
        id: hideTimer
        interval: 400
        running: isAppShown
        onTriggered: root.collapsed = true
    }
}