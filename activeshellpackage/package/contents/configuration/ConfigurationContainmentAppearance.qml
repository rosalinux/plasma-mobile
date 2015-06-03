/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import org.kde.plasma.configuration 2.0
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0

ColumnLayout {
    id: root

    property string currentWallpaper: ""
    property string containmentPlugin: ""

//BEGIN functions
    function saveConfig() {
        for (var key in configDialog.wallpaperConfiguration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                configDialog.wallpaperConfiguration[key] = main.currentItem["cfg_"+key]
            }
        }
        configDialog.currentWallpaper = root.currentWallpaper;
        configDialog.applyWallpaper()
        configDialog.containmentPlugin = root.containmentPlugin
    }

    function restoreConfig() {
        for (var key in configDialog.wallpaperConfiguration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                main.currentItem["cfg_"+key] = configDialog.wallpaperConfiguration[key]
            }
        }
    }
//END functions

    Component.onCompleted: {
        for (var i = 0; i < configDialog.containmentPluginsConfigModel.count; ++i) {
            var data = configDialog.containmentPluginsConfigModel.get(i);
            for(var j in data) print(j)
            if (configDialog.containmentPlugin == data.pluginName) {
                var model = configDialog.containmentPluginsConfigModel.get(i)
                root.containmentPlugin = model.pluginName
                break;
            }
        }

        for (var i = 0; i < configDialog.wallpaperConfigModel.count; ++i) {
            var data = configDialog.wallpaperConfigModel.get(i);
            for(var j in data) print(j)
            if (configDialog.currentWallpaper == data.pluginName) {
                var model = configDialog.wallpaperConfigModel.get(i)
                root.currentWallpaper = model.pluginName
                main.sourceFile = model.source
                configDialog.currentWallpaper = model.pluginName
                root.restoreConfig()
                break;
            }
        }
    }

    Item {
        id: emptyConfig
    }

    QtControls.StackView {
        id: main
        Layout.fillHeight: true;
        anchors {
            left: parent.left;
            right: parent.right;
        }
        property string sourceFile
        onSourceFileChanged: {
            if (sourceFile != "") {
                replace(Qt.resolvedUrl(sourceFile))
            } else {
                replace(emptyConfig);
            }
        }
    }
}
