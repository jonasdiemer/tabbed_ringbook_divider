## Tabbed Divider

This shall be a tabbed divider for filofax type notebooks.

### Main plate
Parameters:
- width, height, depth, default 80, 120, .4 mm
- radius of rounded corners, default: 2.5mm
- Number of holes and diameter, default 6, 4mm
- Edge distance of holes, default 7.5mm

Holes have 19mm distance and are placed on the left hand side.

The bottom left corner shall be on coordinate 0,0

### Tabs

There shall be an optional tab at the top oNoiasdasdr right hand side.
They are slightly angled inwards (i.e. outside edge is narrower than base).
It has rounded corners, and also the connection to the main plate is rounded.

Paramerters:
- position, default=side
- width and height, default 50 and 10 mm
- offset from top, default 5mm
- angle for outside taper, default 75 degrees
- radius of fillets connecting tab and corners, default 1mm

### Ruler

There is an optional ruler that can be added to the top or right edge of the divider.
The ruler is generated as a separate part, allowing it to be printed in a different color as an inlay.

To export for multi-color printing, use the `part_to_show` parameter in the OpenSCAD file. Set it to `"divider"` and export the STL, then set it to `"ruler"` and export another STL. In your slicer software (like BambuStudio or PrusaSlicer), you can then import both STLs as parts of a single object and assign different filaments to them.

Parameters:
- `part_to_show`: "all", "divider", "ruler". Selects which part of the model to render. Default: "all".
- enabled, default=false
- position (top or right), default=top
- offset from edge, default=5mm
- depth of inlay marks, default=0.2mm
- tick width, default=0.4mm
- major/minor tick length, default=10mm/5mm
- major/minor tick spacing, default=10mm/1mm
- show numbers, default=true
- number font size, default=5mm

### Technicalities

Parameters shall be documented according to OpenSCAD customizer style:
```scad
// variable description
variable name = defaultValue; // possible values
```
