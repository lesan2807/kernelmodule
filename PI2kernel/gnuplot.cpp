#include "gnuplot.h"
#include "gnuplot-iostream.h"

#include <vector>

#include <boost/tuple/tuple.hpp>
#include <boost/foreach.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/array.hpp>
#include <boost/range/adaptor/transformed.hpp>
#include <boost/range/irange.hpp>
#include <boost/bind.hpp>


gnuplot::gnuplot()
{

}

void gnuplot::plot2d(double* points, double begin, double end)
{
    Gnuplot gp;
    std::vector<std::pair<double, double> > xy_pts;
    for(double x=-begin; x<end; x+=0.01) {
        double y = x*x*x;
        xy_pts.push_back(std::make_pair(x, y));
    }

    gp << "set xrange [" << begin << ":" << end << "]\nset yrange [-2:2]\n";
    gp << "plot '-' with points title 'cubic'\n";
    gp.send1d(xy_pts);

}

