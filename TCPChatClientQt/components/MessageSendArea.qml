import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtQuick.Layouts

Item{
    id: root
    height: Math.max(60, Math.min(200, messageField.implicitHeight + 25))

    property bool isEmpty: messageField.text.trim().length === 0
    property color panelsColor
    property color mainColor
    property color textColor
    property color borderColor
    property int rightContentMargin
    property int marginChatsField
    property double opacityPanels
    property font appTextFont
    property real borderOpacity: 0.3
    property double opacityMenu
    property font appSmallFont
    readonly property bool highlighted: hoverHandler.hovered
                                        || messageField.activeFocus
                                        || contextMenu.visible
    signal sendRequested(string message)
    signal toButton()

    onHighlightedChanged: {
        borderAnimation.stop()
        borderAnimation.to = root.highlighted ? 1 : 0.3
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

    RectangularShadow{
        id: rectShadow

        anchors.fill: parent


        radius: rectBottom.radius
        blur: 30
        spread: 5
        color: Qt.rgba(0, 0, 0, opacityPanels - 0.1)
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
        radius: 30

        border.width: 1
        border.color: Qt.alpha(borderColor, borderOpacity)

        Behavior on opacity{
            NumberAnimation{
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height{
                NumberAnimation{
                    duration: 75
                    easing.type: Easing.InOutQuad
                }
        }

        Rectangle {
            id: rectBottomTop
            anchors.fill: parent
            anchors.margins: 10
            color: Qt.alpha(mainColor, opacityPanels)
            radius: 30

            Behavior on height{
                    NumberAnimation{
                        duration: 75
                        easing.type: Easing.InOutQuad
                    }
            }
        }

        Flickable{
            id: flick

            anchors.left: parent.left
            anchors.leftMargin: 20

            anchors.right: parent.right
            anchors.rightMargin: rightContentMargin

            anchors.top: parent.top
            anchors.topMargin: 10

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar{
                id: sbar

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

                rightPadding: 10

                font: appTextFont
                color: textColor

                placeholderText: "Message"
                placeholderTextColor: Qt.alpha(textColor, 0.6)

                wrapMode: TextEdit.Wrap

                ContextMenu.menu: Menu{
                    id: contextMenu

                    implicitWidth: 180
                    topPadding: marginChatsField
                    bottomPadding: marginChatsField

                    background: Item{
                        id: itemRoot

                        RectangularShadow{
                            id: menuShadow

                            anchors.fill: backRect

                            radius: backRect.radius
                            blur: 30
                            spread: 5
                            color: Qt.rgba(0, 0, 0, opacityPanels - 0.1)
                        }

                        Rectangle{
                            id: backRect

                            anchors.fill: parent

                            color: Qt.alpha(mainColor, opacityMenu)
                            radius: 8

                            border.width: 1
                            border.color: Qt.alpha(borderColor, 0.3)
                        }
                    }

                    delegate: MenuItem{
                        id: menuItem

                        leftInset: 6
                        rightInset: 6
                        leftPadding: 12
                        rightPadding: 12

                        contentItem: RowLayout{
                            opacity: enabled ? 1 : 0.35

                            Text{
                                text: menuItem.text
                                font: appTextFont
                                color: textColor
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignBaseline
                            }
                            Text{
                                text: menuItem.action.shortcutText
                                font: appSmallFont
                                color: Qt.alpha(textColor, 0.7)
                                Layout.alignment: Qt.AlignBaseline
                            }
                        }

                        background: Rectangle{
                            color: Qt.alpha(textColor, 0.08)
                            opacity: menuItem.highlighted ? 1 : 0
                            radius: 7

                            Behavior on opacity{
                                NumberAnimation{
                                    duration: 75
                                    easing.type: Easing.InOutCubic
                                }
                            }
                        }
                    }
                    Action{
                        text: "Cut"
                        property string shortcutText: "Ctrl+X"
                        enabled: messageField.selectedText.length > 0
                        onTriggered: messageField.cut()
                    }
                    Action{
                        text: "Copy"
                        property string shortcutText: "Ctrl+C"
                        enabled: messageField.selectedText.length > 0
                        onTriggered: messageField.copy()
                    }
                    Action{
                        text: "Paste"
                        property string shortcutText: "Ctrl+V"
                        enabled: messageField.canPaste
                        onTriggered: messageField.paste()
                    }
                    Action{
                        text: "Select All"
                        property string shortcutText: "Ctrl+A"
                        enabled: messageField.length > 0
                        onTriggered: messageField.selectAll()
                    }

                    enter: Transition{
                        NumberAnimation{
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                    exit: Transition{
                        NumberAnimation{
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 100
                            easing.type: Easing.InCubic
                        }
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