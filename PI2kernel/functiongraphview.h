#ifndef FUNCTIONGRAPHVIEW_H
#define FUNCTIONGRAPHVIEW_H

#include "gnuplot.h"

#include <QWidget>

namespace Ui {
class functiongraphview;
}

class functiongraphview : public QWidget
{
    Q_OBJECT

public:
    explicit functiongraphview(QWidget *parent = nullptr);
    virtual ~functiongraphview();
    Ui::functiongraphview *ui = nullptr;
    gnuplot* plot = nullptr;


private slots:
    void clickedButton2d();
    void clickedButton3d();
    void clickedButtonEnter2d();
    void clickedButtonEnter3d();
};

#endif // FUNCTIONGRAPHVIEW_H
