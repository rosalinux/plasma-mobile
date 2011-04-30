/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "windowstrip.h"

#include <QtGui/QGraphicsLinearLayout>
#include <QDeclarativeComponent>
#include <QDeclarativeItem>
#include <QGraphicsView>

#include <Plasma/Svg>
#include <Plasma/WindowEffects>

#include <KStandardDirs>
#include <KWindowSystem>

WindowStrip::WindowStrip(QGraphicsWidget *parent)
    : Plasma::DeclarativeWidget(parent)
{
    // Run the frameupdater once every 20 msec,
    // so KWin gets in the ideal case updated
    // rects for every frame
    m_frameUpdater.setInterval(20);

    // The frameController is used to stop updating the
    // frame after a timeout after the animation has stopped
    m_updateController.setSingleShot(true);
    m_updateController.setInterval(200);
    connect(&m_frameUpdater, SIGNAL(timeout()), SLOT(updateFrame()));
    connect(&m_updateController, SIGNAL(timeout()), &m_frameUpdater, SLOT(stop()));

    //setThumbnailRects("Tokamak 5");
    setQmlPath(KStandardDirs::locate("data", "plasma/plasmoids/org.kde.windowstrip/WindowStrip.qml"));
    m_windowFlicker = rootObject()->findChild<QDeclarativeItem*>("windowFlicker");

<<<<<<< HEAD
    init();

    //connect(rootObject(), SIGNAL(lockedChanged()), this, SLOT(lockChanged()));
    //connect(m_windowFlicker, SIGNAL(childrenPositionsChanged()), this, SLOT(windowsPositionsChanged()));
=======
    connect(m_windowFlicker, SIGNAL(childrenPositionsChanged()), this, SLOT(windowsPositionsChanged()));

>>>>>>> send the whole geometry to the c++ part
    connect(m_windowFlicker, SIGNAL(contentXChanged()), this, SLOT(scrollChanged()));
    //connect(m_windowFlicker, SIGNAL(intermediateFrame()), this, SLOT(scrollChanged()));
}

WindowStrip::~WindowStrip()
{
    hideThumbnails();
    kDebug() << "dtor......";
}

void WindowStrip::init()
{


    kDebug() << "init......";
    QList< WId > windows = KWindowSystem::windows();
}

void WindowStrip::showThumbnails()
{
    QList<QRect> translatedWindows;
    foreach (QRect windowRect, m_windows.values()) {
        translatedWindows << windowRect.translated(m_windowsOffset);
    }
    Plasma::WindowEffects::showWindowThumbnails(m_desktop, m_windows.keys(), translatedWindows);
    //kDebug() << "/// all shown" << m_windows.keys() << translatedWindows;
}

void WindowStrip::hideThumbnails()
{
    Plasma::WindowEffects::showWindowThumbnails(m_desktop);
    kDebug() << "/// all hidden ";
}

void WindowStrip::scrollChanged()
{
    //kDebug() << "elapsed: " << m_time.elapsed();
    if (m_time.elapsed() < 50) {
        //kDebug() << "skipping";
        //return;
    }

    // the view has changed, update the windows,
    // start the updating timer, and start the controller
    // to kill the updater after a while
    updateWindows();
    m_updateController.start();
    m_frameUpdater.start();
}

void WindowStrip::updateWindows()
{
    QVariant dataX = m_windowFlicker->property("contentX");
    QVariant dataY = m_windowFlicker->property("contentY");
    //kWarning()<<"new X"<<data;

<<<<<<< HEAD
    QList< WId > windows = KWindowSystem::windows();
    int x, y, w, h, s;
    x = -data.value<int>();
    y = 20;
    w = 200;
    h = 400;
    s = 10;

    foreach (const WId wid, windows) {
        m_windows[wid] = QRect(x, y, w, h);
        x = x + w + s;
        //kDebug() << "Window ID:" << w << m_windows[wid] << QString::number(wid);
    }

    m_desktop = static_cast<Plasma::Applet *>(parentItem())->view()->effectiveWinId();

=======
    m_desktop = static_cast<Plasma::Applet *>(parentItem())->view()->effectiveWinId();
    m_windowsOffset = -QPoint(dataX.value<int>(), dataY.value<int>());
    
>>>>>>> send the whole geometry to the c++ part
    showThumbnails();
    //kDebug() << "duration: " << m_time.elapsed();
    //m_timer.restart();
}

void WindowStrip::updateFrame()
{
<<<<<<< HEAD
    //kDebug() << "updating frame";
    updateWindows();
=======
    QVariant data = m_windowFlicker->property("childrenPositions");
    QList<QVariant> thumbnailsInfo = data.value<QList<QVariant> >();
    //kDebug() << "window positions" << thumbnailsInfo;
    m_thumbnailRects.clear();
    foreach (QVariant windowData, thumbnailsInfo) {
         const QVariantMap windowInfo = windowData.value<QVariantMap>();
         WId winId = windowInfo["winId"].value<QString>().toInt();

         m_windows[winId] = QRect(windowInfo["x"].value<int>(), windowInfo["y"].value<int>(), windowInfo["width"].value<int>(), windowInfo["height"].value<int>());
    }
>>>>>>> send the whole geometry to the c++ part
}

#include "windowstrip.moc"