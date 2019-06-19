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

private:
    Ui::functiongraphview *ui = nullptr;

private slots:
    void clickedButton2d();
    void clickedButton3d();
};

#endif // FUNCTIONGRAPHVIEW_H
