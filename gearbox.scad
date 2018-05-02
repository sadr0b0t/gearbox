
use <pd-gears/pd-gears.scad>

// Редуктор:
// - 3 ступени
// - количество зубцов:
//     ступень 1: 9-47
//     ступень 2: 12-47
//     ступень 3: 12-47
// - circular pitch для всех ступеней 1.5
// - pressure angle для всех ступеней 20
// 
// Положение шестеренок задается относительными углами поворота
// 
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



/**
 * Найти координаты центра второй шестеренки на ступени редуктора.
 * 
 * @param tnum1 количество зубцов на шестеренке 1
 * @param tnum2 количество зубцов на шестеренке 2
 * @param cp circular pitch
 *     (по умолчанию: 1.5)
 * @param a угол поворота центра шестеренки 2 вокруг центра шестеренки 1
 *     (по умолчанию: 0)
 * @param c1 координаты центра шестеренки 1
 *     (по умолчанию: [0,0])
 * 
 * @return координаты [x, y] центра шестеренки 2
 */
function gb_find_center2(tnum1, tnum2, cp=1.5, a=0, c1=[0,0]) =
    [c1.x +
        (pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum1)+
        pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum2))*cos(a),
    c1.y +
        (pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum1)+
        pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum2))*sin(a)];

/**
 * Найти координаты центра второй шестеренки на
 * указанной ступени редуктора.
 * 
 * @param stage_n индекс ступени редкутора (отсчет с 0)
 * @param tnum1 количество зубцов на шестеренке 1
 *     (массив значений для каждой ступени)
 * @param tnum2 количество зубцов на шестеренке 2
 *     (массив значений для каждой ступени)
 * @param cp circular pitch
 *     (массив значений для каждой ступени)
 * @param a угол поворота центра шестеренки 2 вокруг центра шестеренки 1
 *     (массив значений для каждой ступени)
 * @param stage1_c1 координаты центра шестеренки 1 на ступени 1
 *     (по умолчанию: [0,0])
 * 
 * @return координаты [x, y] центра шестеренки 2 на ступени stage_n
 */
function gb_find_stage_center2(stage_n, tnum1, tnum2, cp, a, stage1_c1=[0,0]) =
    stage_n == 0 ?
        gb_find_center2(tnum1=tnum1[0], tnum2=tnum2[0],
            cp=cp[0], a=a[0], stage1_c1=stage1_c1) :
        gb_find_center2(tnum1=tnum1[stage_n], tnum2= tnum2[stage_n],
            cp=cp[stage_n],
            a=a[stage_n],
            c1=gb_find_stage_center2(stage_n=stage_n-1,
                tnum1=tnum1, tnum2=tnum2,
                cp=cp, a=a, stage1_c1=stage1_c1));

/**
 * Координаты центров шестеренок на всех ступенях
 * редуктора.
 * Результат - список координат, начиная с 1й ступени:
 * [
 *     [[stage-1.c1.x, stage-1.c1.y], [stage-1.c2.x, stage-1.c2.y]],
 *     [[stage-2.c1.x, stage-2.c1.y], [stage-2.c2.x, stage-2.c2.y]], 
 *     ...
 *     [[stage-n.c1.x, stage-n.c1.y], [stage-n.c2.x, stage-n.c2.y]]
 * ]
 * здесь
 *     stage-n.c1 - центр 1й шестеренки на ступени n,
 *     stage-n.c2 - центр 2й шестеренки на ступени n.
 * 
 * @param stage_n - индекс верхней ступени, до которой вычисляем центры.
 *     (нумерация с 0: для 1й ступени stage_n=0, для n-й - stage_n=n-1)
 * @param tnum1 количество зубцов на шестеренке 1
 *     (массив значений для каждой ступени)
 * @param tnum2 количество зубцов на шестеренке 2
 *     (массив значений для каждой ступени)
 * @param cp circular pitch
 *     (массив значений для каждой ступени)
 * @param a угол поворота центра шестеренки 2 вокруг центра шестеренки 1
 *     (массив значений для каждой ступени)
 * @param stage1_c1 координаты центра шестеренки 1 на ступени 1
 *     (по умолчанию: [0,0])
 * 
 * @return координаты центров шестеренок на всех ступенях редуктора до 
 *     ступени stage_n включительно.
 */
