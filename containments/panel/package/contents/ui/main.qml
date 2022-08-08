/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.12 as Kirigami

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.kde.taskmanager 0.1 as TaskManager

import org.kde.plasma.private.nanoshell 2.0 as NanoShell
import org.kde.plasma.private.mobileshell 1.0 as MobileShell
import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

import "LayoutManager.js" as LayoutManager

import "indicators" as Indicators
import "indicators/providers" as IndicatorProviders

Item {
    id: root
    width: 480
    height: 30
    Plasmoid.backgroundHints: showingApp ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

    property Item toolBox
    property int buttonHeight: width/4
    property bool reorderingApps: false
    property var layoutManager: LayoutManager

    readonly property color backgroundColor: NanoShell.StartupFeedback.visible ? NanoShell.StartupFeedback.backgroundColor : topPanel.colorScopeColor
    readonly property bool showingApp: !MobileShell.HomeScreenControls.homeScreenVisible

    readonly property bool hasTasks: tasksModel.count > 0

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

    function addApplet(applet, x, y) {
        
    }

    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsLayout;
        LayoutManager.restore();
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        screenGeometry: plasmoid.screenGeometry
        //FIXME: workaround
        Component.onCompleted: tasksModel.countChanged();
    }

    PlasmaCore.DataSource {
        id: statusNotifierSource
        engine: "statusnotifieritem"
        interval: 0
        onSourceAdded: {
            connectSource(source)
        }
        Component.onCompleted: {
            connectedSources = sources
        }
    }

    RowLayout {
        id: appletsLayout
        Layout.minimumHeight: Math.max(root.height, Math.round(Layout.preferredHeight / root.height) * root.height)
    }
 
    //todo: REMOVE?
    Component {
        id: compactContainerComponent
        Item {
            property Item applet
            visible: applet && (applet.status != PlasmaCore.Types.HiddenStatus && applet.status != PlasmaCore.Types.PassiveStatus)
            Layout.fillHeight: true
            Layout.minimumWidth: applet && applet.compactRepresentationItem ? Math.max(applet.compactRepresentationItem.Layout.minimumWidth, topPanel.applets.height) : topPanel.applets.height
            Layout.maximumWidth: Layout.minimumWidth
        }
    }

    Component {
        id: fullContainerComponent
        FullContainer {}
    }

    // indicator providers
    IndicatorProviders.BatteryProvider {
        id: batteryProvider

        readonly property var setting: HomeScreenComponents.QuickSetting {
            text: i18n("Battery")
            icon: "battery-full" + (batteryProvider.pluggedIn ? "-charging" : "")
            enabled: false
            settingsCommand: "plasma-open-settings kcm_mobile_power"
        }
        //Component.onCompleted: quickSettings.quickSettingsModel.include(setting)
    }
    IndicatorProviders.BluetoothProvider {
        id: bluetoothProvider
    }
    property alias signalStrengthProvider: signalStrengthProviderLoader.item
    Loader {
        id: signalStrengthProviderLoader
        source: Qt.resolvedUrl("indicators/providers/SignalStrengthProvider.qml")
    }
    IndicatorProviders.VolumeProvider {
        id: volumeProvider

        readonly property var setting: HomeScreenComponents.QuickSetting {
            text: i18n("Sound")
            icon: "audio-speakers-symbolic"
            enabled: false
            settingsCommand: "plasma-open-settings kcm_pulseaudio"
            function toggle() {
                volumeProvider.showVolumeOverlay()
            }
        }
        //Component.onCompleted: quickSettings.quickSettingsModel.include(setting)
    }
    IndicatorProviders.WifiProvider {
        id: wifiProvider
    }
    
    // top panel component
    IndicatorsRow {
        id: topPanel
        anchors.fill: parent
        z: 1
        colorGroup: root.showingApp ? PlasmaCore.Theme.HeaderColorGroup : PlasmaCore.Theme.ComplementaryColorGroup
        backgroundColor: !root.showingApp ? "transparent" : root.backgroundColor
        showGradientBackground: false //!showingApp
        showDropShadow: false //!showingApp
    }
}
