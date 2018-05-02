# gearbox
OpenSCAD gearbox generator

requires: pd-gears
https://github.com/sadr0b0t/pd-gears

Редуктор:
- 3 ступени
- количество зубцов:
-- ступень 1: 9-47  
-- ступень 2: 12-47  
-- ступень 3: 12-47  
- circular pitch для всех ступеней 1.5
- pressure angle для всех ступеней 20

Положение шестеренок задается относительными углами поворота a

~~~scad
use <gearbox/gearbox.scad>

gb_gearbox(base=true, cover=true, gears=true,
    mirror_x=true,
    tnum1=[9, 12, 12], tnum2=[47, 47, 47],
    cp=[1.5, 1.5, 1.5], pa=[20, 20, 20],
    holed1=[2, 2, 2],
    holed2=[2, 2, 2],
    h1=[9, 5, 5], h2=[3, 3, 3],
    a=[-25, 15, -15], stage1_c1=[0,0],
    h2_gap=1, bottom_gap=0, top_gap=1,
    base_dim=[108, 30], base_shift=[0, -5],
    columns=[
        [0, -15],
        [49.5, -15], [49.5, 5],
        [-49.5, -15], [-49.5, 5]],
    $fn=100);
~~~

