/*
 *   Copyright 2013 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 1.1
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.metadatamodels 0.1 as MetadataModels
import org.kde.plasma.components 0.1 as PlasmaComponents

Column {
    id: root

    anchors {
        left: parent.left
        right: parent.right
    }

    PlasmaExtras.Heading {
        text: i18n("Artist")
        anchors {
            right: parent.right
            rightMargin: theme.defaultFont.mSize.width
        }
        MouseArea {
            anchors.fill: parent
            onClicked: artistList.visible = !artistList.visible
        }
    }
    Column {
        id: artistList
        visible: false
        Repeater {
            model: MetadataModels.MetadataModel {
                    queryProvider: MetadataModels.CloudQueryProvider {
                        cloudCategory: "nmm:performer"
                        resourceType: "nfo:Audio"
                        minimumRating: metadataModel.queryProvider.minimumRating
                    }
                }
            delegate : PlasmaComponents.Label {
                text: label
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (metadataModel.queryProvider.extraParameters["nmm:performer"] != label) {
                            metadataModel.queryProvider.extraParameters["nmm:performer"] = label
                        } else {
                            metadataModel.queryProvider.extraParameters["nmm:performer"] = ""
                        }
                    }
                }
            }
        }
    }

    PlasmaExtras.Heading {
        text: i18n("Album")
        anchors {
            right: parent.right
            rightMargin: theme.defaultFont.mSize.width
        }
        MouseArea {
            anchors.fill: parent
            onClicked: albumList.visible = !albumList.visible
        }
    }
    Column {
        id: albumList
        visible: false
        Repeater {
            model: MetadataModels.MetadataModel {
                    queryProvider: MetadataModels.CloudQueryProvider {
                        cloudCategory: "nmm:musicAlbum"
                        resourceType: "nfo:Audio"
                        minimumRating: metadataModel.queryProvider.minimumRating
                    }
                }
            delegate : PlasmaComponents.Label {
                text: label
            }
        }
    }
}