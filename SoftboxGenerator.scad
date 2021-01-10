
//////////////////////////////////////////////
//                VARIABLES                 //
//////////////////////////////////////////////

// nozzle diameter in millimeters.
nozzle_dia = 0.4;

// width of the extruded line for perimeters in millimeters.
perimeter_extrusion_width = 0.45;

// width of the extruded line for infill in millimeters.
infill_extrusion_width = 0.45;

// infill percentage 0 => 0%, 0.4 => 40%, 1 => 100%
infill_percentage = 0.4;

// layer height in millimeters.
layer_height = 0.2;

// number of top layers.
top_layers = 3;

// number of bottom layers. 
bottom_layers = 3;

// number of shell perimeters.
shell_perimeters = 2;

//
//   ___________ <= 'width'
//  |           |    
//  |           |
//  |           |
//  |           |
//  |           |
//  |___________|
//
//  /\
//  ||
//  'height'

// Softbox height in millimeters
height = 100;
// Softbox width in millimeters
width = 100;

//
//   __________________  <= 'width'
//  |                  |
//  |__________________|
//
//  /\
//  ||
// 
//  'thickness'

// Softbox thickness in centimeters
thickness = 1.6; // multiplication of 'layer_height'. Because We do not want to lose layers.


////////////////////////////////////////////
//                PROGRAM                 //
////////////////////////////////////////////



top_layer_thickness = layer_height * top_layers;
bottom_layer_thickness = layer_height * bottom_layers;

if(top_layer_thickness + bottom_layer_thickness > thickness)
{
    echo("'top layers' and 'bottom layers' are too thick to fit in specified 'thickness'. Please consider making 'thickness' bigger.");
}

shell_thickness = shell_perimeters * perimeter_extrusion_width;

middleLayer_thickness = thickness - top_layer_thickness + bottom_layer_thickness;

// Bottom layer
module Draw_Bottom_Layer()
{
    cube([width,height,bottom_layer_thickness]);
}

// Middle layer
module Draw_Middle_Layer()
{
    translate([0,0,bottom_layer_thickness])
    {
        // Make shell
        
        difference()
        {  
            cube([width, height, middleLayer_thickness]);
            
            newWidth = width-(shell_thickness*2);
            newHeight = height - (shell_thickness*2);

            translate([shell_thickness, shell_thickness, 0])
            {
                resize(newsize=[newWidth, newHeight, middleLayer_thickness])
                {
                    cube([width, height, middleLayer_thickness]);
                }
            }
        
        }
        
        // Middle layer infill
        middle_layers = middleLayer_thickness / layer_height;
        infill_lines = height * infill_percentage;
        
        
        // Different layer switch between height and width
        for (layer = [0:middle_layers])
        {
            translate([0,0,layer*layer_height])
            {
                side = layer % 1 == 0 ? height : width;
                infill_start = rands(shell_thickness, side, infill_lines);
                
                for (infill_line = [0:infill_lines])
                {
                    //translationX = layer % 1 == 0 ? infill_start[infill_line] : 0;
                    //translationY = layer % 1 == 1 ? infill_start[infill_line] : 0;
                    translate([0,4,0])
                    {
                        rotate(90-infill_start[infill_line])
                        {
                            cube([height*2, infill_extrusion_width, layer_height]);
                        }
                    }
                }
            }
        }
        
    }  
}

module Draw_Top_Layer()
{
    translate([0,0,bottom_layer_thickness + middleLayer_thickness])
    {
        cube([width,height,top_layer_thickness]);
    }
}



//Draw_Bottom_Layer();
Draw_Middle_Layer();
//Draw_Top_Layer();