/*
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2009 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
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

#include "plasmaapp.h"
#include "plasmakeyboardshelladaptor.h"
#include "keyboardcorona.h"

#include <unistd.h>

#include <QApplication>
#include <QPixmapCache>
#include <QTimer>
#include <QVBoxLayout>
#include <QtDBus/QtDBus>
#include <QDesktopWidget>

#include <KAction>
#include <KCrash>
#include <KColorUtils>
#include <KDebug>
#include <KStandardAction>
#include <KWindowSystem>
#include <KSharedConfig>

#include <Plasma/Containment>
#include <Plasma/Theme>
#include <Plasma/PopupApplet>
#include <Plasma/Wallpaper>
#include <Plasma/WindowEffects>


#include "keyboarddialog.h"


PlasmaApp* PlasmaApp::self()
{
    if (!kapp) {
        return new PlasmaApp();
    }

    return qobject_cast<PlasmaApp*>(kapp);
}

PlasmaApp::PlasmaApp()
    : KUniqueApplication(),
      m_corona(0),
      m_dialog(0)
{
    KGlobal::locale()->insertCatalog("plasma-keyboardcontainer");
    KCrash::setFlags(KCrash::AutoRestart);

    KConfigGroup cg(KGlobal::config(), "General");
    Plasma::Theme::defaultTheme()->setFont(cg.readEntry("desktopFont", font()));

    cg = KConfigGroup(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    corona();
    m_containment = m_corona->addContainment("null");

    new PlasmaKeyboardAdaptor(this);
    QDBusConnection::sessionBus().registerObject("/App", this);

    connect(this, SIGNAL(aboutToQuit()), this, SLOT(cleanup()));
}

PlasmaApp::~PlasmaApp()
{
}

KConfigGroup PlasmaApp::storedConfig()
{
    KConfigGroup cg(KGlobal::config(), "KeyboardConfig");
    return cg;
}

int  PlasmaApp::newInstance()
{
    if (m_dialog) {
        return 0;
    }

    const QString pluginName = "plasmaboard";

    KConfigGroup config = storedConfig();
    KConfigGroup actualConfig(m_containment->config());
    actualConfig = KConfigGroup(&actualConfig, "Applets");
    actualConfig = KConfigGroup(&actualConfig, QString::number(1));

    config.copyTo(&actualConfig);
    config.deleteGroup();

    KeyboardDialog *dialog = new KeyboardDialog(m_corona, m_containment, pluginName, 1, QVariantList());
    dialog->installEventFilter(this);
    connect(dialog, SIGNAL(storeApplet(Plasma::Applet*)), this, SLOT(storeApplet(Plasma::Applet*)));

    dialog->setWindowFlags(Qt::FramelessWindowHint);
    KWindowSystem::setType(dialog->winId(), NET::Dock);
    Plasma::WindowEffects::overrideShadow(dialog->winId(), true);
    dialog->applet()->setBackgroundHints(Plasma::Applet::NoBackground);

    // Set window to exist on all desktops
    KWindowSystem::setOnAllDesktops(dialog->winId(), true);

    //FIXME: hardcoding to MID for now
    dialog->applet()->config().writeEntry("layout", "plasmaboard/tablet.xml");
    dialog->applet()->configChanged();

    dialog->hide();

    m_dialog = dialog;

    return 0;
}


void PlasmaApp::cleanup()
{
    if (m_corona) {
        m_corona->saveLayout();
    }

    delete m_dialog;

    delete m_corona;
    m_corona = 0;

    //TODO: This manual sync() should not be necessary?
    syncConfig();
}

void PlasmaApp::storeApplet(Plasma::Applet *applet)
{
    KConfigGroup storage = storedConfig();
    KConfigGroup cg(applet->containment()->config());
    cg = KConfigGroup(&cg, "Applets");
    cg = KConfigGroup(&cg, QString::number(applet->id()));
    delete applet;
//    kDebug() << "storing" << applet->name() << applet->id() << "to" << storage.name() << ", applet config is" << cg.name();
    cg.reparent(&storage);
}


void PlasmaApp::syncConfig()
{
    KGlobal::config()->sync();
}

Plasma::Corona* PlasmaApp::corona()
{
    if (!m_corona) {
        m_corona = new KeyboardCorona(this);
        connect(m_corona, SIGNAL(configSynced()), this, SLOT(syncConfig()));

        m_corona->setItemIndexMethod(QGraphicsScene::NoIndex);
    }

    return m_corona;
}

bool PlasmaApp::hasComposite()
{
    return KWindowSystem::compositingActive();
}


void PlasmaApp::setDirection(const QString &direction)
{
    Plasma::Direction dir;
    if (direction == "up") {
        dir = Plasma::Up;
    } else if (direction == "down") {
        dir = Plasma::Down;
    } else if (direction == "left") {
        dir = Plasma::Left;
    } else if (direction == "right") {
        dir = Plasma::Right;
    } else {
        dir = Plasma::Down;
    }

    m_dialog->setDirection(dir);
}

void PlasmaApp::show()
{
    Plasma::WindowEffects::slideWindow(m_dialog, m_dialog->location());
    m_dialog->show();
    //if the cursor is outside the keyboard at the first touch event, the current window loses focus and the keyboard will hide
    QCursor::setPos(m_dialog->geometry().center());
}

void PlasmaApp::hide()
{
    Plasma::WindowEffects::slideWindow(m_dialog, m_dialog->location());
    m_dialog->hide();
}

#include "plasmaapp.moc"
