#include "functiongraphview.h"
#include "ui_functiongraphview.h"

#include <QRadioButton>

functiongraphview::functiongraphview(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::functiongraphview)
{
    this->ui->setupUi(this);
    this->ui->range2d->setPlaceholderText("Rango");
    this->ui->range3d->setPlaceholderText("Rango");
    this->ui->funcion2d->setPlaceholderText("Funcion de una variable");
    this->ui->funcion3d->setPlaceholderText("Funcion de dos variables");

    this->connect( ui->pushButton2d, &QRadioButton::clicked, this, &functiongraphview::clickedButton2d);
    this->connect( ui->pushButton3d, &QRadioButton::clicked, this, &functiongraphview::clickedButton3d);
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
}

void functiongraphview::clickedButton3d()
{
    ui->funcion2d->setEnabled(false);
    ui->range2d->setEnabled(false);
    ui->funcion3d->setEnabled(true);
    ui->range3d->setEnabled(true);
}

