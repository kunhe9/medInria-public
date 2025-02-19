/*=========================================================================

 medInria

 Copyright (c) INRIA 2013 - 2020. All rights reserved.
 See LICENSE.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even
  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  PURPOSE.

=========================================================================*/

#include <QtGui>
#include <QtOpenGL>
#include <QSurfaceFormat>

#ifdef WIN32
#include <QtPlatformHeaders/QWindowsWindowFunctions>
#endif

#if(USE_PYTHON)
#include <pyncpp.h>
#endif

#include <medMainWindow.h>
#include <medApplication.h>
#include <medSplashScreen.h>

#include <medPluginManager.h>
#include <medDataIndex.h>
#include <medDataManager.h>
#include <medSettingsManager.h>
#include <medStorage.h>

#include <dtkCoreSupport/dtkGlobal.h>


void forceShow(medMainWindow& mainwindow )
{
    //Idea and code taken from the OpenCOR project, Thanks Allan for the code!


    // Note: to show ourselves, one would normally use activateWindow(), but
    //       depending on the operating system it may or not bring medInria to
    //       the foreground, so... instead we do what follows, depending on the
    //       operating system...

//#if defined(Q_OS_WIN)
//    // Retrieve window Id

//    WId mainWinId = mainwindow.winId();

//    // Bring main window to the foreground
//    SetForegroundWindow(mainWinId);

//    // Show/restore the window, depending on its current state

//    if (IsIconic(mainWinId))
//        ShowWindow(mainWinId, SW_RESTORE);
//    else
//        ShowWindow(mainWinId, SW_SHOW);

//    // Note: under Windows, to use activateWindow() will only highlight the
//    //       application in the taskbar, since under Windows no application
//    //       should be allowed to bring itself to the foreground when another
//    //       application is already in the foreground. Fair enough, but it
//    //       happens that, here, the user wants medInria to be brought to the
//    //       foreground, hence the above code to get the effect we are after...
//#else
    mainwindow.activateWindow();
    mainwindow.raise();
//#endif
}

