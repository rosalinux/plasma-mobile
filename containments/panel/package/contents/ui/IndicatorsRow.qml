/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */


import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.wallpapers.image 2.0 as Wallpaper

import "LayoutManager.js" as LayoutManager

import "indicators" as Indicators

Item {
    id: indicatorsRow
    required property var colorGroup
    required property bool showGradientBackground
    required property bool showDropShadow
    required property color backgroundColor
    
    property alias colorScopeColor: icons.backgroundColor
    property alias applets: appletIconsRow
    
    PlasmaCore.DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60 * 1000
    }

    Wallpaper.Image {
        id: imageWallpaper
        renderingMode: Wallpaper.Image.SingleImage
    }

    Image{
        anchors.fill: parent
        source: imageWallpaper.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignTop
        clip: true
    }



    // screen top panel
    PlasmaCore.ColorScope {
        id: icons
        z: 1
        colorGroup: indicatorsRow.colorGroup
        anchors.fill: parent
        
        // background
        Rectangle {
            anchors.fill: parent
            color: backgroundColor
        }

        Rectangle{
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height / 2
            color: "transparent"


            PlasmaComponents.Label {
                id: clock
                property bool is24HourTime: plasmoid.nativeInterface.isSystem24HourFormat
                anchors.leftMargin: 110
                anchors.left: parent.left
                height: parent.height
                text: Qt.formatTime(timeSource.data.Local.DateTime, is24HourTime ? "h:mm" : "h:mm ap")
                color: PlasmaCore.ColorScope.textColor
                verticalAlignment: Qt.AlignVCenter
                font.pixelSize: height * 0.75
            }



            Row {
                id: statusNotifierIndicatorsRow
                anchors.right: strengthLoader.left
                height: parent.height
                Repeater {
                    id: statusNotifierRepeater
                    model: PlasmaCore.SortFilterModel {
                        id: filteredStatusNotifiers
                        filterRole: "Title"
                        sourceModel: PlasmaCore.DataModel {
                            dataSource: statusNotifierSource
                        }
                    }
                    delegate: TaskWidget {}
                }
            }

            Loader {
                id: strengthLoader
                height: parent.height
                width: item ? item.width : 0
                anchors.right: appletIconsRow.left
                active: signalStrengthProvider
                sourceComponent: Indicators.SignalStrength {
                    provider: signalStrengthProvider
                }
            }



            RowLayout {
                id: appletIconsRow
                anchors {
                    bottom: parent.bottom
                    right: simpleIndicatorsLayout.left
                }
                height: parent.height
            }

            RowLayout {
                id: simpleIndicatorsLayout
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    rightMargin: PlasmaCore.Units.smallSpacing
                }
                Indicators.Bluetooth { provider: bluetoothProvider }
                Indicators.Wifi { provider: wifiProvider }
                Indicators.Volume { provider: volumeProvider }
                Indicators.Battery { provider: batteryProvider }
            }
        }

    }
}
