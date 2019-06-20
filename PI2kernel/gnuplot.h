#ifndef GNUPLOT_H
#define GNUPLOT_H

#include <QString>

class gnuplot
{

public:
    gnuplot();
    void getFunction(QString function);
    void getRange(QString range);
    void plot2d(double *points, double begin, double end);

};

#endif // GNUPLOT_H
