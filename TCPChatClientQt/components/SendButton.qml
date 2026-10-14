import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.VectorImage
import QtQuick.Effects
import QtMultimedia
import Qt.labs.lottieqt

Item{
    id: root

    property bool isEmpty: true
    property int circleSize: 40
    property int actualButton: 50
    property color panelsColor
    property color mainColor
    property color textColor
    property font appFont

    signal clicked()

    width: actualButton
    height: actualButton

    function startSend(){
        soundPlayer.play()
        lottieController.frameRate = 90
        ringBoost.start()
        ringTimer.start()
    }

    // Glow effect of ring's animation
    MultiEffect{
        id: bigGlow

        anchors.fill: metalRing
        source: metalRing

        blurEnabled: true
        blur: 0.7
        blurMax: 48
        brightness: 0.3
    }

    // Ring's Lottie animation
    VectorImage{
        id: metalRing
        property int ringSize: 120

        width: button.hovered ? ringSize * 1.15 : ringSize
        height: button.hovered ? ringSize * 1.15 : ringSize

        Behavior on width{
            NumberAnimation{
                duration: 100
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on height{
            NumberAnimation{
                duration: 100
                easing.type: Easing.InOutCubic
            }
        }

        anchors.centerIn: button

        source: "qrc:/qt/qml/TCPChatClientQt/assets/SomethingInteresting.json"

        assumeTrustedSource: true

        animations.loops: Animation.Infinite

        preferredRendererType: VectorImage.CurveRenderer

        LottieVectorImageController{
            id: lottieController
        }
    }

    // Bottom of the button
    Rectangle{
        id: buttonRectangleBottom
        anchors.centerIn: button

        width: button.hovered  ? actualButton * 1.2 : actualButton
        height: button.hovered ? actualButton * 1.2 : actualButton

        Behavior on width{
            NumberAnimation{
                duration: 100
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on height{
            NumberAnimation{
                duration: 100
                easing.type: Easing.InOutCubic
            }
        }

        radius: width / 2
        color: panelsColor
    }

    // Top of the button
    Rectangle{
        id: buttonRectangleTop
        anchors.centerIn: button

        width: circleSize
        height: circleSize

        scale: button.hovered ? 1.2 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutCubic
            }
        }

        radius: width / 2
        color: mainColor
    }

    // Button
    Button{
        id: button
        text: "S"

        enabled: !ringBoost.running && !isEmpty

        width: actualButton
        height: actualButton

        onHoveredChanged: {
            lottieController.frameRate = button.hovered ? 60 : 30
        }

        onClicked: {
            root.clicked()

            startSend()
        }

        contentItem: Text{
            text: button.text
            color: textColor
            font: appFont


            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle{
            color: "transparent"
        }
    }

    // Send sound
    SoundEffect{
        id: soundPlayer
        volume: 0.3
        source: "qrc:/qt/qml/TCPChatClientQt/assets/SendS.wav"
    }

    // Animations
    Timer{
        id: ringTimer
        interval: 500

        onTriggered: {
            lottieController.frameRate = button.hovered ? 60 : 30
        }
    }

    SequentialAnimation{
        id: ringBoost

        NumberAnimation {
            target: metalRing
            property: "ringSize"
            from: 120
            to: 128
            duration: 250
            easing.type: Easing.InOutCubic
        }


        NumberAnimation {
            target: metalRing
            property: "ringSize"
            from: 128
            to: 120
            duration: 250
            easing.type: Easing.InOutCubic
        }
    }
}