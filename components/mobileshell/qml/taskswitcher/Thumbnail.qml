/*
 *   SPDX-FileCopyrightText: 2020 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

TaskManager.PipeWireSourceItem {
    id: root
    visible: (taskSwitcher.visible || taskSwitcher.tasksModel.taskReorderingEnabled) && MobileShell.MobileShellSettings.taskSwitcherPreviewsEnabled
    opacity: nodeId > 0 ? 1 : 0
    nodeId: waylandItem.nodeId
    
    readonly property alias uuid: waylandItem.uuid

    onVisibleChanged: {
        if (model.WinIdList && visible) {
            waylandItem.uuid = model.WinIdList[0];
        }
    }

    TaskManager.ScreencastingRequest {
        id: waylandItem
        uuid: ""
    }
}


