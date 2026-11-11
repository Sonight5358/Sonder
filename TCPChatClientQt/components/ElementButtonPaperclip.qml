import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Shapes

Button{
    id: root

    property int size
    property int radiusButton
    property color mainColor
    property color textColor
    property string iconName
    property string tooltipText
    property double opacityMenu
    property font appSmallFont
    property color borderColor
    property double borderIdleOpacity
    property bool toolTipVisible
    property real iconRot: 0
    property bool opened: false

    width: root.size
    height: root.size

    Item{
        id: icon

        rotation: iconRot

        anchors.centerIn: parent

        width: 24
        height: 24

        Behavior on rotation{
            NumberAnimation{
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Shape{
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath{
                strokeColor: root.textColor
                strokeWidth: 2
                fillColor: "transparent"

                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathSvg{
                    path: "M 16 6 L 7.586 14.586 A 2 2 0 0 0 10.415 17.415 L 18.829 8.829 A 4 4 0 1 0 13.172 3.172"
                }
            }
        }

        Shape{
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath{
                strokeColor: root.textColor
                strokeWidth: 2
                fillColor: "transparent"

                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathSvg{
                    path: "M 13.172 3.172 L 4.793 11.723 A 6 6 0 1 0 13.278 20.208"
                }
            }
        }

        Item{
            anchors.fill: parent

            transform: Rotation{
                origin.x: 13.278
                origin.y: 20.208


                angle: root.opened ? 15 : 0

                Behavior on angle{
                    NumberAnimation{
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Shape{
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath{
                    strokeColor: root.textColor
                    strokeWidth: 2
                    fillColor: "transparent"

                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    PathSvg{
                        path: "M 13.278 20.208 L 21.657 11.657"
                    }
                }
            }
        }
    }

    background: Rectangle{
        id: buttonRectangleBottom

        radius: root.radiusButton
        color: root.hovered ? Qt.lighter(mainColor, 1.35) : mainColor

        Behavior on color{
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    CustomToolTip{
        text: tooltipText

        visible: root.hovered && tooltipText !== "" && root.toolTipVisible

        mainColor: root.mainColor
        textColor: root.textColor
        opacityMenu: root.opacityMenu
        appSmallFont: root.appSmallFont
        borderColor: root.borderColor
        borderIdleOpacity: root.borderIdleOpacity
    }
}