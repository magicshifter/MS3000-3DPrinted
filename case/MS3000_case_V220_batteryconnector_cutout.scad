doBatteryPart = true;
doLedPart = true;
doLedCutout = true;
doVersionNr = false;


rotZ = 90;

dxfFileName = "MS3000_case_V220.dxf";
topH=1.2;


glassH = 0.6;
bottomH=2;

logoH = 0.5;



buttonPos = [ 40, 50, 60];
buttonR = 5;
buttonH = 6;

cutoutH = bottomH - glassH; // 1.6;
pcbClearance = 0.45;
pcbH=1.6;
buttonH = 4;

usbH = 0;

ledPartH = 6.9;
batteryPartH= 3.7;
snapInH = 1;
snapInW = 0.8;
delta = 0.40;
//holeH=2;

pillarR=1+1.92;

$fn = 24;
//$fn=8;

infSize = 400;


// -0.1 so we dont press onto the board too much
pillarH= ledPartH + batteryPartH - (bottomH + pcbH - snapInH) - 0.1;
wallOffset = pcbClearance+2*snapInW+delta;

pcbHeight = 24.2;

cylYOffset = pcbHeight/2;
cylPositions = [
  [18.0825, 22.6 - cylYOffset],
 [16.8275, 1.6 - cylYOffset],
 [97.8, 22.6 - cylYOffset],
 [97.8, 1.6 - cylYOffset],
];

cCS = 10;
cOO = 1;
cDD = 1.7;
cylCutawayParams = [
 [[1, [0, 0, 0], [0, -(cCS/2+cOO), cCS/2-cDD]]
 //, [1, [0, 0, 0], [6, 3-(cCS/2+cOO), cCS/2-cDD-6]]
 ],
 [[1, [0, 0, 0],  [0, cCS/2+cOO, cCS/2-cDD]]],
 [[0]],
 [[1, [0, 0, 0], , [0, cCS/2+cOO, cCS/2-cDD]]],
];
smallButtonPositions = [
    [32.7025, 21.14],
    [3.06, 5.08],
];

bbY = 17.3;
bbZ = 6.3;
bbR = 6.0;    
bbRX = 8;
buttonPositions = [
    [39.65, bbY, bbZ],
    [49.65, bbY, bbZ],
    [59.65, bbY, bbZ],
];


rotate([0,0,rotZ]) {
    if (doBatteryPart) 
        translate([0,0, topH]) 
            mirror([0, -1, 0])
                BatteryPart();
    
    if (doLedPart)
        translate([0, doBatteryPart ? 30 : 0, 0])
            LedPart();
}

expl= 0.1;

*intersection() {
rotate([0,0,0]) {
    translate([0,0, bottomH+expl]) 
        linear_extrude(convexity = 10, height = pcbH-expl, center = false)
            import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);

    
    if (doBatteryPart) 
        translate([0,0, ledPartH + batteryPartH + snapInH + expl]) 
            rotate([180,0,0])
            mirror([0, -1, 0])
                BatteryPart();
    
    if (doLedPart)
        translate([0, 0, 0])
            LedPart();
}
cubeEx([35.5, 100, 100]);
}

module BatteryPart() {
difference() {
union() {
    #intersection() {
     translate([0,0,0]) {
                for (pos = cylPositions) {
			translate([pos[0], pos[1], -1]) {
                cylinder(r=pillarR, h=pillarH+1, center=false);
				cylinder(r1= 8, r2= 0, h = 8, center=false);
			}
		}
      }
      union() {
        translate([0,0,4]) linear_extrude(convexity = 10, height = infSize, center = true)
                //minkowski() {
                import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
                //    circle(r=pcbClearance-delta);
                //};
      
           translate([0,0,-infSize/2+batteryPartH]) linear_extrude(convexity = 10, height = infSize, center = true)
                minkowski() {
                import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
                    circle(r=1);
                };
      
    }
}

intersection() {
    // pcb um null darauf waende in xyz
    difference()
    {
       minkowski() {
        linear_extrude(convexity = 10, height = batteryPartH, center = false)
                import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
        ellipsoid([wallOffset,wallOffset, topH]);
        }
    
    difference() {
        // cutout
        translate([0,0,0]) linear_extrude(convexity = 10, height = infSize, center = false)
                minkowski() {
                    import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
                     circle(r=pcbClearance, $fn=16);
                }
        }
        cubeEx([infSize, infSize, infSize], [0, 0, 0.5], [0,0, batteryPartH]);
    }
    
    
     // snapIn
    union() 
    {
      linear_extrude(convexity = 10, height = (batteryPartH-snapInH)*2, center = true)
			minkowski() {
                import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
                 circle(r=wallOffset+1, $fn=16);
            };
            
            linear_extrude(convexity = 10, height = (batteryPartH+snapInH)*2, center = true)
                minkowski() {
                    import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
                     circle(r=pcbClearance+snapInW, $fn=16);
                }
      }
}
};
cubeEx([6, 4, 10], [0, 0, -0], [4.5,-7, 0]);

     // screwholes and versenkte schraubenkoepfe ;)
		translate([0, 0, -1]) for (pos = cylPositions) {
			translate([pos[0], pos[1], -1]) {
				cylinder(r= 1.50, h = 50, center=true);
				#cylinder(r1= 4.3, r2= 0, h = 4.3, center=false);
			}
		}
        
