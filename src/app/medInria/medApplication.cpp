/*=========================================================================

 medInria

 Copyright (c) INRIA 2013. All rights reserved.

 See LICENSE.txt for details in the root of the sources or:
 https://github.com/medInria/medInria-public/blob/master/LICENSE.txt

 This software is distributed WITHOUT ANY WARRANTY; without even
 the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE.

=========================================================================*/

#include "medApplication.h"

#include <medAbstractDataFactory.h>
#include <medCore.h>
#include <medDatabaseSettingsWidget.h>
#include <medDevelopmentSettingsWidget.h>
#include <medDataManager.h>
#include <medDiffusionWorkspace.h>
#include <medFilteringWorkspace.h>
#include <medLogger.h>
#include <medMainWindow.h>
#include <medPluginManager.h>
#include <medSeedPointAnnotationData.h>
#include <medSettingsManager.h>
#include <medSettingsWidgetFactory.h>
#include <medStartupSettingsWidget.h>
#include <medStyleSheetParser.h>
#include <medVisualizationWorkspace.h>
#include <medWorkspaceFactory.h>

#define VAL(str) #str
#define TOSTRING(str) VAL(str)

class medApplicationPrivate
{
public:
    medMainWindow *mainWindow;
    QStringList systemOpenInstructions;
    QSplashScreen *splashScreen;
};

// /////////////////////////////////////////////////////////////////
// medApplication
// /////////////////////////////////////////////////////////////////

medApplication::medApplication(int & argc, char**argv) :
    QtSingleApplication(argc,argv),
    d(new medApplicationPrivate)
{
    d->mainWindow = nullptr;

    this->setApplicationName(TOSTRING(APPLICATION_NAME));
    this->setOrganizationName(TOSTRING(ORGANIZATION_NAME));
    this->setOrganizationDomain(TOSTRING(ORGANIZATION_DOMAIN));
    this->setWindowIcon(QIcon(TOSTRING(WINDOW_ICON)));
    this->setApplicationVersion(MEDINRIA_VERSION);

    medLogger::initialize();

    qInfo() << "####################################";
    qInfo() << "Version: "    << MEDINRIA_VERSION;
    qInfo() << "Build Date: " << MEDINRIA_BUILD_DATE;

    initializeSplashScreen();
    initializeThemes();

    QApplication::setStyle(QStyleFactory::create("fusion"));

    // Expiration Date
    QDate expiryDate = QDate::fromString(QString(MEDINRIA_BUILD_DATE), "dd_MM_yyyy")
                                        .addMonths(QString(TOSTRING(EXPIRATION_TIME)).toInt());
    qInfo() << "Expiration Date: " << qPrintable(expiryDate.toString());

    if ( ! expiryDate.isValid() || QDate::currentDate() > expiryDate)
    {
        QString expiredInfo = "This copy of ";
        expiredInfo += TOSTRING(PROJECT_NAME);
        expiredInfo += " has expired, please contact ";
        expiredInfo += TOSTRING(PROJECT_CONTACT);
        expiredInfo += " for more information.";
        QMessageBox msg;
        msg.setText(expiredInfo);
        msg.exec();
        ::exit(1);
    }

    this->initialize();
}

medApplication::~medApplication(void)
{
    delete d;
    d = nullptr;
}

bool medApplication::event(QEvent *event)
{
    switch (event->type())
    {
        // Handle file system open requests, but only if the main window has been created and set
        case QEvent::FileOpen:
            if (d->mainWindow)
                emit messageReceived(QString("/open ") + static_cast<QFileOpenEvent *>(event)->file());
            else
                d->systemOpenInstructions.append(QString("/open ") + static_cast<QFileOpenEvent *>(event)->file());

            return true;
        default:
            return QtSingleApplication::event(event);
    }
}

void medApplication::setMainWindow(medMainWindow *mw)
{
    d->mainWindow = mw;

    QVariant var = QVariant::fromValue((QObject*)d->mainWindow);
    this->setProperty("MainWindow",var);
    d->systemOpenInstructions.clear();

    // Wait until the app is displayed to close itself
    d->splashScreen->finish(d->mainWindow); 
}

void medApplication::redirectMessageToSplash(const QString &message)
{
    emit showMessage(message);
}

void medApplication::open(const medDataIndex & index)
{
    d->mainWindow->open(index);
}

void medApplication::open(QString path)
{
    d->mainWindow->open(path);
}

