/* AMPL model for the Kepler conjecture
File created May 8, 2009
Revised June 20, 2009
Thomas C. Hales

The model starts with a tame hypermap, then breaks certain quadrilaterals into two flats, certain pentagons into a flat+big4face or into 2 flats+apiece, certain hexagons into flat+big5face.  The new internal edges have length 2.52--sqrt8.


The sets ITRIANGLE, IQUAD, IPENT, IHEX index the remaining standard regions.  The other faces are subregions obtained by subdividing a standard region as just described.  If a standard region is known to contain no flat quarters, then it belongs to SUPER8.

****************

The branching has have following types.
* 2-way split on a triangular standard region according to y4+y5+y6 <= 6.25.
* 2-way  split on a node according to yn <= 2.18
* 3-way split on a standard quad, according to SUPER8, flats one way, flats the other way.
* 11-way split on std. pent, SUPER8, 5 (flat+big4face), 5 (flat+flat+Apiece).
* 6-way split on std. hex, SUPER8, 6 (flat+big5face).
Note that a big5face may have other flats within it, that are not used in branching.  This is done to keep the branching on hexagons to a minimum.

****************

Sets provided in the data file :
hypermapID: a numerical identifier of the case.
CVERTEX: the number of vertices. 
CFACE: the number of faces.  Standard regions that have been subdivided are not counted.
EDART: quadruples (i1,i2,i3,j) where (i1,j) is a dart such that f(i1,j) = (i2,j), f(i2,j)=(i3,j).
ITRIANGLE, IQUAD, IPENT, IHEX: remaining standard faces with 3,4,5,6 darts.
SUPER8: quads, pents, and hexes that are known not to have any flat quarters.
FLAT: the apex darts of flat quarters.
APIECE: the apex darts of flat quarters.
BIG5APEX: apex dart of complement of flat in hex
BIG4APEX: apex dart in complement of flat in pent, where the apex dart is defined as
  the dart x s.t. f x and f^2 x are the two darts along the long edge.
BIGTRI: standard triangles with y4+y5+y6>=6.25;
SMALLTRI: standard triangles with y4+y5+y6<=6.25;
HIGHVERTEX: vertex with yn >= 2.18;
LOWVERTEX: vertex with yn <= 2.18;

*/

param hypermapID;
param pi := 3.1415926535897932;
param delta0 := 0.5512855984325308;
param tgt := 1.54065864570856;
param sqrt8 := 2.8284271247461900;

param CVERTEX 'number of vertices' >= 13, <= 14; 
param CFACE 'number of faces' >= 0; 


# directed edge (i,j) identified with tail of arrow.
set IVERTEX := 0..(CVERTEX-1);
set FACE := 0..(CFACE-1);
set EDART 'extended dart' within IVERTEX cross IVERTEX cross IVERTEX cross FACE;
set DART := setof {(i1,i2,i3,j) in EDART} (i1,j);
set DEDGE := DART;
set EDGE within DART cross DART := setof{(i1,i2,i3,j1) in EDART,(i0,i3,i2,j2) in EDART}(i2,j1,i3,j2);

set ITRIANGLE; 
set IQUAD;  
set IPENT; 
set IHEX; 
set STANDARDR := ITRIANGLE union IQUAD union IPENT union IHEX; # standard regions.
set DART3:= {(i,j) in DART: j in ITRIANGLE};

# branch sets
set SUPER8 within IQUAD union IPENT union IHEX;
set SUBREGION := FACE diff STANDARDR;
set FLAT within {(i,j) in DART : j in SUBREGION};
set APIECE within {(i,j) in DART : j in SUBREGION};

# APEX3 does not include all darts of FLAT and APIECE, only the distinguished one.
set APEX3 := FLAT union APIECE union {(i,j) in DART: j in ITRIANGLE};
set BIG5APEX within {(i,j) in DART : j in SUBREGION};  
set BIG5FACE := setof{(i,j) in BIG5APEX}(j);
set BIG4APEX within {(i,j) in DART: j in SUBREGION};  
set BIG4FACE := setof{(i,j) in BIG4APEX}(j);
set BIGTRI within ITRIANGLE;
set SMALLTRI within ITRIANGLE;
set HIGHVERTEX within IVERTEX;
set LOWVERTEX within IVERTEX;

