import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects

Item{
    id: root

    height: 52

    property bool isEmpty: regField.text.trim().length === 0
    property color panelsColor
    property color mainColor
    property color textColor
    property color borderColor
    property int marginChatsField
    property double opacityPanels
    property font appTextFont
    property real borderOpacity: borderIdleOpacity
    property double borderIdleOpacity
    property double opacityMenu
    property font appSmallFont
    readonly property bool highlighted: hoverHandler.hovered
                                        || regField.activeFocus
                                        || contextMenu.visible

    signal sendRequested(string message)

    function focusField(){
        regField.forceActiveFocus()
    }

    onHighlightedChanged: {
        borderAnimation.stop()
        borderAnimation.to = root.highlighted ? 1 : borderIdleOpacity
        borderAnimation.duration = 150
        borderAnimation.start()
    }

    HoverHandler{
        id: hoverHandler
    }

    function send(){
        if (isEmpty){
            return
        }

        sendRequested(regField.text.trim())
    }

    RectangularShadow{
        id: rectShadow

        anchors.fill: parent


        radius: rectBottom.radius
        blur: 30
        spread: 5
        color: Qt.rgba(0, 0, 0, opacityPanels - 0.3)
    }

    NumberAnimation{
        id: borderAnimation
        target: root
        property: "borderOpacity"
        easing.type: Easing.OutCubic
    }

    Rectangle{
        id: rectBottom
        anchors.fill: parent

        color: Qt.alpha(panelsColor, opacityPanels)
        radius: root.height / 2

        border.width: 1
        border.color: Qt.alpha(borderColor, borderOpacity)

        Rectangle {
            id: rectBottomTop
            anchors.fill: parent
            anchors.margins: 6
            color: Qt.alpha(mainColor, opacityPanels)
            radius: root.height / 2
        }

        TextField{
            id: regField

            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.verticalCenter: parent.verticalCenter

            background: null

            rightPadding: 10
            maximumLength: 30

            font: appTextFont
            color: textColor

            placeholderText: "Nickname"
            placeholderTextColor: Qt.alpha(textColor, 0.6)

            ContextMenu.menu: ChatMenu{
                id: contextMenu

                mainColor: root.mainColor
                textColor: root.textColor
                borderColor: root.borderColor
                opacityPanels: root.opacityPanels
                opacityMenu: root.opacityMenu
                appTextFont: root.appTextFont
                appSmallFont: root.appSmallFont
                borderIdleOpacity: root.borderIdleOpacity
                marginChatsField: root.marginChatsField

                implicitWidth: 180

                Action{
                    text: "Cut"
                    property string shortcutText: "Ctrl+X"
                    enabled: regField.selectedText.length > 0
                    onTriggered: regField.cut()
                }
                Action{
                    text: "Copy"
                    property string shortcutText: "Ctrl+C"
                    enabled: regField.selectedText.length > 0
                    onTriggered: regField.copy()
                }
                Action{
                    text: "Paste"
                    property string shortcutText: "Ctrl+V"
                    enabled: regField.canPaste
                    onTriggered: regField.paste()
                }
                Action{
                    text: "Select All"
                    property string shortcutText: "Ctrl+A"
                    enabled: regField.length > 0
                    onTriggered: regField.selectAll()
                }
            }

            onAccepted: root.send()
        }

        Text{
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            text: regField.maximumLength - regField.length
            color: regField.maximumLength - regField.length <= 5 ? Qt.alpha("#FF323C", 0.8) : Qt.alpha(textColor, 0.6)
            font: appSmallFont

            Behavior on color{
                ColorAnimation{
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}