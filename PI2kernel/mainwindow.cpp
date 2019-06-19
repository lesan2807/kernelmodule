#include "mainwindow.h"
#include "ui_functiongraphview.h"
#include <functiongraphview.h>



MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    this->buildInterface();
    this->showMenu();
}

void MainWindow::buildInterface()
{
    this->setWindowTitle("Graficador de funciones");

#if ! defined(Q_OS_ANDROID) && ! defined(Q_OS_IOS)
  this->resize(320, 480);
#endif
}

void MainWindow::showMenu()
{
    functiongraphview* graphFuncionView = new functiongraphview(this);
    this->setCentralWidget( graphFuncionView );

}

MainWindow::~MainWindow()
{

}