void medApplication::initialize()
{
    qRegisterMetaType<medDataIndex>("medDataIndex");

    // Registering different workspaces
    medWorkspaceFactory * viewerWSpaceFactory = medWorkspaceFactory::instance();
    viewerWSpaceFactory->registerWorkspace<medVisualizationWorkspace>();
    viewerWSpaceFactory->registerWorkspace<medDiffusionWorkspace>();
    viewerWSpaceFactory->registerWorkspace<medFilteringWorkspace>();

    //Register settingsWidgets
    medSettingsWidgetFactory* settingsWidgetFactory = medSettingsWidgetFactory::instance();
    settingsWidgetFactory->registerSettingsWidget<medStartupSettingsWidget>();
    settingsWidgetFactory->registerSettingsWidget<medDatabaseSettingsWidget>();
    settingsWidgetFactory->registerSettingsWidget<medDevelopmentSettingsWidget>();

    //Register annotations
    medAbstractDataFactory * datafactory = medAbstractDataFactory::instance();
    datafactory->registerDataType<medSeedPointAnnotationData>();

    // process layer:
    QString pluginsPath = getenv("MEDINRIA_PLUGINS_DIR");
    QString defaultPath;
    QDir plugins_dir;
#ifdef Q_OS_MAC
    plugins_dir = qApp->applicationDirPath() + "/../PlugIns";
#elif defined(Q_OS_WIN)
    plugins_dir = qApp->applicationDirPath() + "/plugins";
#else
    plugins_dir.setPath(qApp->applicationDirPath() + "/plugins");
#endif
    defaultPath = plugins_dir.absolutePath();

    if ( !pluginsPath.isEmpty() )
        medCore::pluginManager::initialize(pluginsPath);
    else
        medCore::pluginManager::initialize(defaultPath);
}

/**
 * @brief Get back the previous screen used to display the application
 * 
 * @return QScreen 
 */
QScreen* medApplication::getPreviousScreen()
{
    medSettingsManager &manager = medSettingsManager::instance();
    int currentScreen = 0;
    QVariant currentScreenQV = manager.value("medMainWindow", "currentScreen");
    if (!currentScreenQV.isNull())
    {
        currentScreen = currentScreenQV.toInt();

        // If the previous used screen has been removed, initialization
        if (currentScreen >= QApplication::desktop()->screenCount())
        {
            currentScreen = 0;
        }
    }
    return screens().at(currentScreen);
}

/**
 * @brief Set the Qt splash screen to the application logo.
 * 
 */
void medApplication::initializeSplashScreen()
{
    // // Themes
    // QVariant themeChosen = medSettingsManager::instance().value("startup","theme");
    // int themeIndex = themeChosen.toInt();
    // QPixmap splashLogo;
    // switch (themeIndex)
    // {
    //     case 0:
    //     default:
    //     {
    //         splashLogo.load(TOSTRING(LARGE_LOGO_DARK_THEME));
    //         break;
    //     }
    //     case 1:
    //     case 2:
    //     {
    //         splashLogo.load(TOSTRING(LARGE_LOGO_LIGHT_THEME));
    //         break;
    //     }
    // }

    d->splashScreen = new QSplashScreen(getPreviousScreen(), QPixmap(":/pixmaps/medInria-splash.png"),
        Qt::WindowStaysOnTopHint | Qt::X11BypassWindowManagerHint);
    d->splashScreen->setAttribute(Qt::WA_DeleteOnClose, true);
    d->splashScreen->show();
    this->processEvents();
}

/**
 * @brief Parse the theme file chosen by user in settings.
 * 
 */
void medApplication::initializeThemes()
{
    QApplication::setStyle(QStyleFactory::create("fusion"));

    int themeIndex = medSettingsManager::instance().value("startup","theme").toInt();
    QString qssFile;
    switch (themeIndex)
    {
    case 0:
    default:
        // Dark Grey
        qssFile = ":/music_darkGrey.qss";
        break;
    case 1:
        // Dark Blue
        qssFile = ":/music_dark.qss";
        break;
    case 2:
        // medInria
        qssFile = ":/medInria.qss";
        break;
    case 3:
        // Light Grey
        qssFile = ":/music_lightGrey.qss";
        break;
    case 4:
        // Light
        qssFile = ":/music_light.qss";
        break;
    }
    medStyleSheetParser parser(dtkReadFile(qssFile));
    this->setStyleSheet(parser.result());

    // Unblur icons for instance on retina screens
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps); 
}