# darts originally on a standard region with more than 4 sides.
set DARTX := BIG4APEX union
   setof{(i1,i2,i3,j) in EDART: (i2,j) in BIG4APEX}(i1,j) union
   BIG5APEX union
   setof{(i1,i2,i3,j) in EDART: (i2,j) in BIG5APEX}(i1,j) union
   setof{(i1,i2,i3,j) in EDART: (i2,j) in BIG5APEX}(i3,j) union
   {(i,j) in DART: j in IQUAD union IPENT union IHEX};


# basic variables
var azim{DART} >= 0, <= pi;
var ln{IVERTEX} >= 0, <= 1;
var rhazim{DART} >=0, <= pi + delta0;
var yn{IVERTEX} >= 2, <= 2.52;
var ye{DEDGE} >= 2, <= 2.52;
var rho{IVERTEX} >= 1, <= 1 + delta0/pi;
var sol{FACE} >= 0, <= 4.0*pi;
var tau{FACE} >= 0, <= tgt;
var y1{DART} >= 0, <=2.52;
var y2{DART} >=0, <=2.52;
var y3{DART} >=0, <=2.52;
var y4{APEX3} >=0, <=sqrt8;
var y5{DEDGE} >=0, <=sqrt8;
var y6{DEDGE} >=0, <=sqrt8;


#report variables
var lnsum;
var ynsum;


## objective
maximize objective:  lnsum;

## equality constraints
lnsum_def: sum{i in IVERTEX} ln[i]  = lnsum;
ynsum_def: sum{i in IVERTEX} yn[i] = ynsum;
azim_sum{i in IVERTEX}:  sum {(i,j) in DART} azim[i,j] = 2.0*pi;
rhazim_sum{i in IVERTEX}:  sum {(i,j) in DART} rhazim[i,j] = 2.0*pi*rho[i];
sol_sum{j in FACE}: sum{(i,j) in DART} (azim[i,j] - pi) = sol[j] - 2.0*pi;
tau_sum{j in FACE}: sum{(i,j) in DART} (rhazim[i,j] - pi -delta0) = tau[j] - 2.0*(pi+delta0);
ln_def{i in IVERTEX}: ln[i] = (2.52 - yn[i])/0.52;
rho_def{i in IVERTEX}: rho[i] = (1 + delta0/pi) - ln[i] * delta0/pi;
edge{(i1,j1,i2,j2) in EDGE}: ye[i1,j1] = ye[i2,j2];
y1_def{(i3,i1,i2,j) in EDART}: y1[i1,j] = yn[i1];
y2_def{(i3,i1,i2,j) in EDART}: y2[i1,j] = yn[i2];
y3_def{(i3,i1,i2,j) in EDART}: y3[i1,j] = yn[i3];
y4_def{(i3,i1,i2,j) in EDART :  (i1,j) in APEX3}: y4[i1,j] = ye[i2,j];
y5_def{(i3,i1,i2,j) in EDART}: y5[i1,j] = ye[i3,j];
y6_def{(i3,i1,i2,j) in EDART}: y6[i1,j] = ye[i1,j];

## inequality constraints
main: sum{i in IVERTEX} ln[i] >= 12;
azmin{(i,j) in DART : j in ITRIANGLE}: azim[i,j] >= 0.852;
azmax{(i,j) in DART : j in ITRIANGLE}: azim[i,j] <= 1.893;
RHA{(i,j) in DART}: azim[i,j] <= rhazim[i,j];
RHB{(i,j) in DART}: rhazim[i,j] <= azim[i,j]*(1+delta0/pi);

# The corresponding bounds on APIECE, BIGAPEX4, BIGAPEX5 are redundant:
y4_bound{(i,j) in DART3}: y4[i,j] <= 2.52;
y5_bound{(i,j) in DART3}: y5[i,j] <= 2.52;
y6_bound{(i,j) in DART3}: y6[i,j] <= 2.52;
y4_boundF{(i,j) in FLAT}: y4[i,j] >= 2.52;
y5_boundF{(i,j) in FLAT}: y5[i,j] <= 2.52;
y6_boundF{(i,j) in FLAT}: y6[i,j] <= 2.52;


