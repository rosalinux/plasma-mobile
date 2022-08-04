/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */


import QtQuick 2.12
import QtQuick.Controls 2.12
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

        Loader {
            id: strengthLoader
            height: parent.height
            width: 50//item ? item.width : 0
            anchors.leftMargin: 100
            anchors.left: parent.left
            active: signalStrengthProvider
            sourceComponent: Indicators.SignalStrength {
                provider: signalStrengthProvider
            }
        }

        Row {
            id: statusNotifierIndicatorsRow
            anchors.left: strengthLoader.right
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

        PlasmaComponents.Label {
            id: clock
            property bool is24HourTime: plasmoid.nativeInterface.isSystem24HourFormat
            
            anchors.fill: parent
            text: Qt.formatTime(timeSource.data.Local.DateTime, is24HourTime ? "h:mm" : "h:mm ap")
            color: PlasmaCore.ColorScope.textColor
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: height * 0.75
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