function gb_find_stage_centers(stage_n, tnum1, tnum2, cp, a, stage1_c1=[0,0]) =
    stage_n == 0 ?
        [
            // центр1 на ступени 1
            [stage1_c1,
            // центр2 на ступени 2
            gb_find_center2(tnum1=tnum1[0], tnum2=tnum2[0],
                cp=cp[0], c1=stage1_c1, a=a[0])]
        ] :
        concat(
            // все центры на предыдущих ступенях
            gb_find_stage_centers(stage_n=stage_n-1,
                tnum1=tnum1, tnum2=tnum2,
                cp=cp, a=a, stage1_c1=stage1_c1),
            [
                // центр 1 на текущей ступени == центр 2 на предыдущей ступени
                [gb_find_center2(tnum1=tnum1[stage_n-1], tnum2= tnum2[stage_n-1],
                    cp=cp[stage_n-1], a=a[stage_n-1],
                    c1=gb_find_stage_centers1(stage_n=stage_n-1,
                        tnum1=tnum1, tnum2=tnum2,
                        cp=cp, a=a, stage1_c1=stage1_c1)[stage_n-1]),
                // центр 2 на текущей ступени
                gb_find_center2(tnum1=tnum1[stage_n], tnum2= tnum2[stage_n],
                    cp=cp[stage_n], a=a[stage_n],
                    c1=gb_find_stage_center2(stage_n=stage_n-1,
                        tnum1=tnum1, tnum2=tnum2,
                        cp=cp, a=a, stage1_c1=stage1_c1))]
            ]
        );

/**
 * Координаты центров шестеренки 1 на всех ступенях редуктора.
 * Результат - список координат, начиная с 1й ступени
 * [[stage-1.c1.x, stage-1.c1.y], [stage-2.c1.x, stage-2.c1.y], ..., [stage-n.c1.x, stage-n.c1.y]]
 * здесь stage-n.c1 - центр 1й шестеренки на ступени n.
 * 
 * @param stage_n - индекс верхней ступени, до которой вычисляем центры.
 *     (нумерация с 0: для 1й ступени stage_n=0, для n-й - stage_n=n-1)
 * @param tnum1 количество зубцов на шестеренке 1
 *     (массив значений для каждой ступени)
 * @param tnum2 количество зубцов на шестеренке 2
 *     (массив значений для каждой ступени)
 * @param cp circular pitch
 *     (массив значений для каждой ступени)
 * @param a угол поворота центра шестеренки 2 вокруг центра шестеренки 1
 *     (массив значений для каждой ступени)
 * @param stage1_c1 координаты центра шестеренки 1 на ступени 1
 *     (по умолчанию: [0,0])
 * 
 * @return координаты центров шестеренки 1 на всех ступенях редуктора
 *     до ступени stage_n включительно.
 */
function gb_find_stage_centers1(stage_n, tnum1, tnum2, cp, a, stage1_c1=[0,0]) =
    stage_n == 0 ?
        [stage1_c1] :
        concat(
            gb_find_stage_centers1(stage_n=stage_n-1,
                tnum1=tnum1, tnum2=tnum2,
                cp=cp, a=a, stage1_c1=stage1_c1),
            [gb_find_center2(tnum1=tnum1[stage_n-1], tnum2= tnum2[stage_n-1],
                cp=cp[stage_n-1], a=a[stage_n-1],
                c1=gb_find_stage_centers1(stage_n=stage_n-1,
                    tnum1=tnum1, tnum2=tnum2,
                    cp=cp, a=a, stage1_c1=stage1_c1)[stage_n-1])]
        );

/**
 * Координаты центров шестеренки 2 на всех ступенях редуктора.
 * Результат - список координат, начиная с 1й ступени
 * [[stage-1.c2.x, stage-1.c2.y], [stage-2.c2.x, stage-2.c2.y], ..., [stage-n.c2.x, stage-n.c2.y]]
 * здесь stage-n.c1 - центр 1й шестеренки на ступени n.
 * 
 * @param stage_n - индекс верхней ступени, до которой вычисляем центры.
 *     (нумерация с 0: для 1й ступени stage_n=0, для n-й - stage_n=n-1)
 * @param tnum1 количество зубцов на шестеренке 1
 *     (массив значений для каждой ступени)
 * @param tnum2 количество зубцов на шестеренке 2
 *     (массив значений для каждой ступени)
 * @param cp circular pitch
 *     (массив значений для каждой ступени)
 * @param a угол поворота центра шестеренки 2 вокруг центра шестеренки 1
 *     (массив значений для каждой ступени)
 * @param stage1_c1 координаты центра шестеренки 1 на ступени 1
 *     (по умолчанию: [0,0])
 *
 * @return координаты центров шестеренки 2 на всех ступенях редуктора
 *     до ступени stage_n включительно.
 */
