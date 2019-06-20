#include "functiongraphview.h"
#include "ui_functiongraphview.h"

#include <iostream>

#include <QRadioButton>
#include <QSignalMapper>

functiongraphview::functiongraphview(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::functiongraphview),
    plot(new gnuplot)
{

    this->ui->setupUi(this);

    this->ui->range2d->setPlaceholderText("Rango");
    this->ui->range3d->setPlaceholderText("Rango");
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

void functiongraphview::clickedButton2d()
{
    ui->funcion2d->setEnabled(true);
    ui->range2d->setEnabled(true);
    ui->funcion3d->setEnabled(false);
    ui->range3d->setEnabled(false);
    ui->enter2d->setEnabled(true);
    ui->enter3d->setEnabled(false);
}

void functiongraphview::clickedButton3d()
{
    ui->funcion2d->setEnabled(false);
    ui->range2d->setEnabled(false);
    ui->funcion3d->setEnabled(true);
    ui->range3d->setEnabled(true);
    ui->enter2d->setEnabled(false);
    ui->enter3d->setEnabled(true);
}

void functiongraphview::clickedButtonEnter2d()
{
    QString function = ui->funcion2d->text();
    QString range = ui->funcion2d->text();
    plot->getFunction(function);
    plot->getRange(range);
}

void functiongraphview::clickedButtonEnter3d()
{

}