solyA{(i,j) in DART3}: sol[j] - 0.55125 - 0.196*(y4[i,j]+y5[i,j]+y6[i,j]-6) + 0.38*(y1[i,j]+y2[i,j]+y3[i,j]-6) >= 0;
solyB{(i,j) in DART3}: -sol[j] + 0.5513 + 0.3232*(y4[i,j]+y5[i,j]+y6[i,j]-6) - 0.151*(y1[i,j]+y2[i,j]+y3[i,j]-6) >= 0;

azminA{(i,j) in DART3}: azim[i,j] - 1.2308 
  + 0.3639*(y2[i,j]+y3[i,j]+y5[i,j]+y6[i,j]-8) - 0.235*(y1[i,j]-2) - 0.685*(y4[i,j]-2) >= 0;
azmaxA{(i,j) in DART3}: -azim[i,j] + 1.231 
  - 0.152*(y2[i,j]+y3[i,j]+y5[i,j]+y6[i,j]-8) + 0.5*(y1[i,j]-2) + 0.773*(y4[i,j]-2) >= 0;
azminX{(i,j) in DARTX}: azim[i,j] - 1.629 
  + 0.402*(y2[i,j]+y3[i,j]+y5[i,j]+y6[i,j]-8) - 0.315*(y1[i,j]-2)  >= 0;

rhazminA{(i,j) in DART3}: rhazim[i,j] - 1.2308 
  + 0.3639*(y2[i,j]+y3[i,j]+y5[i,j]+y6[i,j]-8) - 0.6*(y1[i,j]-2) - 0.685*(y4[i,j]-2) >= 0;

# tau inequality
tau3{j in ITRIANGLE}: tau[j] >= 0;
tau4{j in IQUAD}: tau[j] >= 0.206;
tau5{j in IPENT}: tau[j] >= 0.483;
tau6{j in IHEX}: tau[j] >= 0.76;

tau_azim3A{(i,j) in DART : j in ITRIANGLE}: tau[j]+0.626*azim[i,j] - 0.77 >= 0;
tau_azim3B{(i,j) in DART : j in ITRIANGLE}: tau[j]-0.259*azim[i,j] + 0.32 >= 0;
tau_azim3C{(i,j) in DART : j in ITRIANGLE}: tau[j]-0.507*azim[i,j] + 0.724 >= 0;
tau_azim3D{(i,j) in DART3}: tau[j] + 0.001 -0.18*(y1[i,j]+y2[i,j]+y3[i,j]-6) - 0.125*(y4[i,j]+y5[i,j]+y6[i,j]-6) >= 0;

tau_azim4A{(i,j) in DART : j in IQUAD}: tau[j] + 4.72*azim[i,j] - 6.248 >= 0;
tau_azim4B{(i,j) in DART : j in IQUAD}: tau[j] + 0.972*azim[i,j] - 1.707 >= 0;
tau_azim4C{(i,j) in DART : j in IQUAD}: tau[j] + 0.7573*azim[i,j] - 1.4333 >= 0;
tau_azim4D{(i,j) in DART : j in IQUAD}: tau[j] + 0.453*azim[i,j] + 0.777 >= 0;

#branch SUPER8 inequality
tau4B{j in IQUAD inter SUPER8}: tau[j] >= 0.256;
tau5h{j in IPENT inter SUPER8}: tau[j] >= 0.751;
tau6h{j in IHEX inter SUPER8}: tau[j] >= 0.91;

#XX add super8-dih.

#branch FLAT inequality

#branch APIECE inequality

#branch BIGPIECE inequality

#branch BIGTRI inequality
ybig{(i,j) in DART3 : j in SMALLTRI}: 
  y4[i,j]+y5[i,j]+y6[i,j] >= 6.25;

#branch SMALLTRI inequality
ysmall{(i,j) in DART3 : j in SMALLTRI}: 
  y4[i,j]+y5[i,j]+y6[i,j] <= 6.25;

#branch HIGHVERTEX inequality
yhigh{i in HIGHVERTEX}: yn[i] >= 2.18;

#branch LOWVERTEX inequality
ylow{i in LOWVERTEX}: yn[i] <= 2.18;

solve;
display hypermapID;
display lnsum;
