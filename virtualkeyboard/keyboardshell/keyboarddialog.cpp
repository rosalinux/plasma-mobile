/*
 *   Copyright 2007-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License version 2 as
 *   published by the Free Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "keyboarddialog.h"

#include <cmath>

#include <QAction>
#include <QApplication>
#include <QDesktopWidget>
#include <QFileInfo>
#include <QDir>
#include <QPushButton>

#include <KWindowSystem>
#include <KIcon>
#include <KIconLoader>
#include <KCmdLineArgs>

#include <Plasma/Applet>
#include <Plasma/PopupApplet>
#include <Plasma/Corona>
#include <Plasma/Containment>
#include <Plasma/WindowEffects>

KeyboardDialog::KeyboardDialog(Plasma::Corona *corona, Plasma::Containment *containment, const QString &pluginName, int appletId, const QVariantList &appletArgs, QWidget *parent)
    : Plasma::Dialog(parent),
      m_applet(0),
      m_containment(0),
      m_corona(corona),
      m_direction(Plasma::Up),
      m_location(Plasma::BottomEdge),
      m_rotation(0)
{
    m_closeButton = new QPushButton(this);
    m_closeButton->setFlat(true);
    m_closeButton->setIcon(KIcon("dialog-close"));
    m_closeButton->setIconSize(QSize(KIconLoader::SizeMedium, KIconLoader::SizeMedium));
    connect(m_closeButton, SIGNAL(clicked()), this, SLOT(hide()));

    m_moveButton = new QPushButton(this);
    m_moveButton->setFlat(true);
    m_moveButton->setIcon(KIcon("arrow-up"));
    m_moveButton->setIconSize(QSize(KIconLoader::SizeMedium, KIconLoader::SizeMedium));
    connect(m_moveButton, SIGNAL(clicked()), this, SLOT(swapScreenEdge()));

    setContainment(containment);
    m_containment->setFormFactor(Plasma::Planar);
    m_containment->setLocation(Plasma::BottomEdge);
    KWindowSystem::setType(winId(), NET::Dock);
    setAttribute(Qt::WA_X11DoNotAcceptFocus);
    QFileInfo info(pluginName);
    if (!info.isAbsolute()) {
        info = QFileInfo(QDir::currentPath() + "/" + pluginName);
    }

    if (info.exists()) {
        m_applet = Plasma::Applet::loadPlasmoid(info.absoluteFilePath(), appletId, appletArgs);
    }

    if (!m_applet) {
        m_applet = Plasma::Applet::load(pluginName, appletId, appletArgs);
    }

    // ensure that the keyboard knows when to reset itself
    connect(this, SIGNAL(dialogVisible(bool)), m_applet, SLOT(dialogStatusChanged(bool)));
    m_containment->addApplet(m_applet, QPointF(-1, -1), false);

    setGraphicsWidget(m_applet);

    m_applet->setFlag(QGraphicsItem::ItemIsMovable, false);
    setWindowTitle(m_applet->name());
    setWindowIcon(SmallIcon(m_applet->icon()));

    connect(this, SIGNAL(sceneRectAboutToChange()), this, SLOT(updateGeometry()));
    QDesktopWidget *desktop = QApplication::desktop();
    connect(desktop, SIGNAL(resized(int )), this, SLOT(updateGeometry()));

    setFixedHeight(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());

    QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));
    screenGeom.setWidth(screenGeom.width()-100);
    setFixedWidth(screenGeom.width());

    hide();
    updateGeometry();
}

KeyboardDialog::~KeyboardDialog()
{
    emit storeApplet(m_applet);
}

void KeyboardDialog::setContainment(Plasma::Containment *c)
{
    if (m_containment) {
        disconnect(m_containment, 0, this, 0);
    }

    m_containment = c;
    m_containment->setScreen(0);
    updateGeometry();
}

Plasma::Applet *KeyboardDialog::applet()
{
    return m_applet;
}

Plasma::Location KeyboardDialog::location() const
{
    return m_containment->location();
}

Plasma::FormFactor KeyboardDialog::formFactor() const
{
    return m_containment->formFactor();
}

void KeyboardDialog::updateGeometry()
{
    QDesktopWidget *desktop = QApplication::desktop();
    m_containment->setGeometry(QRect(QPoint(0,0), desktop->size()));
    m_corona->setSceneRect(m_containment->geometry());
    const int iconSize = KIconLoader::SizeMedium;
    switch (m_location) {
        case Plasma::TopEdge:
            m_closeButton->setGeometry(width() - iconSize, height() - iconSize, iconSize, iconSize);
            m_moveButton->setGeometry(0, height() - iconSize, iconSize, iconSize);
            break;
        case Plasma::RightEdge:
            m_closeButton->setGeometry(0, 0, iconSize, iconSize);
            m_moveButton->setGeometry(0, height() - iconSize, iconSize, iconSize);
            break;
        case Plasma::LeftEdge:
            m_closeButton->setGeometry(width() - iconSize, 0, iconSize, iconSize);
            m_moveButton->setGeometry(width() - iconSize, height() - iconSize, iconSize, iconSize);
            break;
        case Plasma::BottomEdge:
            m_closeButton->setGeometry(width() - iconSize, 0, iconSize, iconSize);
            m_moveButton->setGeometry(0, 0, iconSize, iconSize);
            break;
        default:
            break;
    }
    m_closeButton->raise();
    m_moveButton->raise();
}

void KeyboardDialog::swapScreenEdge()
{
    switch (m_location) {
    case Plasma::TopEdge:
        setLocation(Plasma::BottomEdge);
        break;
    case Plasma::RightEdge:
        setLocation(Plasma::LeftEdge);
        break;
    case Plasma::LeftEdge:
        setLocation(Plasma::RightEdge);
        break;
    case Plasma::BottomEdge:
        setLocation(Plasma::TopEdge);
        break;
    default:
        break;
    }
}

void KeyboardDialog::setRotation(const int degrees)
{
    if (degrees == m_rotation) {
        return;
    }

    m_rotation = degrees;
    const double pi = 3.141593;

    const double a    = pi/180 * degrees;
    const double sina = sin(a);
    const double cosa = cos(a);

    QTransform rotationTransform(cosa, sina, -sina, cosa, 0, 0);
    m_applet->setTransform(rotationTransform);
}

int KeyboardDialog::rotation() const
{
    return m_rotation;
}

void KeyboardDialog::setLocation(const Plasma::Location location)
{
    if (location == m_location) {
        return;
    }

    const Plasma::Location oldLocation = m_location;
    m_location = location;

    QDesktopWidget *desktop = QApplication::desktop();
    const QRect screenGeom = desktop->screenGeometry(desktop->screenNumber(this));

    switch (location) {
    case Plasma::TopEdge:
        setFixedSize(screenGeom.width() - 100, static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        move(screenGeom.left() + 50, screenGeom.top());
        m_moveButton->setIcon(KIcon("arrow-down"));
        break;
    case Plasma::RightEdge:
        setFixedSize(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).width(), screenGeom.height() - 100);
        move(screenGeom.right() - width(), screenGeom.top() + 50);
        m_moveButton->setIcon(KIcon("arrow-left"));
        break;
    case Plasma::LeftEdge:
        setFixedSize(static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).width(), screenGeom.height() - 100);
        move(screenGeom.left(), screenGeom.top() + 50);
        m_moveButton->setIcon(KIcon("arrow-right"));
        break;
    case Plasma::BottomEdge:
        setFixedSize(screenGeom.width() - 100, static_cast<Plasma::PopupApplet *>(applet())->graphicsWidget()->effectiveSizeHint(Qt::PreferredSize).height());
        move(screenGeom.left() + 50, screenGeom.height() - height());
        m_moveButton->setIcon(KIcon("arrow-up"));
        break;
    default:
        // we don't support this location, so just revert back
        m_location = oldLocation;
        break;
    }

    updateGeometry();
    if (isVisible()) {
        Plasma::WindowEffects::slideWindow(this, m_location);
    }
}

void KeyboardDialog::setDirection(const Plasma::Direction direction)
{
    if (direction == m_direction) {
        return;
    }

    m_direction = direction;

    switch (direction) {
    case Plasma::Down:
        setRotation(180);
        break;
    case Plasma::Left:
        setRotation(270);
        break;
    case Plasma::Right:
        setRotation(90);
        break;
    case Plasma::Up:
    default:
        setRotation(0);
        break;
    }

}

Plasma::Direction KeyboardDialog::direction() const
{
    return m_direction;
}

void KeyboardDialog::showEvent(QShowEvent *event)
{
    KWindowSystem::setType(winId(), NET::Dock);
    unsigned long state = NET::Sticky | NET::StaysOnTop | NET::KeepAbove;
    KWindowSystem::setState(winId(), state);
    KWindowSystem::raiseWindow(effectiveWinId());
    Plasma::Dialog::showEvent(event);

    //FIXME: this is an hack for the applet disabing itself in panic when doesn't immediately find a view
    Plasma::PopupApplet *pa = qobject_cast<Plasma::PopupApplet *>(m_applet);
    if (pa) {
        pa->graphicsWidget()->setEnabled(true);
    }
}

void KeyboardDialog::resizeEvent(QResizeEvent *event)
{
    if (event->oldSize() == event->size()) {
        return;
    }

    Plasma::Dialog::resizeEvent(event);
    QDesktopWidget *desktop = QApplication::desktop();
    switch (m_location) {
    case Plasma::TopEdge:
        move((desktop->size().width() / 2) - (event->size().width() / 2), desktop->screenGeometry().y());
        break;
    case Plasma::RightEdge:
        move(desktop->size().width() - event->size().width(), (desktop->size().height() / 2) - (event->size().height() / 2));
         break;
    case Plasma::LeftEdge:
        move(desktop->screenGeometry().x(), (desktop->size().height() / 2) - (event->size().width() / 2));
        break;
    case Plasma::BottomEdge:
        move((desktop->size().width() / 2) - (event->size().width() / 2), desktop->size().height() - event->size().height());
        break;
    default:
        break;
    }
}

QSize KeyboardDialog::transformedSize() const
{
    switch (m_direction) {
    case Plasma::Left:
    case Plasma::Right:
        return QSize(size().height(), size().width());
        break;
    case Plasma::Down:
    case Plasma::Up:
    default:
        return size();
        break;
    }
}

#include "keyboarddialog.moc"

