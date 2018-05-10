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
    mirror_x=true, mirror_y=false,
    printed_rods=false,
    exit_base=true, exit_cover=false,
    tnum1=[9, 12, 12], tnum2=[47, 47, 47],
    cp=[1.5, 1.5, 1.5], pa=[20, 20, 20],
    holed1=[2, 2, 2], holed2=[2, 2, 2],
    h1=[9, 5, 5], h2=[3, 3, 3],
    a=[-25, 15, -15], stage1_c1=[0,0],
    rot2=[0, 0, 0],
    h2_gap=1, bottom_gap=0, top_gap=1,
    base_points=[[-54, -20], [-54, 10], [54, 10], [54, -20]],
    cover_points=[[-54, -20], [-54, 10], [54, 10], [54, -20]],
    base_h=3, cover_h=3,
    columns=[
        [0, -15],
        [49.5, -15], [49.5, 5],
        [-49.5, -15], [-49.5, 5]],
    base_color=[0.8, 0.5, 0.9], cover_color=[0.5, 0.7, 0.9], gears_color=[1, 1, 0.4],
    print_error=0.1, $fn=100);
~~~

Все шестеренки отдельно (параметр index - номер нужной шестеренки)
~~~scad
for(i=[0:3]) {
    translate([i*30-40, 40, 0])
        gb_gear(tnum1=[9, 12, 12], tnum2=[47, 47, 47],
            cp=[1.5, 1.5, 1.5], pa=[20, 20, 20],
            holed1=[2, 2, 2], holed2=[2, 2, 2],
            h1=[9, 5, 5], h2=[3, 3, 3],
            rot2=[0, 0, 0],
            print_error=0.1, $fn=100,
            index=i);
}
~~~

