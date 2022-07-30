#define snapshot 20210108
#define commit 6204b90a5106e1a8acb1853efa0c8555d7c3097c
%define plasmaver %(echo %{version} |cut -d. -f1-3)
%define stable %([ "`echo %{version} |cut -d. -f3`" -ge 80 ] && echo -n un; echo -n stable)

Name:		plasma-phone-components
Version:	5.23.5
Summary:	Plasma components for mobile phones
Source0:	plasma-ayya-5.23.5.tar.gz
Release:	2
Patch0:		plasma-phone-components-x11-session.patch
Patch2:		plasma-phone-components-dont-start-to-lockscreen.patch
License:	GPLv2/LGPLv2/LGPLv2.1
Group:		Graphical desktop/KDE
BuildRequires:	cmake(ECM)
BuildRequires:	cmake(Qt5Core)
BuildRequires:	cmake(Qt5Quick)
BuildRequires:	cmake(Qt5Test)
BuildRequires:	cmake(Qt5Gui)
BuildRequires:	cmake(KF5Akonadi)
BuildRequires:	cmake(KF5Libkdepim)
BuildRequires:	cmake(KF5WindowSystem)
BuildRequires:	cmake(KF5Codecs)
BuildRequires:	cmake(KF5Archive)
BuildRequires:	cmake(KF5CoreAddons)
BuildRequires:	cmake(KF5Solid)
BuildRequires:	cmake(KF5Config)
BuildRequires:	cmake(KF5Auth)
BuildRequires:	cmake(KF5DBusAddons)
BuildRequires:	cmake(KF5Sonnet)
BuildRequires:	cmake(KF5I18n)
BuildRequires:	cmake(KF5Service)
BuildRequires:	cmake(KF5Notifications)
BuildRequires:	cmake(KF5IconThemes)
BuildRequires:	cmake(KF5Completion)
BuildRequires:	cmake(KF5Bookmarks)
BuildRequires:	cmake(KF5Wayland)
BuildRequires:	cmake(KF5Plasma)
BuildRequires:	cmake(KF5PlasmaQuick)
BuildRequires:	cmake(KF5Declarative)
BuildRequires:	cmake(KF5KIO)
BuildRequires:	cmake(KF5Activities)
BuildRequires:	cmake(KF5Baloo)
BuildRequires:	cmake(PkgConfig)
BuildRequires:	cmake(KWinDBusInterface)
BuildRequires:	cmake(KF5ModemManagerQt)
BuildRequires:	pkgconfig(gstreamer-1.0)
Requires:	plasma-workspace
Requires:	plasma-nano
Requires:	qml(org.kde.plasma.core)
Requires:	qml(org.kde.plasma.components)
Requires:	qml(org.kde.plasma.workspace.components)
Requires:	qml(org.kde.plasma.networkmanagement)
Requires:	qml(org.kde.bluezqt)
Requires:	qml(org.kde.plasma.private.volume)
Requires:	qml(org.kde.notificationmanager)
Requires:	qml(org.kde.kirigami)
Requires:	qml(org.kde.taskmanager)
Requires:	qml(org.kde.plasma.private.nanoshell)
Requires:	qml(org.kde.plasma.private.mobileshell)
Requires:	qml(org.kde.plasma.private.containmentlayoutmanager)
Requires:	qml(org.kde.kquickcontrolsaddons)
Requires:	qml(org.kde.draganddrop)
Requires:	qml(org.kde.plasma.extras)
Requires:	qml(org.kde.milou)
Requires:	qml(QtGraphicalEffects)
Requires:	qt5-qtquickcontrols2
Requires:	kwin
Requires:	plasma-pa
Requires:	plasma-nm-mobile
# Used by the screenshot button
Requires:	spectacle

%description
Plasma components for mobile phones.

%package wayland
Summary:	Wayland session files for Plasma phone components
Requires:	plasma-workspace-wayland

%description wayland
Wayland session files for Plasma phone components.

%package x11
Summary:	X11 session files for Plasma phone components
Requires:	plasma-workspace-x11

%description x11
X11 session files for Plasma phone components.

%prep
%autosetup -p1
%cmake_kde5

%build
%ninja_build -C build

%install
%ninja_install -C build
%find_lang %{name} --all-name

%files -f %{name}.lang
%{_libdir}/qt5/plugins/plasma/applets/plasma_applet_phonepanel.so
%{_libdir}/qt5/plugins/plasma/applets/plasma_containment_phone_homescreen.so
%{_libdir}/qt5/plugins/plasma/applets/plasma_containment_phone_taskpanel.so
#%{_libdir}/qt5/qml/QtQuick/VirtualKeyboard
%{_libdir}/qt5/qml/org/kde/plasma/mm
%{_libdir}/qt5/qml/org/kde/plasma/private/mobileshell
%{_libdir}/qt5/qml/org/kde/plasma/private/mobilehomescreencomponents
%{_datadir}/metainfo/org.kde.phone.activities.appdata.xml
%{_datadir}/metainfo/org.kde.phone.krunner.appdata.xml
%{_datadir}/metainfo/org.kde.plasma.phone.appdata.xml
%{_datadir}/plasma/look-and-feel/org.kde.plasma.phone
%{_datadir}/plasma/plasmoids/org.kde.phone.activities
%{_datadir}/plasma/plasmoids/org.kde.phone.homescreen
%{_datadir}/plasma/plasmoids/org.kde.phone.krunner
%{_datadir}/plasma/plasmoids/org.kde.phone.panel
%{_datadir}/plasma/plasmoids/org.kde.phone.taskpanel
%{_datadir}/knotifications5/plasma_phone_components.notifyrc
%{_datadir}/plasma/shells/org.kde.plasma.phoneshell
%{_datadir}/metainfo/org.kde.plasma.phoneshell.appdata.xml
%{_datadir}/plasma/quicksettings/org.kde.plasma.airplanemode
%{_datadir}/plasma/quicksettings/org.kde.plasma.nightcolor
%{_datadir}/kservices5/plasma-applet-org.kde.phone.activities.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.phone.homescreen.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.phone.krunner.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.phone.panel.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.phone.taskpanel.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.plasma.airplanemode.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.plasma.nightcolor.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.plasma.phone.desktop
%{_datadir}/kservices5/plasma-applet-org.kde.plasma.phoneshell.desktop

%files wayland
%{_bindir}/kwinwrapper
%{_datadir}/wayland-sessions/plasma-mobile.desktop

%files x11
%{_bindir}/kwinwrapper_x11
%{_datadir}/xsessions/plasma-mobile-x11.desktop
