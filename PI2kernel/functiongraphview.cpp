#include "functiongraphview.h"
#include "ui_functiongraphview.h"
#include "usertokernel.h"

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <QRadioButton>
#include <QSignalMapper>

functiongraphview::functiongraphview(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::functiongraphview)
{

    this->ui->setupUi(this);

    this->ui->funcion2d->setPlaceholderText("Funcion de una variable");
    this->ui->funcion3d->setPlaceholderText("Funcion de dos variables");

    this->connect( ui->pushButton2d, &QRadioButton::clicked, this, &functiongraphview::clickedButton2d);
    this->connect( ui->pushButton3d, &QRadioButton::clicked, this, &functiongraphview::clickedButton3d);

    this->connect(ui->enter2d, &QRadioButton::clicked, this, &functiongraphview::clickedButtonEnter2d );
    this->connect(ui->enter3d, &QRadioButton::clicked, this, &functiongraphview::clickedButtonEnter3d );



}

functiongraphview::~functiongraphview()
{
    delete ui;
}

int functiongraphview::userToKernel(const char *messageToSend)
{
    int error = 0;
    usertokernel kernel = usertokernel();
    error = kernel.callKernel(messageToSend);
    return 0;
}



void functiongraphview::clickedButton2d()
{
    ui->funcion2d->setEnabled(true);
    ui->range2d->setEnabled(true);
    ui->enter2d->setEnabled(true);
    ui->incremento2d->setEnabled(true);

    ui->funcion3d->setEnabled(false);
    ui->range3dx->setEnabled(false);
    ui->range3dy->setEnabled(false);
    ui->enter3d->setEnabled(false);
    ui->incremento3d->setEnabled(false);
}

void functiongraphview::clickedButton3d()
{
    ui->funcion2d->setEnabled(false);
    ui->range2d->setEnabled(false);
    ui->enter2d->setEnabled(false);
    ui->incremento2d->setEnabled(false);

    ui->funcion3d->setEnabled(true);
    ui->range3dx->setEnabled(true);
    ui->range3dy->setEnabled(true);
    ui->enter3d->setEnabled(true);
    ui->incremento3d->setEnabled(true);

}

void functiongraphview::clickedButtonEnter2d()
{
    QString function = ui->funcion2d->text();
    QString range = ui->range2d->text();
    QString increment = ui->incremento2d->text();
    QString messageToSend = function + "/" + range + "/" + increment + "/2D";
    parentWidget()->close();
    userToKernel(messageToSend.toStdString().c_str());
}

void functiongraphview::clickedButtonEnter3d()
{
    QString function = ui->funcion3d->text();
    QString rangeX = ui->range3dx->text();
    QString rangeY = ui->range3dy->text();
    QString increment = ui->incremento3d->text();
    QString messageToSend = function + "/" + rangeX + "/" + rangeY + "/" + increment + "/3D";
    parentWidget()->close();
    userToKernel(messageToSend.toStdString().c_str());
}


