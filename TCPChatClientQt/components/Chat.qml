import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Controls.Basic

Item{
    id: root

    property color panelsColor
    property color mainColor
    property color textColor
    property color borderColor
    property double opacityPanels
    property font appTextFont
    property Gradient defaultGrad
    property int windowsRadius
    property int marginChatsField

    ListModel{
        id: messageModel
    }

    function addMessage(text, mine){
        messageModel.append({messageText: text, isMine: mine})
    }

    Rectangle{
        id: rectChatBottom
        color: Qt.alpha(panelsColor, opacityPanels)
        radius: windowsRadius

        border.width: 1
        border.color: borderColor

        anchors.fill: parent

        Rectangle{
            id: rectChatTop

            anchors.fill: parent
            anchors.margins: marginChatsField

            gradient: defaultGrad
            radius: 4

            layer.enabled: true
            layer.format: ShaderEffectSource.RGBA16F
            layer.effect: ShaderEffect{
                fragmentShader: "qrc:/shaders/assets/DitheringShader.frag.qsb"
            }
        }

        ListView{
            id: entireChat

            anchors.fill: parent
            anchors.margins: marginChatsField

            clip: true
            spacing: 16
            model: messageModel

            delegate: Item{
                id: delegateRoot

                required property string messageText
                required property bool isMine

                // временно
                height: delegateBottom.height
                width: ListView.view.width

                RectangularShadow{
                    id: rectShadow

                    anchors.fill: delegateBottom

                    radius: delegateBottom.radius
                    blur: 30
                    spread: 2
                    color: Qt.rgba(0, 0, 0, opacityPanels - 0.15)
                }

                Rectangle{
                    id: delegateBottom

                    width: message.width + 24
                    height: message.implicitHeight + 16

                    x: delegateRoot.isMine ? delegateRoot.width - width - 15 : 15

                    color: delegateRoot.isMine? Qt.alpha("#2E2E2E", opacityPanels) : Qt.alpha(panelsColor, opacityPanels)
                    radius: windowsRadius

                    border.width: 1
                    border.color: delegateRoot.isMine ? "#484848" : "#2E2E2E"

                    Text{
                    id: message

                    anchors.centerIn: parent

                    width: Math.min(implicitWidth, delegateRoot.width * 0.7 - 24)

                    text: delegateRoot.messageText
                    color: textColor
                    font: appTextFont

                    wrapMode: Text.Wrap
                    }
                }
            }

            ScrollBar.vertical: ScrollBar{
                id: sbar

                contentItem: Rectangle{
                    implicitWidth: 5
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
        }
    }
}