// Tabbed Divider for Filofax-style Notebooks
// Based on specifications from Tabbed_Divider.md

// --- Parameters ---

// Width of the main divider in mm
divider_width = 78; // [50:1:200]
// Height of the main divider in mm
divider_height = 108; // [80:1:300]
// Thickness of the divider material in mm
divider_depth = 0.4; // [0.2:0.2:2.0]
// Radius for the main body corners in mm
divider_radius = 2.5; // [0:0.1:10]

// Number of holes for binder rings
hole_count = 5; // [1:1:10]
// Diameter of the holes in mm
hole_diameter = 4; // [2:0.1:10]
// Spacing between hole centers in mm
hole_spacing = 19; // [5:0.1:30]
// Distance from the left edge to the hole centers in mm
hole_edge_distance = 7.5; // [2:0.1:20]

// Type of tab to generate (off, right, or top)
tab_type = "off"; // ["off", "right", "top"]
// Length of the tab along the divider's height or width in mm
tab_length = 50; // [10:1:100]
// How far the tab protrudes from the divider edge in mm
tab_protrusion = 10; // [5:1:30]
// Offset from the top edge (for "right" tab) or left edge (for "top" tab) of the divider in mm
tab_offset = 5; // [0:1:100]
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
    if (tab_type != "off") {
        r = tab_outer_radius;

        // Ensure dimensions don't become negative if radius is too large
        // (w_inner and h_inner calculated differently for 'right' and 'top' tabs)
        
        if (tab_type == "right") {
            // Right tab logic
            w_inner = tab_protrusion - r;
            h_inner = tab_length - (2 * r);
            
            if (w_inner > 0 && h_inner > 0) {
                taper_offset_inner = w_inner / tan(tab_taper_angle);

                // Define the core tapered shape, offset by 'r' on the y-axis
                tab_points = [
                    [0, r],
                    [0, r + h_inner],
                    [w_inner, r + h_inner - taper_offset_inner],
                    [w_inner, r + taper_offset_inner]
                ];

                // Position the final tab shape relative to the main body
                translate([divider_width, divider_height - tab_length - tab_offset, 0]) {
                    linear_extrude(height = divider_depth) {
                        difference() {
                            minkowski($fn=64) {
                                polygon(tab_points);
                                circle(r = r);
                            }
                            cutter_width = r + 1; // Must be wider than the radius
                            cutter_height = tab_length + 2; // Must be taller than the final shape
                            translate([-cutter_width, -1]) {
                                square([cutter_width, cutter_height]);
                            }
                        }
                    }
                }
            }
        } else if (tab_type == "top") {
            // Top tab logic
            // w_inner will be along divider_width, h_inner along divider_height
            w_inner = tab_length - (2 * r); // tab_length is now along width
            h_inner = tab_protrusion - r; // tab_protrusion is now along height

            if (w_inner > 0 && h_inner > 0) {
                taper_offset_inner = h_inner / tan(tab_taper_angle); // Taper along y-axis now

                // Define the core tapered shape, offset by 'r' on the x-axis
                tab_points = [
                    [r, 0],
                    [r + w_inner, 0],
                    [r + w_inner - taper_offset_inner, h_inner],
                    [r + taper_offset_inner, h_inner]
                ];
                
                // Position the final tab shape relative to the main body
                translate([tab_offset, divider_height, 0]) {
                    linear_extrude(height = divider_depth) {
                        difference() {
                            minkowski($fn=64) {
                                polygon(tab_points);
                                circle(r = r);
                            }
                            cutter_width = tab_length + 2; // Must be taller than the final shape
                            cutter_height = r + 1; // Must be wider than the radius
                            translate([-1, -cutter_height]) {
                                square([cutter_width, cutter_height]);
                            }
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
