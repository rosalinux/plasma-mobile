// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian K�gler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.qtextracomponents 0.1
import org.kde.plasma.core 0.1 as PlasmaCore

import QtMultimediaKit 1.1

Item {
    width: 400
    height: 400
    id: startPage
    state: "paused"

    Column {
        id: col
        anchors.fill: parent
        anchors.topMargin: 20
        spacing: 10

        Text {
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            id: title
            text: i18n("<h1>Discover Plasma Active</h1>")
            color: theme.textColor
            style: Text.Sunken
            styleColor: theme.backgroundColor
        }

        Text {
            id: description
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: i18n("<p>Stay in control of your data and create a personalized user experience!</p><p>With Plasma Active you can browse and interact with the web, stay in contact with your friends, get the latest news, read and edit documents, enjoy your music and movies, play games and more.</p><p>While using Plasma Active, you can personalize it so that it reflects your needs and interests with the innovative Activities feature. Press the arrow to learn more about Activities.")
            color: theme.textColor
            styleColor: theme.backgroundColor
        }


        Item {
            id: videoItem
            anchors.horizontalCenter: parent.horizontalCenter
            width: 266
            height: 186

            /*
            Rectangle {
                id: rect
                anchors.fill: parent
                //color: "#000"
            }
            */
            PlasmaCore.FrameSvgItem {
                imagePath: "widgets/media-delegate"
                prefix: "picture"
                id: frameRect
                height: width/1.7
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }


            
                Video {
                    id: video
                    width: frameRect.width - 2
                    height: frameRect.height - 1
                    anchors {
                        fill: frameRect
                        leftMargin: frameRect.margins.left
                        topMargin: frameRect.margins.top
                        rightMargin: frameRect.margins.right
                        bottomMargin: frameRect.margins.bottom
                    }
                    source: plasmoid.file("data", "video.ogv")

                    onPausedChanged: {
                        print("Paused Changed..." + paused + playing);
                        if (paused) {
                            setPaused();
                        } else {
                            setPlaying();
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (startPage.state == "playing") {
                                setPaused();
                            } else {
                                setPlaying();
                            }
                            print(" XXX State is now: " + startPage.state + " opacity: " + pauseButton.opacity + " scale: " + videoItem.scale);
                        }
                    }

                    focus: true
                    Keys.onSpacePressed: video.paused = !video.paused
                    Keys.onLeftPressed: video.position -= 5000
                    Keys.onRightPressed: video.position += 5000
                }
            }
            Column {
                anchors.centerIn: parent
                spacing: 60

                Text {
                    id: videoText
                    text: i18n("<h2>Watch the video!</h2>")
                    color: "#FFF"

                }
                QIconItem {
                    id: pauseButton
                    width: 48
                    height: 48
                    anchors.centerIn: parent
                    icon: QIcon("media-playback-start")

                }
            }
        }
    } // Column

    states: [
        State {
            name: "paused"
            PropertyChanges {
                target: frameRect
                width: 266
                height: 186
            }
            PropertyChanges { target: pauseButton; opacity: 1.0}
            PropertyChanges { target: videoText; opacity: 1.0}
        },
        State {
            name: "playing"
            PropertyChanges {
                target: frameRect
                width: 600
                height: 420
            }
            PropertyChanges { target: pauseButton; opacity: 0.0}
            PropertyChanges { target: videoText; opacity: 0.0}
        }
    ]

    transitions: [
        Transition {
            from: "paused"; to: "playing"
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuint; duration: 300 }
            NumberAnimation { properties: "width,height"; easing.type: Easing.InOutQuint; duration: 500 }
        },
        Transition {
            from: "playing"; to: "paused"
            NumberAnimation { properties: "opacity"; easing.type: Easing.InOutQuint; duration: 300 }
            NumberAnimation { properties: "width,height"; easing.type: Easing.InOutQuint; duration: 200 }
        }
    ]

    function setPlaying() {
        welcome.clip = false;
        video.play()
        startPage.state = "playing";
    }

    function setPaused() {
        welcome.clip = true;
        video.pause()
        startPage.state = "paused";
    }

}
