import QtQuick 2.15

Item{
    id: root

    property int widthPanel
    property color panelsColor
    property color mainColor
    property color textColor
    property color borderColor
    property double opacityPanels
    property font appTextFont
    property Gradient defaultGrad
    property int windowsRadius
    property int marginChatsField

    Rectangle{
        id: rectLeft

        anchors.fill: parent

        color: Qt.alpha(panelsColor, opacityPanels)
        radius: windowsRadius

        border.width: 1
        border.color: borderColor

        Rectangle{
            id: rectLeftTop

            anchors.fill: parent
            anchors.margins: marginChatsField

            gradient: defaultGrad
            radius: 4

            layer.enabled: true
            layer.format: ShaderEffectSource.RGBA16F
            layer.effect: ShaderEffect{
                fragmentShader: "qrc:/shaders/assets/DitheringShader.frag.qsb"
            }

            Behavior on height{
                NumberAnimation{
                        duration: 75
                        easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
