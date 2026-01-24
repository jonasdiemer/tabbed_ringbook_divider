// Tabbed Divider for Filofax-style Notebooks
// Based on specifications from Tabbed_Divider.md

// --- Parameters ---

// Width of the main divider in mm
divider_width = 80; // [50:1:200]
// Height of the main divider in mm
divider_height = 120; // [80:1:300]
// Thickness of the divider material in mm
divider_depth = 0.4; // [0.1:0.1:2.0]
// Radius for the main body corners in mm
divider_radius = 2.5; // [0:0.1:10]

// Number of holes for binder rings
hole_count = 6; // [2:1:10]
// Diameter of the holes in mm
hole_diameter = 4; // [2:0.1:10]
// Spacing between hole centers in mm
hole_spacing = 19; // [5:0.1:30]
// Distance from the left edge to the hole centers in mm
hole_edge_distance = 7.5; // [2:0.1:20]

// Enable or disable the tab
tab_enabled = true; // [true, false]
// Length of the tab along the divider's height in mm
tab_length = 50; // [10:1:100]
// How far the tab protrudes from the divider edge in mm
tab_protrusion = 10; // [5:1:30]
// Offset from the top edge of the divider to the start of the tab in mm
tab_position_from_top = 5; // [0:1:100]
// Inward angle of the tab's tapered sides in degrees
tab_taper_angle = 75;      // [0:1:90]
// Radius for the tab's outer corners in mm
tab_outer_radius = 2.5;    // [0:0.1:10]


// --- Helper Modules ---

// Creates a 2D rectangle with rounded corners
module rounded_rectangle(size, r) {
    w = size[0];
    h = size[1];
    $fn=64;
    hull() {
        translate([r, r]) circle(r = r);
        translate([w - r, r]) circle(r = r);
        translate([r, h - r]) circle(r = r);
        translate([w - r, h - r]) circle(r = r);
    }
}


// --- Main Components ---

module body() {
    linear_extrude(height = divider_depth) {
        rounded_rectangle([divider_width, divider_height], divider_radius);
    }
}

module tab() {
    if (tab_enabled) {
        r = tab_outer_radius;

        // Compensate for minkowski expansion by defining a smaller inner polygon.
        // This ensures the final shape has the exact dimensions specified.
        w_inner = tab_protrusion - r;
        h_inner = tab_length - (2 * r);
        
        // Ensure dimensions don't become negative if radius is too large
        if (w_inner > 0 && h_inner > 0) {
            taper_offset_inner = w_inner / tan(tab_taper_angle);

            // Define the core tapered shape, offset by 'r' on the y-axis
            // so that after minkowski, the shape's bounding box starts at y=0.
            tab_points = [
                [0, r],
                [0, r + h_inner],
                [w_inner, r + h_inner - taper_offset_inner],
                [w_inner, r + taper_offset_inner]
            ];

            // Position the final tab shape relative to the main body
            translate([divider_width, divider_height - tab_length - tab_position_from_top, 0]) {
                linear_extrude(height = divider_depth) {
                    // To get sharp inside corners and rounded outside corners, we first
                    // round all corners of the polygon, then slice off the rounded edge
                    // at the base, restoring a sharp edge for a clean join.
                    difference() {
                        // 1. Create the smaller inner polygon and round ALL corners.
                        // This expands the shape to the desired final dimensions.
                        minkowski($fn=64) {
                            polygon(tab_points);
                            circle(r = r);
                        }
                        
                        // 2. Cut off the rounded left edge to create a sharp seam.
                        // A large rectangle positioned to the left of the y-axis achieves this.
                        cutter_width = r + 1; // Must be wider than the radius
                        cutter_height = tab_length + 2; // Must be taller than the final shape
                        translate([-cutter_width, -1]) {
                            square([cutter_width, cutter_height]);
                        }
                    }
                }
            }
        }
    }
}

// The punch holes for the binder rings
module holes() {
    // Center the group of holes vertically on the divider
    total_hole_span = (hole_count - 1) * hole_spacing;
    y_start = (divider_height - total_hole_span) / 2;
    
    hole_cylinder_height = divider_depth + 2; 

    for (i = [0:hole_count-1]) {
        y_pos = y_start + i * hole_spacing;
        translate([hole_edge_distance, y_pos, -1]) {
            cylinder(h = hole_cylinder_height, d = hole_diameter, $fn=32);
        }
    }
}


// --- Final Assembly ---

difference() {
    union() {
        body();
        tab();
    }
    holes();
}
