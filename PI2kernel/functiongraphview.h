#ifndef FUNCTIONGRAPHVIEW_H
#define FUNCTIONGRAPHVIEW_H


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

    int userToKernel(const char* messageToSend);

    //void graph2d(pointsy, rangex)
    //void graph3d(pointsz, rangex, rangey)
    //double* getRange2d(qstring range) ; graph gnuplot
    //double* getRange3d(qstring rangex, qstring rangey) ; graph gnuplot

private slots:
    void clickedButton2d();
    void clickedButton3d();
    void clickedButtonEnter2d();
    void clickedButtonEnter3d();
};

#endif // FUNCTIONGRAPHVIEW_H
