/*=========================================================================

 medInria

 Copyright (c) INRIA 2013 - 2018. All rights reserved.
 See LICENSE.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even
  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  PURPOSE.

=========================================================================*/

#pragma once

#include <QtGui>
#include <QtWidgets>

class medHomepageAreaPrivate;

class medHomepageArea : public QWidget
{
Q_OBJECT
public:
    medHomepageArea(QWidget * parent = 0);
    virtual ~medHomepageArea();

    void initPage();

    void resizeEvent( QResizeEvent * event );

public slots:
    void onShowBrowser();
    void onShowWorkspace(QString workspace);
    void onShowSettings();
    void onShowAbout();
    void onShowPlugin();
    void onShowHelp();
    // void onShowAuthors();
    void onShowComposer();
    void openLogDirectory();
    // void onShowReleaseNotes();
    // void onShowLicense();
    void onShowInfo();
    // void onShowExtLicenses();

signals:
    void showBrowser();
    void showViewer();
    void showWorkspace(QString workspace);

// protected:
//     void expandDetailedText(QMessageBox*);

private:
    medHomepageAreaPrivate * d;
};


