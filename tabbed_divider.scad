// Tabbed Divider for Filofax-style Notebooks
// Based on specifications from Tabbed_Divider.md

// --- Part Selection ---
// Choose which part to display. For multi-color printing, export "divider" 
// and "ruler" individually and import them as parts of a single object
// in your slicer software.
part_to_show = "all"; // ["all", "divider", "ruler"]

// --- Parameters ---

// Width of the main divider in mm
divider_width = 78; // [15:1:200]
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

// Width of the channel from hole to edge in mm. 0 to disable.
hole_channel_width = 1; // [0:0.1:10]

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


// --- Ruler Parameters ---
// Position of the ruler ("off", "top", or "right" edge)
ruler_position = "off"; // ["off", "top", "right"]
// Distance from the edge to the ruler marks' baseline.
ruler_offset = 5; // [0:0.5:20]
// Depth of the ruler marks inlay in mm. For multi-color printing.
ruler_mark_depth = 0.2; // [0.1:0.1:1]
// Width of each tick mark in mm.
ruler_tick_width = 0.4; // [0.2:0.1:2]
// Length of major tick marks (e.g., every 10mm).
ruler_major_tick_length = 10; // [5:1:20]
// Length of minor tick marks (e.g., every 1mm).
ruler_minor_tick_length = 5; // [2:1:10]
// Spacing for major ticks (e.g., 10 for cm).
ruler_major_tick_spacing = 10; // [5:1:20]
// Spacing for minor ticks (e.g., 1 for mm).
ruler_minor_tick_spacing = 1; // [1:1:10]
// Display numbers on major ticks.
ruler_show_numbers = true; // [true, false]
// Font size for ruler numbers.
ruler_font_size = 5; // [4:1:12]
// Font for the numbers
ruler_font = "Liberation Sans"; //
// Offset of the numbers from the major ticks.
ruler_number_offset = 2; // [1:0.5:10]


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


// --- Ruler Components ---

// Generates the 2D geometry for the ruler marks.
module ruler_marks_2d() {
    if (ruler_position != "off") {
        if (ruler_position == "top") {
            // Ruler along the top edge
            // Note: May overlap with a "top" tab. Adjust ruler_offset or tab_offset.
            translate([0, divider_height - ruler_offset, 0]) {
                for (x = [0 : ruler_minor_tick_spacing : divider_width - ruler_tick_width]) {
                    is_major_tick = (x % ruler_major_tick_spacing == 0);
                    tick_len = is_major_tick ? ruler_major_tick_length : ruler_minor_tick_length;

                    // Draw tick mark
                    translate([x, -tick_len, 0]) {
                        square([ruler_tick_width, tick_len]);
                    }

                    // Draw number for major ticks
                    if (is_major_tick && ruler_show_numbers && x > 0) {
                        number_text = str(x / ruler_major_tick_spacing);
                        translate([x + ruler_tick_width / 2, -tick_len - ruler_number_offset, 0]) {
                            text(number_text, size = ruler_font_size, font = ruler_font, halign = "center", valign = "top");
                        }
                    }
                }
            }
        } else if (ruler_position == "right") {
            // Ruler along the right edge
            // Note: May overlap with a "right" tab. Adjust ruler_offset or tab_offset.
            translate([divider_width - ruler_offset, 0, 0]) {
                for (y = [0 : ruler_minor_tick_spacing : divider_height - ruler_tick_width]) {
                    is_major_tick = (y % ruler_major_tick_spacing == 0);
                    tick_len = is_major_tick ? ruler_major_tick_length : ruler_minor_tick_length;
                    
                    // Draw tick mark
                    translate([-tick_len, y, 0]) {
                        square([tick_len, ruler_tick_width]);
                    }

                    // Draw number for major ticks
                    if (is_major_tick && ruler_show_numbers && y > 0) {
                        number_text = str(y / ruler_major_tick_spacing);
                        translate([-tick_len - ruler_number_offset, y + ruler_tick_width / 2, 0]) {
                            text(number_text, size = ruler_font_size, font = ruler_font, halign = "right", valign = "center");
                        }
                    }
                }
            }
        }
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
        
        // The hole itself
        translate([hole_edge_distance, y_pos, -1]) {
            cylinder(h = hole_cylinder_height, d = hole_diameter, $fn=32);
        }

        // Optional channel from hole to the edge with rounded corners
        if (hole_channel_width > 0) {
            r = hole_channel_width / 2; // Rounding radius, as specified
            
            translate([0, y_pos - r, -1]) { // Position the channel cutter relative to the hole's y_pos
                linear_extrude(height = hole_cylinder_height) {
                    union() {
                        // The main rectangular part of the channel cutter
                        square([hole_edge_distance, hole_channel_width]);

                        // Bottom-left corner rounding cutter:
                        // This shape is an r x r square MINUS a quarter circle.
                        // When subtracted from the main body, it creates a convex quarter-circle fillet.
                        translate([0, -r]) { // Position at bottom-left of the current channel segment
                            difference() {
                                square([r, r]); // The r x r square part
                                // The quarter circle that is "added back" (subtracted from the square)
                                translate([r, 0]) circle(r = r, $fn=32);
                            }
                        }

                        // Top-left corner rounding cutter:
                        // Similar logic for the top corner.
                        translate([0, hole_channel_width ]) { // Position at top-left of the current channel segment
                            difference() {
                                square([r, r]); // The r x r square part
                                // The quarter circle that is "added back" (subtracted from the square)
                                translate([r, r]) circle(r = r, $fn=32);
                            }
                        }
                    }
                }
            }
        }
    }
}


// --- Final Assembly ---

// This module creates the main divider with holes and cutouts for the ruler.
module divider_main() {
    difference() {
        union() {
            body();
            tab();
        }
        holes();
        
        if (ruler_position != "off") {
            // Create cutouts for the ruler inlay
            translate([0, 0, divider_depth - ruler_mark_depth]) {
                linear_extrude(height = ruler_mark_depth + 0.1) { // Add a bit to ensure clean cut
                    ruler_marks_2d();
                }
            }
        }
    }
}

// This module creates only the ruler inlay part.
module ruler_inlay() {
    if (ruler_position != "off") {
        translate([0, 0, divider_depth - ruler_mark_depth]) {
            linear_extrude(height = ruler_mark_depth) {
                ruler_marks_2d();
            }
        }
    }
}

// Render the selected part(s). For multi-color printing, you must export
// "divider" and "ruler" as separate files (e.g. STL) and then import them as
// parts of a single object in your slicer software (like BambuStudio).
// The "all" view is for preview purposes only.
if (part_to_show == "divider") {
    divider_main();
} else if (part_to_show == "ruler") {
    ruler_inlay();
} else { // "all"
    color("black") {
        divider_main();
    }
    color("white") {
        ruler_inlay();
    }
}
