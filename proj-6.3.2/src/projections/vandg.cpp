#define PJ_LIB__
#include "proj.h"
#include "proj_internal.h"

PROJ_HEAD(vandg, "van der Grinten (I)") "\n\tMisc Sph";

# define TOL        1.e-10
# define THIRD      .33333333333333333333
# define C2_27      .07407407407407407407
# define PI4_3      4.18879020478639098458
# define PISQ       9.86960440108935861869
# define TPISQ      19.73920880217871723738
# define HPISQ      4.93480220054467930934


static PJ_XY vandg_s_forward (PJ_LP lp, PJ *P) {           /* Spheroidal, forward */
    PJ_XY xy = {0.0,0.0};
    double  al, al2, g, g2, p2;

    p2 = fabs(lp.phi / M_HALFPI);
    if ((p2 - TOL) > 1.) {
        proj_errno_set(P, PJD_ERR_TOLERANCE_CONDITION);
        return xy;
    }
    if (p2 > 1.)
        p2 = 1.;
    if (fabs(lp.phi) <= TOL) {
        xy.x = lp.lam;
        xy.y = 0.;
    } else if (fabs(lp.lam) <= TOL || fabs(p2 - 1.) < TOL) {
        xy.x = 0.;
        xy.y = M_PI * tan(.5 * asin(p2));
        if (lp.phi < 0.) xy.y = -xy.y;
    } else {
        al = .5 * fabs(M_PI / lp.lam - lp.lam / M_PI);
        al2 = al * al;
        g = sqrt(1. - p2 * p2);
        g = g / (p2 + g - 1.);
        g2 = g * g;
        p2 = g * (2. / p2 - 1.);
        p2 = p2 * p2;
        {
            // Force floating-point computations done on 80 bit on
            // i386 to go back to 64 bit. This is to avoid the test failures
            // of https://github.com/OSGeo/PROJ/issues/1906#issuecomment-583168348
            // The choice of p2 is completely arbitrary.
            volatile double p2_tmp = p2;
            p2 = p2_tmp;
        }
        xy.x = g - p2; g = p2 + al2;
        xy.x = M_PI * (al * xy.x + sqrt(al2 * xy.x * xy.x - g * (g2 - p2))) / g;
        if (lp.lam < 0.) xy.x = -xy.x;
        xy.y = fabs(xy.x / M_PI);
        xy.y = 1. - xy.y * (xy.y + 2. * al);
        if (xy.y < -TOL) {
            proj_errno_set(P, PJD_ERR_TOLERANCE_CONDITION);
            return xy;
        }
        if (xy.y < 0.)
            xy.y = 0.;
        else
            xy.y = sqrt(xy.y) * (lp.phi < 0. ? -M_PI : M_PI);
    }

    return xy;
}


static PJ_LP vandg_s_inverse (PJ_XY xy, PJ *P) {           /* Spheroidal, inverse */
    PJ_LP lp = {0.0,0.0};
    double t, c0, c1, c2, c3, al, r2, r, m, d, ay, x2, y2;

    x2 = xy.x * xy.x;
    if ((ay = fabs(xy.y)) < TOL) {
        lp.phi = 0.;
        t = x2 * x2 + TPISQ * (x2 + HPISQ);
        lp.lam = fabs(xy.x) <= TOL ? 0. :
           .5 * (x2 - PISQ + sqrt(t)) / xy.x;
        return (lp);
    }
    y2 = xy.y * xy.y;
    r = x2 + y2;    r2 = r * r;
    c1 = - M_PI * ay * (r + PISQ);
    c3 = r2 + M_TWOPI * (ay * r + M_PI * (y2 + M_PI * (ay + M_HALFPI)));
    c2 = c1 + PISQ * (r - 3. *  y2);
    c0 = M_PI * ay;
    c2 /= c3;
    al = c1 / c3 - THIRD * c2 * c2;
    m = 2. * sqrt(-THIRD * al);
    d = C2_27 * c2 * c2 * c2 + (c0 * c0 - THIRD * c2 * c1) / c3;
    const double al_mul_m = al * m;
    if( fabs(al_mul_m) < 1e-16 ) {
        proj_errno_set(P, PJD_ERR_TOLERANCE_CONDITION);
        return proj_coord_error().lp;
    }
    d = 3. * d /al_mul_m;
    t = fabs(d);
    if ((t - TOL) <= 1.) {
        d = t > 1. ? (d > 0. ? 0. : M_PI) : acos(d);
        lp.phi = M_PI * (m * cos(d * THIRD + PI4_3) - THIRD * c2);
        if (xy.y < 0.) lp.phi = -lp.phi;
        t = r2 + TPISQ * (x2 - y2 + HPISQ);
        lp.lam = fabs(xy.x) <= TOL ? 0. :
           .5 * (r - PISQ + (t <= 0. ? 0. : sqrt(t))) / xy.x;
    } else {
        proj_errno_set(P, PJD_ERR_TOLERANCE_CONDITION);
        return lp;
    }

    return lp;
}


PJ *PROJECTION(vandg) {
    P->es = 0.;
    P->inv = vandg_s_inverse;
    P->fwd = vandg_s_forward;

    return P;
}

