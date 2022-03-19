
include <MCAD/gears.scad>

function calc_tooth_width(number_of_teeth, diametral_pitch, pressure_angle=30) = (
  pitch_diametral2diameter(number_of_teeth, diametral_pitch) * cos(pressure_angle) * sin(180 / number_of_teeth)
);

function calc_wheel_base_radius(number_of_teeth, diametral_pitch, pressure_angle=30) = (
  0.5 * pitch_diametral2diameter(number_of_teeth, diametral_pitch) * cos(pressure_angle)
); 

module saw_tooth_profile(width, tooth_angle=30) {
  points = [
    [0, 0],
    [0, width],
    [width * tan(tooth_angle), width]
  ];
  polygon(points);
}

module test_saw_tooth_profile() {
  saw_tooth_profile(width=3, tooth_angle=30);
}

module sawtooth_gear(number_of_teeth=24, diametral_pitch=1, gear_height=1, pressure_angle=30, shaft_diameter=3, key_size=1.5, key_count=4) {
  pitch_diameter = pitch_diametral2diameter(number_of_teeth, diametral_pitch);
  base_diameter = pitch_diameter * cos(pressure_angle);
  // base_radius = base_diameter / 2;
  base_radius = calc_wheel_base_radius(number_of_teeth, diametral_pitch, pressure_angle);
  tooth_sector_angle = 360 / number_of_teeth;
  // tooth_width = base_diameter * sin(tooth_sector_angle / 2);
  tooth_width = calc_tooth_width(number_of_teeth, diametral_pitch, pressure_angle);
  difference() {
    cylinder(r=base_radius, h=gear_height);
    cylinder(r=shaft_diameter / 2, h = gear_height * 3, center=true);
  }
  for (placement_angle = [0:360/number_of_teeth:360]) {
    rotate([0, 0, placement_angle])
      translate([base_radius, 0, 0])
        rotate([0, 0, tooth_sector_angle / 2])
          linear_extrude(gear_height)
            saw_tooth_profile(width=tooth_width, tooth_angle=pressure_angle);
  }
}

//$fs = 0.01;
//$fa = 0.01;
//
//rotate([180])
//  sawtooth_gear(number_of_teeth=36, diametral_pitch=2, pressure_angle=30);
