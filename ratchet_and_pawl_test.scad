include <ratchet_pawl.scad>
include <ratchet_wheel.scad>

$fs = 0.01;
$fa = 0.01;

wheel_tooth_count = 24;
wheel_diametral_pitch = 2;
wheel_height = 2;
pressure_angle = 30;

wheel_radius = calc_wheel_base_radius(
  wheel_tooth_count, wheel_diametral_pitch, pressure_angle
);
rotate([0, 0, -360 / wheel_tooth_count / 2])
translate([-wheel_radius, 0, wheel_height])
  rotate([180, 0, 0])
    sawtooth_gear(
      number_of_teeth=wheel_tooth_count,
      diametral_pitch=wheel_diametral_pitch,
      gear_height=wheel_height,
      pressure_angle=pressure_angle
    );

pawl_primary_od = 3;
pawl_arm_length = 8;
pawl_thickness = 2;

translate([0, -pawl_arm_length - pawl_primary_od / 4, 0])
  ratchet_pawl(
    primary_od=pawl_primary_od,
    arm_length=pawl_arm_length,
    thickness=pawl_thickness,
    wheel_tooth_count=wheel_tooth_count,
    wheel_diametral_pitch=wheel_diametral_pitch,
    pressure_angle=pressure_angle
  );