function gb_find_stage_centers2(stage_n, tnum1, tnum2, cp, a, stage1_c1=[0,0]) =
    stage_n == 0 ?
        [gb_find_center2(tnum1=tnum1[0], tnum2=tnum2[0],
            cp=cp[0], c1=stage1_c1, a=a[0])] :
        concat(
            gb_find_stage_centers2(stage_n=stage_n-1,
                tnum1=tnum1, tnum2=tnum2,
                cp=cp, a=a, stage1_c1=stage1_c1),
            [gb_find_center2(tnum1=tnum1[stage_n], tnum2= tnum2[stage_n],
                cp=cp[stage_n], a=a[stage_n],
                c1=gb_find_stage_center2(stage_n=stage_n-1,
                    tnum1=tnum1, tnum2=tnum2,
                    cp=cp, a=a, stage1_c1=stage1_c1))]
        );


/**
 * Координата основания (по оси Z) указанной ступени редуктора.
 * Высота ступени берется как высота шестеренки 2 h2
 * плюс вертикальный отступ h2_gap.
 *
 * Основание 1й ступени (stage_n=0) - ноль.
 *
 * @param stage_n - индекс ступени, для которой вычисляем координату Z основания.
 *     (нумерация с 0: для 1й ступени stage_n=0, для n-й - stage_n=n-1)
 * @param h2 высота шестеренки 2
 *     (массив значений для каждой ступени)
 * @param h2_gap отступ по оси Z под шестеренкой 2 относительно шестеренки 1
 *     (по умолчанию: 0)
 * @return
 */
function gb_stage_bottom(stage_n, h2, h2_gap=0) =
    stage_n == 0 ? 0 :
        gb_stage_bottom(stage_n=stage_n-1, h2=h2, h2_gap=h2_gap) +
            h2[stage_n-1] + h2_gap;


/**
 * Нарисовать ступень редуктора:
 * 2 сцепленные шестеренки, центр шестеренки 2 повернут
 * вокруг центра шестеренки 1 на a градусов.
 * 
 * @param tnum1 количество зубцов на шестеренке 1
 * @param tnum2 количество зубцов на шестеренке 2
 * @param cp circular pitch (default=1.5)
 * @param pa pressure angle (default=20)
 * @param holed1 диаметр отверстия на шестеренке 1
 * @param holed2 диаметр отверстия на шестеренке 2
 * @param h1 высота шестеренки 1
 * @param h2 высота шестеренки 2
 * @param a угол поворота шестеренки 2 вокруг цента шестеренки 1
 * @param c1 координаты центра шестеренки 1
 * @param rot1 угол поворота шестеренки 1 вокруг центра
 *     (полезно для смещения зубцов)
 * @param h2_gap отступ по оси Z под шестеренкой 2 относительно шестеренки 1
 * @param $fn детализация отверстий внутри шестеренок
 */
module gb_stage(tnum1, tnum2,
        cp=1.5, pa=20,
        holed1=2, holed2=2, h1=3, h2=3,
        a=0, c1=[0,0], rot1=0, h2_gap=0,
        mirror_x=true,
        $fn=90) {
    module _stage() {
        rotate([0,0,rot1]) gear(mm_per_tooth=cp, pressure_angle=pa,
            number_of_teeth=tnum1, thickness=h1, hole_diameter=holed1,
            center=false, $fn=$fn);
        rotate([0, 0, a]) translate([
                pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum1)+
                pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum2),
                0, h2_gap])
            gear(mm_per_tooth=cp, pressure_angle=pa,
                number_of_teeth=tnum2, thickness=h2, hole_diameter=holed2,
                center=false, $fn=$fn);
        if(mirror_x && c1.x == 0) {
            // шестеренка 1 находится на оси X - отражаем только 
            // шестеренку 2
            rotate([0, 0, 180-a]) translate([
                    pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum1)+
                    pitch_radius(mm_per_tooth=cp, number_of_teeth=tnum2),
                    0, h2_gap])
                gear(mm_per_tooth=cp, pressure_angle=pa,
                    number_of_teeth=tnum2, thickness=h2, hole_diameter=holed2,
                    center=false, $fn=$fn);
        }
    }
    translate([c1.x, c1.y, 0]) _stage();
    if(mirror_x && c1.x != 0) {
        // шестеренка 1 не на оси X - отражаем обе
        mirror([1,0,0]) translate([c1.x, c1.y, 0]) _stage();
    }
}


