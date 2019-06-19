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
  this->resize(500, 200);
#endif
}

void MainWindow::showMenu()
{
    functiongraphview* graphFuncionView = new functiongraphview(this);
    graphFuncionView->setLayout(graphFuncionView->ui->verticalLayout);

    this->setCentralWidget( graphFuncionView );
}

MainWindow::~MainWindow()
{

}
