import QtQuick 2.15
import QtQuick.Controls.Basic
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

    property bool collapsed: false
    property real collapse: 0

    property double chatTopMargin: 50 - 20 * root.collapse
    property double chatLeftMargin: 160 + 40 * root.collapse
    property double chatRightMargin: 160 + 40 * root.collapse
    height: 60 - 10 * root.collapse

    NumberAnimation{
        id: collapseAnim
        target: root
        property: "collapse"
        easing.type: Easing.InOutCubic
    }

    onCollapsedChanged: {
        collapseAnim.stop()
        collapseAnim.duration = collapsed ? 800 : 400
        collapseAnim.to = collapsed ? 1 : 0
        collapseAnim.start()
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
        radius: 30
        opacity: 1 - 0.6 * root.collapse

        Rectangle{
            id: chatInfoTop
            anchors.fill: parent
            anchors.margins: 10
            color: Qt.alpha(mainColor, opacityPanels)
            radius: 30

            opacity: 1 - 1 * root.collapse
        }

        Text{
            text: connectionStatus
            font: appTextFont
            color: textColor

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            x: 20 * (1 - root.collapse) + (parent.width - width) / 2 * root.collapse
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
        interval: 2500
        running: true
        onTriggered: root.collapsed = true
    }
}