/**
 * Многоступенчатый плоский редуктор.
 * 
 * @param tnum1 количество зубцов на шестеренке 1
 *     (массив значений для каждой ступени)
 * @param tnum2 количество зубцов на шестеренке 2
 *     (массив значений для каждой ступени)
 * @param cp circular pitch
 *     (массив значений для каждой ступени)
 * @param pa pressure angle
 *     (массив значений для каждой ступени)
 * @param holed1 диаметр отверстия на шестеренке 1
 *     (массив значений для каждой ступени)
 * @param holed2 диаметр отверстия на шестеренке 2
 *     (массив значений для каждой ступени)
 * @param h1 высота шестеренки 1
 *     (массив значений для каждой ступени)
 * @param h2 высота шестеренки 2
 *     (массив значений для каждой ступени)
 * @param a угол поворота центра шестеренки 2 вокруг центра шестеренки 1
 *     (массив значений для каждой ступени)
 * @param stage1_c1 координаты центра шестеренки 1 на ступени 1
 * @param h2_gap отступ по оси Z под шестеренкой 2 относительно шестеренки 1 (по умолчанию: 1)
 * @param bottom_gap отступ снизу от основания ректора
 *      (по умолчанию: 0)
 * @param top_gap отступ сверху от крышки ректора
 *      (по умолчанию: 1)
 * @param base_dim размер основания: [dim_x, dim_y]
 * @param base_shift смещение основания: [shift_x, shift_y]
 * @param columns стойки с отверстиями под винты
 *     (3мм отверстие+2мм стенка). Массив: каждый элемент
 *     массива - пара [x,y] - координаты центра каждой стойки.
 * @param mirror_x отразить все шестеренки, кроме начальной, по оси X
 * @param base рисовать основание (true/false)
 * @param cover рисовать крушку (true/false)
 * @param gears  рисовать шестеренки (true/false)
 * @param print_error компенсация погрешности 3д-печати для стыкующихся
 *     элементов
 * @param $fn детализация цилиндрических стоек и отверстий
 */