       # translate([0, 0, 0]) for (pIdx = [0, 1, 2, 3]) {
            paramss = cylCutawayParams[pIdx];
         echo(paramss);
            //params=paramss[0];
        for (params = paramss)
            if (params[0]) {
                pos = cylPositions[pIdx];
                rp = params[1];
                tr = params[2];
                 translate(tr) translate([pos[0], pos[1], pillarH]) rotate(rp) {
                    cubeEx([cCS, cCS, cCS]);
                }
            }
		}
            
                

      //#translate([0,0,-topH]) LogoCutout(doLogo = true, doVNr = doVersionNr);
   
     
     // aux HOLES (reset, power off)B
     union() {
     
     for (pos = smallButtonPositions) {
			translate([pos[0], pos[1]-cylYOffset]) {
				cylinder(r= 1.3, h = 4*infSize, center=true);
			}
		}
    }

 *for (pos = buttonPositions) {
			translate([pos[0], pos[1], 10 - pos[2]])
                ellipsoid([bbRX,bbR,bbR]);      
     } 
     
     translate([0,0,10-2*buttonPositions[0][2]]) ButtonCutout();
}}

module LogoCutout(doLogo, doVNr) {
    
      translate([0,0,0]) {
         linear_extrude(convexity = 10, height = 2*logoH, center = true ) {
                if (doLogo) {
                    import(file = dxfFileName, layer = "logo_magic", convexity = 10, scale=1);
                    import(file = dxfFileName, layer = "logo_shifter", convexity = 10, scale=1);
                }
                if (doVNr) {
                    import(file = dxfFileName, layer = "VersionText", convexity = 10, scale=1);
                    *translate([77, -6  , 0]) circle(r = 1);
                }
            }
        }
    
}

module ButtonCutout() {
     for (pos = buttonPositions) {
        translate(pos) ellipsoid([bbRX,bbR,bbR],$fn=64);      
     }
 }


// led part
module LedPart() {
    difference() {
translate([0, 0, bottomH]) difference()
{
    // pcb um null in bottomH und dann in xyz fuer outher walls
    minkowski() {
        linear_extrude(convexity = 10, height = ledPartH, center = false)
                import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
        ellipsoid([wallOffset,wallOffset, bottomH]);
    }
    
    // pcp plus clearance
    translate([0,0,0]) linear_extrude(convexity = 10, height = infSize, center = false)
			minkowski() {
                import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
                 circle(r=pcbClearance, $fn=16);
            };

    if (doLedCutout) {
        // ledspace raus
        translate([0,0, glassH-bottomH]) linear_extrude(convexity = 10, height = infSize, center = false)
        
        minkowski() {
                import(file = dxfFileName, layer = "leds", convexity = 10, scale=1);
                    circle(r=1);
                };
    }
            
    // ledspace raus
    translate([0,0, doLedCutout ? -5 : glassH-bottomH]) linear_extrude(convexity = 10, height = infSize, center = false)
			import(file = dxfFileName, layer = "leds", convexity = 10, scale=1);
            
    // space for through hol components
    translate([0,0,-cutoutH])
    linear_extrude(convexity = 10, height = infSize, center = false)
			import(file = dxfFileName, layer = "cutout_solder", convexity = 10, scale=1);
            
     
    ButtonCutout();
            
 
        
     
            
            translate([-infSize/3,0, pcbH+usbH]) rotate([0,0,0]) rotate([90,00,0]) rotate([0,00,90]) rotate([90,90,0]) linear_extrude(convexity = 10, height = infSize, center = true)
			import(file = dxfFileName, layer = "usb", convexity = 10, scale=1);
      
       
   // occams razor ;)    
      cubeEx([infSize, infSize, infSize], [0, 0, 0.5], [0,0, ledPartH]);
         
            
      // snapIn
      translate([0,0,ledPartH-snapInH]) linear_extrude(convexity = 10, height = infSize, center = false)
			minkowski() {
                import(file = dxfFileName, layer = "pcb", convexity = 10, scale=1);
                 circle(r=wallOffset-snapInW, $fn=16);
            }
            
       #for (pos = cylPositions) {
			translate([pos[0], pos[1], -bottomH-0.1]) {
				cylinder(r1= 0.60, r2=1.00, h = bottomH+2*0.1, center=false);
			}
		}
           
            
            
            
}

//#translate([2,16,0]) 
#mirror([0,1,0]) 
#LogoCutout(doLogo = false, doVNr = doVersionNr);

}
}








// my improved version of the openSCAD cube module
// size works like the first parameter of the cube primitive, it's a 3 dim vector that contains the sidelengths of the "cube" ;)
// center is also a 3 dim vector so you can specify the centering for each axis individually, This is normaly either -0.5, 0 (equal to center = true), or 0.5 (equal to center = false) but any value is possible.
// offset specifies an absolute offset in mm from the position that would result from just the center parameter
module cubeEx(size=[1,1,1], center=[0,0,0], offset=[0,0,0], childCenters, childOffsets, unionNotDifference=0)
{
	//s = 1.5;
	//centerExp = [s*center[0], s*center[1], s*center[2]];

	translate([center[0]*size[0]+offset[0], center[1]*size[1]+offset[1], center[2]*size[2]+offset[2]])
	{
		if (!unionNotDifference)
			difference()
			{
				cube(size, center = true);
				if ($children > 0) for (i = [0:$children-1])
					translate([childCenters[i][0]*size[0]+childOffsets[i][0], childCenters[i][1]*size[1]+childOffsets[i][1], childCenters[i][2]*size[2]+childOffsets[i][2]]) child(i);
			}
		if (unionNotDifference)
			union()
			{
				cube(size, center = true);
				if ($children > 0) for (i = [0:$children-1])
					translate([childCenters[i][0]*size[0]+childOffsets[i][0], childCenters[i][1]*size[1]+childOffsets[i][1], childCenters[i][2]*size[2]+childOffsets[i][2]]) child(i);
			}
	}
}


module ellipsoid(v)
{
    scale(v, $fn=16) sphere(r=1);
}


    