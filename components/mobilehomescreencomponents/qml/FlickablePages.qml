/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragDrop

import "private" as Private

import org.kde.plasma.private.containmentlayoutmanager 1.0 as ContainmentLayoutManager 

import org.kde.plasma.private.mobileshell 1.0 as MobileShell

import org.kde.plasma.private.mobilehomescreencomponents 0.1 as HomeScreenComponents

Flickable {
    id: mainFlickable

    property AbstractAppDrawer appDrawer

    readonly property int totalPages: Math.ceil(contentWidth / width)
    property int currentIndex: 0

    property ContainmentLayoutManager.AppletsLayout appletsLayout: null
    property Item footer

    property alias dragGestureEnabled: gestureHandler.enabled
    opacity: appDrawer ? 1 - appDrawer.openFactor : 1
    transform: Translate {
        y: appDrawer ? (-mainFlickable.height / 20) * appDrawer.openFactor : 0
    }
    clip: true

    property bool showAddPageIndicator: false
    contentHeight: height
    interactive: false

    signal cancelEditModeForItemsRequested
    onDragStarted: cancelEditModeForItemsRequested()
    onDragEnded: cancelEditModeForItemsRequested()
    onFlickStarted: cancelEditModeForItemsRequested()
    onFlickEnded: cancelEditModeForItemsRequested()

    //onCurrentIndexChanged: contentX = width * currentIndex;
    onContentXChanged: mainFlickable.currentIndex = Math.floor(contentX / width)

    onFooterChanged: {
        footer.parent = mainFlickable;
        footer.anchors.left = mainFlickable.left;
        footer.anchors.bottom = mainFlickable.bottom;
        footer.anchors.right = mainFlickable.right;
    }

    //Autoscroll related functions
    function scrollLeft() {
        if (mainFlickable.atXBeginning) {
            return;
        }
        autoScrollTimer.scrollRight = false;
        autoScrollTimer.running = true;
    }

    function scrollRight() {
        if (mainFlickable.atXEnd) {
            return;
        }
        autoScrollTimer.scrollRight = true;
        autoScrollTimer.running = true;
    }

    function stopScroll() {
        autoScrollTimer.running = false;
    }

    function snapPage() {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.round(mainFlickable.contentX / mainFlickable.width)
        scrollAnim.running = true;
    }

    function snapNextPage() {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.ceil(mainFlickable.contentX / mainFlickable.width)
        scrollAnim.running = true;
    }

    function snapPrevPage() {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.floor(mainFlickable.contentX / mainFlickable.width)
        scrollAnim.running = true;
    }
    function scrollToPage(index) {
        scrollAnim.running = false;
        scrollAnim.to = mainFlickable.width * Math.max(0, Math.min(index, mainFlickable.contentWidth - mainFlickable.width))
        scrollAnim.running = true;
    }

    Timer {
        id: autoScrollTimer
        property bool scrollRight: true
        repeat: true
        interval: 1500
        onTriggered: {
            scrollAnim.to = scrollRight ?
            //Scroll Right
                Math.min(mainFlickable.contentItem.width - mainFlickable.width, mainFlickable.contentX + mainFlickable.width) :
            //Scroll Left
                Math.max(0, mainFlickable.contentX - mainFlickable.width);

            scrollAnim.running = true;
        }
    }

    Private.DragGestureHandler {
        id: gestureHandler
        target: appletsLayout
        appDrawer: mainFlickable.appDrawer
        mainFlickable: mainFlickable
        onSnapPage: mainFlickable.snapPage();
        onSnapNextPage: mainFlickable.snapNextPage();
        onSnapPrevPage: mainFlickable.snapPrevPage();
    }

    NumberAnimation {
        id: scrollAnim
        target: mainFlickable
        properties: "contentX"
        duration: PlasmaCore.Units.longDuration
        easing.type: Easing.InOutQuad
    }

}


