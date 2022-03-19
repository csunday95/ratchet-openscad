
include <ratchet_wheel.scad>

function midpoint(P1, P2) = [(P1[0] + P2[0]) / 2, (P1[1] + P2[1]) / 2];
function distance(P1, P2) = sqrt((P1[0] - P2[0]) ^ 2 + (P1[1] - P2[1]) ^ 2);
function direction_vec(P1, P2) = [
  (P1[0] - P2[0]) / distance(P1, P2),
  (P1[1] - P2[1]) / distance(P1, P2)
];

function calc_pawl_tooth_height(tooth_width, pressure_angle) = tooth_width * tan(pressure_angle);
function calc_pawl_tooth_points(tooth_height, wheel_tooth_count, pressure_angle) = [
  [0, 0],
  [tooth_height, 0],
  [tooth_height, tooth_height * tan(90 - pressure_angle + 360 / wheel_tooth_count)]
];

module draw_point(P, radius = 0.1, height=10) {
  translate([P[0], P[1]])
    cylinder(r=radius, h=height);
}

module pawl_arm_profile(od, arm_length, tooth_width, tooth_height, pressure_angle=30, contour_angle=20) {
  main_radius = od / 2;
  tip_circle_radius = main_radius / 2;
  beta = 90 - contour_angle;
  contour_arc_chord_length = 2 * main_radius * sin(contour_angle / 2);
//  contour_inflection_point = [
//    -main_radius + contour_arc_chord_length * cos(beta),
//    contour_arc_chord_length * sin(beta)
//  ];
  contour_inflection_point = [
    -main_radius * cos(contour_angle),
    main_radius * sin(contour_angle)
  ];
  
  contour_top_point = [
    tip_circle_radius,
    arm_length// + tip_circle_radius
  ];
  contour_chord_len = distance(contour_inflection_point, contour_top_point);
  contour_radius = (1 / sin(contour_angle / 2)) * contour_chord_len / 2;
  chord_midpoint = midpoint(contour_inflection_point, contour_top_point);
  chord_dir = direction_vec(contour_top_point, contour_inflection_point);
  perp_chord_dir = [-chord_dir[1], chord_dir[0]];
  perp_distance = contour_radius * cos(contour_angle / 2);
  contour_center = [
    chord_midpoint[0] + perp_chord_dir[0] * perp_distance,
    chord_midpoint[1] + perp_chord_dir[1] * perp_distance
  ];
//  draw_point(contour_inflection_point);
//  draw_point(contour_top_point);
//  draw_point(contour_center);
   
  difference() {
    circle(r=main_radius);
  }
  difference() {
    union() {
      translate([contour_inflection_point[0], 0])
        square([main_radius + abs(contour_inflection_point[0]), arm_length]);
      translate([tip_circle_radius, arm_length, 0])
        circle(r=tip_circle_radius);
    }
    difference() {
      translate(contour_center)
        circle(r=contour_radius);
      translate([contour_top_point[0], contour_top_point[1] + contour_radius])
        square([contour_radius * 2, contour_radius], center = true);
    }
  }
  intersection() {
    translate(contour_center)
      circle(r=contour_radius);
    translate([tip_circle_radius, arm_length - tooth_width + tip_circle_radius])
      square([tip_circle_radius, tooth_width]);
  }
}

module test_pawl_arm_profile() {
  $fs = 0.1;
  $fa = 0.1;
  pawl_arm_profile(
    od=3,
    arm_length=8
  );
}

module pawl_tooth_profile(tooth_height, wheel_tooth_count, pressure_angle=30) {
  points = calc_pawl_tooth_points(tooth_height, wheel_tooth_count, pressure_angle);
  polygon(points);
}

module test_pawl_tooth_profile() {
  pawl_tooth_profile();
}

module pawl_profile(od, arm_length, wheel_tooth_count, wheel_diametral_pitch, pressure_angle=30, contour_angle=40) {
  wheel_tooth_width = calc_tooth_width(
    wheel_tooth_count,
    wheel_diametral_pitch,
    pressure_angle
  );
  tooth_height = calc_pawl_tooth_height(wheel_tooth_width, pressure_angle);
  pawl_tooth_width = tooth_height * tan(90 - pressure_angle + 360 / wheel_tooth_count);
  translate([-od / 4 + tooth_height, 0])
    pawl_arm_profile(
      od,
      arm_length,
      pawl_tooth_width,
      tooth_height,
      pressure_angle,
      contour_angle
    );
  translate([0, arm_length + od / 4])
    rotate([180, 0, 0])
      pawl_tooth_profile(tooth_height, wheel_tooth_count, pressure_angle);
}

module test_pawl_profile() {
  $fs = 0.1;
  $fa = 0.1;
  pawl_profile(
    od=3,
    arm_length=8,
    wheel_tooth_count=36,
    wheel_diametral_pitch=2
  );
}

module ratchet_pawl(primary_od, arm_length, thickness, wheel_tooth_count, wheel_diametral_pitch, pressure_angle=30, contour_angle=40) {
  linear_extrude(thickness)
    pawl_profile(
      od=primary_od,
      arm_length=arm_length,
      wheel_tooth_count=wheel_tooth_count,
      wheel_diametral_pitch=wheel_diametral_pitch,
      pressure_angle=pressure_angle,
      contour_angle=contour_angle
    );
}

//test_pawl_profile();