int main(int argc,char* argv[])
{
    // Setup openGL surface compatible with QVTKOpenGLWidget,
    // required by medVtkView
    QSurfaceFormat fmt;
    fmt.setRenderableType(QSurfaceFormat::OpenGL);
    fmt.setVersion(3, 2);
    fmt.setProfile(QSurfaceFormat::CoreProfile);
    fmt.setSwapBehavior(QSurfaceFormat::DoubleBuffer);
    fmt.setRedBufferSize(1);
    fmt.setGreenBufferSize(1);
    fmt.setBlueBufferSize(1);
    fmt.setDepthBufferSize(1);
    fmt.setStencilBufferSize(0);
    fmt.setAlphaBufferSize(1);
    fmt.setStereo(false);
    fmt.setSamples(0);

    QSurfaceFormat::setDefaultFormat(fmt);

    // this needs to be done before creating the QApplication object, as per the
    // Qt doc, otherwise there are some edge cases where the style is not fully applied
    //QApplication::setStyle("plastique");
    medApplication application(argc,argv);

    // Themes
    QVariant themeChosen = medSettingsManager::instance()->value("startup","theme");
    int themeIndex = themeChosen.toInt();
    QPixmap splashLogo;
    switch (themeIndex)
    {
        case 0:
        case 1:
        case 2:
        default:
        {
            splashLogo.load(":MUSICardio_logo_darkbackground_notext.png");
            break;
        }
        case 3:
        case 4:
        {
            splashLogo.load(":MUSICardio_logo_lightbackground_notext.png");
            break;
        }
    }
    splashLogo = splashLogo.scaled(914, 147, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    medSplashScreen splash(splashLogo);

    setlocale(LC_NUMERIC, "C");
    QLocale::setDefault(QLocale("C"));

    if (dtkApplicationArgumentsContain(&application, "-h") || dtkApplicationArgumentsContain(&application, "--help"))
    {
        qDebug() << "Usage: "
                 << QFileInfo(argv[0]).baseName().toStdString().c_str()
                 << "[--fullscreen|--no-fullscreen] "
                 << "[--stereo] "
                 << "[--debug] "
            #ifdef ACTIVATE_WALL_OPTION
                 << "[[--wall] [--tracker=URL]] "
            #endif
                 << "[[--view] [files]]";
        return 1;
    }

    // Do not show the splash screen in debug builds because it hogs the
    // foreground, hiding all other windows. This makes debugging the startup
    // operations difficult.

    #if !defined(_DEBUG)
    bool show_splash = true;
    #else
    bool show_splash = false;
    #endif

    medSettingsManager* mnger = medSettingsManager::instance();

    QStringList posargs;
    for (int i=1;i<application.arguments().size();++i)
    {
        const QString arg = application.arguments().at(i);
        if (arg.startsWith("--"))
        {
            bool valid_option = false;
            const QStringList options =
                    (QStringList()
                     << "--fullscreen"
                     << "--no-fullscreen"
                     << "--wall"
                     << "--tracker"
                     << "--stereo"
                     << "--view"
                     << "--debug");
            for (QStringList::const_iterator opt=options.constBegin();opt!=options.constEnd();++opt)
            {
                if (arg.startsWith(*opt))
                {
                    valid_option = true;
                }
            }
            if (!valid_option)
            {
                qDebug() << "Ignoring unknown option " << arg;
            }
            continue;
        }
        posargs.append(arg);
    }

    const bool DirectView = dtkApplicationArgumentsContain(&application,"--view") || posargs.size()!=0;

    int runningMedInria = 0;
    if (DirectView) {
        show_splash = false;
        for (QStringList::const_iterator i=posargs.constBegin();i!=posargs.constEnd();++i) {
            const QString& message = QString("/open ")+*i;
            runningMedInria = application.sendMessage(message);
        }
    } else {
        runningMedInria = application.sendMessage("");
    }

    if (runningMedInria)
        return 0;

    if (show_splash)
    {
        QObject::connect(medPluginManager::instance(),SIGNAL(loaded(QString)),
                         &application,SLOT(redirectMessageToSplash(QString)) );
        QObject::connect(&application,SIGNAL(showMessage(const QString&)),
                         &splash,SLOT(showMessage(const QString&)) );
        splash.show();
        splash.showMessage("Loading plugins...");
    }

    medDataManager::instance()->setDatabaseLocation();

#if(USE_PYTHON)
    pyncpp::Manager pythonManager;
    QDir pythonHome = qApp->applicationDirPath();
    QString pythonErrorMessage;

    if (!pythonHome.cd(PYTHON_HOME))
    {
        pythonErrorMessage = "The embedded Python could not be found ";
    }
    else
    {
        if(!pythonManager.initialize(qUtf8Printable(pythonHome.absolutePath())))
        {
            pythonErrorMessage = "Initialization of the embedded Python failed.";
        }
    }
#endif

    medPluginManager::instance()->setVerboseLoading(true);
    medPluginManager::instance()->initialize();

    //Use Qt::WA_DeleteOnClose attribute to be sure to always have only one closeEvent.
    medMainWindow *mainwindow = new medMainWindow;
    mainwindow->setAttribute(Qt::WA_DeleteOnClose, true);

    if (DirectView)
        mainwindow->setStartup(medMainWindow::WorkSpace,posargs);

    bool fullScreen = medSettingsManager::instance()->value("startup", "fullscreen", false).toBool();
    
    const bool hasFullScreenArg   = application.arguments().contains("--fullscreen");
    const bool hasNoFullScreenArg = application.arguments().contains("--no-fullscreen");
    const bool hasWallArg         = application.arguments().contains("--wall");

    const int conflict = static_cast<int>(hasFullScreenArg)+static_cast<int>(hasNoFullScreenArg)+ static_cast<int>(hasWallArg);

    if (conflict>1)
        dtkWarn() << "Conflicting command line parameters between --fullscreen, --no-fullscreen and -wall. Ignoring.";
    else {
        if (hasWallArg) {
            mainwindow->setWallScreen(true);
            fullScreen = false;
        }

        if (hasFullScreenArg)
            fullScreen = true;

        if (hasNoFullScreenArg)
            fullScreen = false;
    }

    mainwindow->setFullScreen(fullScreen);
#ifdef WIN32
    QWindowsWindowFunctions::setHasBorderInFullScreen(mainwindow->windowHandle(), true);
#endif

    if(application.arguments().contains("--stereo")) {
       QGLFormat format;
       format.setAlpha(true);
       format.setDoubleBuffer(true);
       format.setStereo(true);
       format.setDirectRendering(true);
       QGLFormat::setDefaultFormat(format);
    }

    if (show_splash)
        splash.finish(mainwindow);

#if(USE_PYTHON)
    if(!pythonErrorMessage.isEmpty())
    {
        QMessageBox::warning(mainwindow, "Python", pythonErrorMessage);
        qWarning() << pythonErrorMessage;
    }
#endif

    if (medPluginManager::instance()->plugins().isEmpty()) {
        QMessageBox::warning(mainwindow,
                             QObject::tr("No plugin loaded"),
                             QObject::tr("Warning : no plugin loaded successfully."));
    }

    // Handle file associations open requests that were not handled in the application
    QObject::connect(&application,SIGNAL(messageReceived(const QString&)),
                     mainwindow,SLOT(processNewInstanceMessage(const QString&)));

    application.setMainWindow(mainwindow);

    forceShow(*mainwindow);

    qInfo() << "### Application is running...";

    //  Start main loop.
    const int status = application.exec();

    medPluginManager::instance()->uninitialize();

    return status;
}
