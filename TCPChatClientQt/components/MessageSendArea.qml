import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects

Item{
    id: root

    property bool isEmpty: messageField.text.trim().length === 0
    property int minHeight: 54
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
    property double rightContentMargin
    readonly property bool highlighted: hoverHandler.hovered
                                        || messageField.activeFocus
                                        || contextMenu.visible
    readonly property double contentHeight: Math.max(minHeight, Math.min(200, messageField.implicitHeight +
    flick.anchors.topMargin + flick.anchors.bottomMargin))

    property bool isAppShown
    property int startupDuration

    opacity: isAppShown ? 1 : 0
    height: contentHeight

    Behavior on opacity{
        NumberAnimation{
            duration:  startupDuration
            easing.type: Easing.OutCubic
        }
    }

    signal sendRequested(string message)
    signal toButton()

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

        sendRequested(messageField.text)
        messageField.clear()
    }

    function focusFieldChat(){
        messageField.forceActiveFocus()
    }

    RectangularShadow{
        id: rectShadow

        anchors.fill: parent


        radius: rectBottom.radius
        blur: 25
        spread: 3
        color: Qt.rgba(0, 0, 0, opacityPanels - 0.3)
    }

    NumberAnimation{
        id: borderAnimation
        target: root
        property: "borderOpacity"
        easing.type: Easing.OutCubic
    }

    Behavior on height{
        NumberAnimation{
            duration: 75
        }
    }

    Rectangle{
        id: rectBottom
        anchors.fill: parent

        color: Qt.alpha(panelsColor, opacityPanels)
        radius: 27

        border.width: 1
        border.color: Qt.alpha(borderColor, borderOpacity)

        Behavior on opacity{
            NumberAnimation{
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: rectBottomTop
            anchors.fill: parent
            anchors.margins: marginChatsField
            color: mainColor
            radius: rectBottom.radius - marginChatsField
        }

        Flickable{
            id: flick

            anchors.left: parent.left

            anchors.right: parent.right
            anchors.rightMargin: rightContentMargin

            anchors.top: parent.top
            anchors.topMargin: 8

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8

            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar{
                id: sbar

                visible: root.height > root.minHeight

                contentItem: Rectangle{
                    implicitWidth: 4
                    radius: implicitWidth / 2
                    color: textColor
                    opacity: sbar.active ? 0.7 : 0

                    Behavior on opacity{
                        NumberAnimation{
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                background: null
            }

            TextArea.flickable: TextArea{
                id: messageField
                background: null

                rightPadding: 0
                leftPadding: 54

                font: appTextFont
                color: textColor

                placeholderText: "Message"
                placeholderTextColor: Qt.alpha(textColor, 0.6)

                wrapMode: TextEdit.Wrap

                selectionColor: selectedText.length > 0 ? textColor : "transparent"
                selectedTextColor: selectedText.length > 0 ? "#171717" : textColor

                Behavior on selectionColor{
                    ColorAnimation {
                        duration: 75
                        easing.type: Easing.InCubic
                    }
                }
                Behavior on selectedTextColor{
                    ColorAnimation {
                        duration: 75
                        easing.type: Easing.InCubic
                    }
                }

                // Cursor
                cursorDelegate: Item{}
                Cursor{
                    textColor: root.textColor
                    field: messageField
                }

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

                    implicitWidth: 200

                    Action{
                        text: "Cut"
                        property string shortcutText: "Ctrl+X"
                        enabled: messageField.selectedText.length > 0
                        onTriggered: messageField.cut()
                        property string iconName: "scissors"
                    }
                    Action{
                        text: "Copy"
                        property string shortcutText: "Ctrl+C"
                        enabled: messageField.selectedText.length > 0
                        onTriggered: messageField.copy()
                        property string iconName: "copy"
                    }
                    Action{
                        text: "Paste"
                        property string shortcutText: "Ctrl+V"
                        enabled: messageField.canPaste
                        onTriggered: messageField.paste()
                        property string iconName: "clipboard"
                    }
                    Action{
                        text: "Select All"
                        property string shortcutText: "Ctrl+A"
                        enabled: messageField.length > 0
                        onTriggered: messageField.selectAll()
                        property string iconName: "scan-text"
                    }
                }

                Keys.onPressed: function(event){
                    if (event.key !== Qt.Key_Return && event.key !== Qt.Key_Enter){
                        return
                    }
                    if(event.modifiers & Qt.ShiftModifier){
                        return
                    }
                    event.accepted = true
                    if(!root.isEmpty){
                        root.toButton()
                        root.send()
                    }
                }
            }
        }
    }
}