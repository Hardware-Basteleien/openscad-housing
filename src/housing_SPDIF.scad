// --- EINSTELLUNGEN ---

// Was soll angezeigt werden? "gehaeuse" oder "deckel"
teil_anzeigen = "gehaeuse"; 

// Maße des Gehäuses (Außen)
laenge = 30;
breite = 20;
hoehe  = 20;

// Wandstärke
wand = 1.6; // 1.6mm ist gut für 3D Druck (4 Bahnen à 0.4mm)

// Bohrungen
loch_cinch = 8.00;
loch_kabel = 3.0;

// Toleranz für den Deckel (Spaltmaß)
// 0.15mm bis 0.2mm ist meist gut für einen festen Klemmsitz
toleranz = 0.2; 

// Qualität der Rundungen
$fn = 60; 

// --- LOGIK ---

if (teil_anzeigen == "gehaeuse") {
    gehaeuse();
} else if (teil_anzeigen == "deckel") {
    deckel();
} else {
    // Falls man beide sehen will zur Vorschau
    gehaeuse();
    translate([0, 0, hoehe + 5]) deckel();
}

// --- MODULE ---

module gehaeuse() {
    difference() {
        // 1. Der massive Block
        cube([laenge, breite, hoehe]);
        
        // 2. Der Innenraum (Schnitt)
        // Wir lassen oben offen (Z-Richtung)
        translate([wand, wand, wand]) {
            cube([laenge - 2*wand, breite - 2*wand, hoehe]);
        }
        
        // 3. Cinch Bohrung (7.75mm)
        // Positioniert an der linken Seite (X=0)
        translate([-1, breite/2, (hoehe/2) + (wand/2)]) {
            rotate([0, 90, 0]) {
                cylinder(d=loch_cinch, h=wand+2);
            }
        }
        
        // 4. Kabel Bohrung (2.5mm)
        // Positioniert an der gegenüberliegenden Seite (X=laenge)
        translate([laenge - wand - 1, breite/2, (hoehe/2) + (wand/2)]) {
            rotate([0, 90, 0]) {
                cylinder(d=loch_kabel, h=wand+2);
            }
        }
    }
}

module deckel() {
    // Die Deckplatte
    cube([laenge, breite, wand]);
    
    // Der Klemm-Rahmen (Steg, der in das Gehäuse greift)
    translate([wand + toleranz, wand + toleranz, wand]) {
        difference() {
            // Außenmaß des Stegs (Innenmaß Gehäuse minus Toleranz)
            cube([
                laenge - 2*(wand + toleranz), 
                breite - 2*(wand + toleranz), 
                3 // Der Steg ragt 3mm tief ins Gehäuse
            ]);
            
            // Innen hohl machen, um Material zu sparen und Flexibilität zu geben
            translate([wand, wand, -1]) {
                cube([
                    laenge - 2*(wand + toleranz) - 2*wand, 
                    breite - 2*(wand + toleranz) - 2*wand, 
                    5
                ]);
            }
        }
    }
}