module gb_gearbox(tnum1, tnum2, cp, pa,
        holed1, holed2, h1, h2,
        a, stage1_c1=[0,0],
        h2_gap=1, bottom_gap=0, top_gap=1,
        base_dim=[40, 40], base_shift=[0,0],
        columns=[],
        mirror_x=true,
        base=true, cover=true, gears=true,
        print_error=0.1, $fn=100) {
    
    // центры шестеренки 1 на всех ступенях
    c1 = gb_find_stage_centers1(stage_n=len(tnum1),
                tnum1=tnum1, tnum2=tnum2,
                cp=cp, a=a, stage1_c1=stage1_c1);
    // центры шестеренки 2 на всех ступенях
    c2 = gb_find_stage_centers2(stage_n=2,
                tnum1=tnum1, tnum2=tnum2,
                cp=cp, a=a, stage1_c1=stage1_c1);
            
    // высота блока с шестеренками - без зазоров сверху и снизу,
    // для последней ступеньки берем высоту более высокой шестеренки
    stages_h = gb_stage_bottom(stage_n=len(tnum1)-1, h2=h2, h2_gap=h2_gap) +
        (h1[len(tnum1)-1] > h2[len(tnum1)-1]+h2_gap ?
            h1[len(tnum1)-1] : h2[len(tnum1)-1]+h2_gap);
            
    // подставки под шестеренки - под каждой 2й шестеренкой
    // на ступеньке: цилиндр радиусом=радиус отверстия шестеренки+2мм
    module _gear_stands() {
        for(i = [0 : len(tnum1)-1]) {
            difference() {
                translate([c2[i].x, c2[i].y, 0])
                    cylinder(
                        r=holed2[i]/2+2,
                        h=gb_stage_bottom(
                            stage_n=i, h2=h2, h2_gap=h2_gap)+h2_gap+bottom_gap, $fn=$fn);
                
                // отверстие внутри подставки под ось шестеренки: высота подставки + 2мм
                // (дополнительное вычитание выше из самого дна)
                translate([c2[i].x, c2[i].y, -0.1])
                    cylinder(
                        r=holed2[i]/2,
                        h=gb_stage_bottom(
                            stage_n=i, h2=h2, h2_gap=h2_gap)+h2_gap+bottom_gap+0.2, $fn=$fn);
                
                // вычитаем внешний диаметр шестеренки 2 с предыдущей ступени
                if(i >0) translate([c2[i-1].x, c2[i-1].y, -0.1])
                    cylinder(
                        r=outer_radius(mm_per_tooth=cp[i-1], number_of_teeth=tnum2[i-1], clearance=0)+0.2,
                        h=gb_stage_bottom(
                            stage_n=i, h2=h2, h2_gap=h2_gap)+h2_gap+bottom_gap+0.2, $fn=$fn);
            }
        }
    }
    
    // отверстия в основании (колонны не учитываем)
    module _base_holes1() {
        // несквозные отверстия в основании под оси шестеренок:
        // высота подставки + 2мм
        for(i = [0 : len(tnum1)-1]) {
            translate([c2[i].x, c2[i].y, -2])
                cylinder(r=holed2[i]/2, h=2.1, $fn=$fn);
        }
    }
    
    // отверстия в крышке (колонны не учитываем)
    module _cover_holes1() {
        // несквозные отверстия в крышке под оси шестеренок 
        for(i = [0 : len(tnum1)-1]) {
                translate([c2[i].x, c2[i].y, stages_h+bottom_gap+top_gap-0.1])
                    cylinder(r=holed2[i]/2,
                        h=(i<len(tnum1)-1? 2:3.1)+0.1, $fn=$fn);
        }
    }

    // основание
    color([.1, .2, .3]) if(base) {
        // дно
        difference() {
            translate([base_shift.x, base_shift.y, -1.5])
                cube([base_dim.x, base_dim.y, 3], center=true);
            
            // отверстия под подставками под шестеренки
            _base_holes1();
            if(mirror_x) mirror([1,0,0]) _base_holes1();
            
            // отверстия под "колоннами"
            for(col = columns) {
                translate([col.x, col.y,-3-0.1]) cylinder(r=1.5, h=3+0.2);
            }
        }
        
        // подставки под шестеренки
        _gear_stands();
        if(mirror_x) mirror([1,0,0]) _gear_stands();
        
        // "колонны": высота внутри редуктора + 2мм
        // внутри отверстие 3мм
        difference() {
            for(col = columns) {
                translate([col.x, col.y, 0]) difference() {
                    cylinder(r=3.5-print_error, h=stages_h+bottom_gap+top_gap+2);
                    translate([0,0,-0.1])
                        cylinder(r=1.5, h=stages_h+bottom_gap+top_gap+2+0.2);
                }
            }
            
            // вычитаем из колонн цилиндры диаметром с шестеренки
            // по центрам шестеренок по всей высоте
            for(i = [0 : len(tnum1)-1]) {
                translate([c1[i].x, c1[i].y, -0.1]) cylinder(
                    r=outer_radius(
                        mm_per_tooth=cp[i], number_of_teeth=tnum1[i], clearance=0)+0.2,
                    h=stages_h+bottom_gap+top_gap+2+0.2,
                    $fn=$fn);
                translate([c2[i].x, c2[i].y, -0.1]) cylinder(
                    r=outer_radius(
                        mm_per_tooth=cp[i], number_of_teeth=tnum2[i], clearance=0)+0.2,
                    h=stages_h+bottom_gap+top_gap+2+0.2,
                    $fn=$fn);
            }
        }
    }
    
    // крышка
    color([.3, .2, .1]) if(cover) {
        // крышка
        difference() {
            translate([base_shift.x, base_shift.y, stages_h+bottom_gap+top_gap+1.5])
                cube([base_dim.x, base_dim.y, 3], center=true);
            
            // отверстия для шестеренок
            _cover_holes1();
            if(mirror_x) mirror([1,0,0]) _cover_holes1();
            
            // выемки для "колонн"
            for(col = columns) {
                translate([col.x, col.y, stages_h+bottom_gap+top_gap-0.1]) difference() {
                    cylinder(r=3.5+print_error, h=2+0.1);
                }
            }
            
            // сквозные отверстия под "колоннами"
            for(col = columns) {
                translate([col.x, col.y, stages_h+bottom_gap+top_gap-0.1])
                    cylinder(r=1.5, h=3+0.2);
            }
        }
    }
    
    // шестеренки
    if(gears) {
        for(i = [0 : len(tnum1)-1]) {
            translate([0,0, gb_stage_bottom(stage_n=i, h2=h2, h2_gap=h2_gap)+bottom_gap])
                gb_stage(tnum1=tnum1[i], tnum2=tnum2[i],
                    cp=cp[i], pa=pa[i],
                    holed1=holed1[i], holed2=holed2[i], h1=h1[i], h2=h2[i],
                    a=a[i],
                    c1=c1[i],
                    h2_gap=h2_gap,
                    mirror_x=mirror_x,
                    $fn=$fn);
        }
    }
}