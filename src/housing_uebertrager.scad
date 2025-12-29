// --- PARAMETER ---

// Innenmaße (95mm x 80mm x 35mm)
innen_breite = 95;  
innen_laenge = 80;  
innen_hoehe  = 35;  

// Wandstärke
wand = 2.0;
boden = 2.0;

// --- KABEL-KONFIGURATION ---
// Positionen der Löcher entlang der Y-Achse (aus Skizze: 20mm und 60mm)
kabel_positionen_y = [20, 60]; 

kabel_durchmesser = 8;
kabel_hoehe_z = 16; // Höhe der Kabelmitte vom Boden

// --- ZUGENTLASTUNG ---
// Abstand zur Innenwand
zugentlastung_abstand = 3.0; 

// Breite des Schlitzes für den Kabelbinder (Tunnel)
// 0.5mm ist sehr eng für den 3D-Druck. Standard-Binder sind 2.5-4.8mm breit.
// Hier auf 4mm voreingestellt. Falls wirklich 0.5mm gewollt: hier ändern!
kabelbinder_breite = 4.0; 
kabelbinder_dicke = 1.5; // Höhe des Schlitzes

// --- PLATINEN-HALTERUNG ---
pcb_lochabstand = 45;
pcb_standoff_hoehe = 10; 
pcb_sockel_d = 10; 
pcb_schraube_d = 2.8; // Kernloch M3

// Deckel Toleranz
deckel_toleranz = 0.15; 
$fn = 60; 

// --- HAUPTPROGRAMM ---

union() {
    gehaeuse();
    // Deckel daneben platzieren
    translate([0, -innen_laenge - 20, 0]) deckel();
}

// --- MODULE ---

module gehaeuse() {
    aussen_breite = innen_breite + 2*wand;
    aussen_laenge = innen_laenge + 2*wand;
    aussen_hoehe  = innen_hoehe + boden;
    
    mitte_x = aussen_breite / 2;
    mitte_y = aussen_laenge / 2;

    union() {
        difference() {
            // 1. Der massive Gehäuse-Körper
            cube([aussen_breite, aussen_laenge, aussen_hoehe]);

            // 2. Der Innenraum (Aushöhlung)
            translate([wand, wand, boden])
                cube([innen_breite, innen_laenge, innen_hoehe + 1]);

            // 3. Kabellöcher (Schleife für alle Positionen)
            for (pos_y = kabel_positionen_y) {
                // Linke Seite
                translate([-1, wand + pos_y, boden + kabel_hoehe_z])
                    rotate([0, 90, 0])
                    cylinder(d=kabel_durchmesser, h=wand+2);
                
                // Rechte Seite
                translate([aussen_breite - wand -1, wand + pos_y, boden + kabel_hoehe_z])
                    rotate([0, 90, 0])
                    cylinder(d=kabel_durchmesser, h=wand+2);
            }
        }

        // 4. Zugentlastungs-Sockel hinzufügen
        for (pos_y = kabel_positionen_y) {
            // LINKS
            translate([wand + zugentlastung_abstand, wand + pos_y, boden])
                zugentlastung_block();

            // RECHTS (spiegelverkehrt positioniert)
            translate([aussen_breite - wand - zugentlastung_abstand, wand + pos_y, boden])
                rotate([0, 0, 180]) // Umdrehen, damit der Block nach innen zeigt
                zugentlastung_block();
        }

        // 5. Platinenhalter (Standoffs)
        translate([mitte_x - pcb_lochabstand/2, mitte_y, boden])
            standoff();
            
        translate([mitte_x + pcb_lochabstand/2, mitte_y, boden])
            standoff();
    }
}

module zugentlastung_block() {
    // Ein Block, der das Kabel stützt und einen Tunnel für den Binder hat
    block_laenge = 12; // Entlang der Y-Achse (etwas breiter als das 8mm Loch)
    block_breite = 8;  // Entlang der X-Achse (in den Raum hinein)
    block_hoehe  = kabel_hoehe_z - (kabel_durchmesser/2) + 2; // Bis knapp unter das Kabel

    translate([0, -block_laenge/2, 0]) // Zentrieren auf Loch-Achse
    difference() {
        // Der massive Block
        cube([block_breite, block_laenge, block_hoehe]);

        // Der Tunnel für den Kabelbinder
        // Er verläuft quer (Y-Achse) durch den Block
        translate([block_breite/2 - kabelbinder_breite/2, -1, 2]) // 2mm Boden unter dem Tunnel
            cube([kabelbinder_breite, block_laenge + 2, kabelbinder_dicke]);
            
        // Optional: Kleine Mulde oben für das Kabel
        translate([-1, block_laenge/2, block_hoehe])
            rotate([0, 90, 0])
            cylinder(d=kabel_durchmesser, h=block_breite+2);
    }
}

module standoff() {
    difference() {
        cylinder(d=pcb_sockel_d, h=pcb_standoff_hoehe);
        translate([0,0,1]) 
            cylinder(d=pcb_schraube_d, h=pcb_standoff_hoehe+1);
    }
}

module deckel() {
    aussen_breite = innen_breite + 2*wand;
    aussen_laenge = innen_laenge + 2*wand;
    deckel_dicke = 2;
    rand_hoehe = 4;

    cube([aussen_breite, aussen_laenge, deckel_dicke]);

    translate([wand + deckel_toleranz, wand + deckel_toleranz, deckel_dicke])
        difference() {
            cube([innen_breite - 2*deckel_toleranz, innen_laenge - 2*deckel_toleranz, rand_hoehe]);
            
            translate([wand, wand, -1])
                cube([innen_breite - 2*deckel_toleranz - 2*wand, innen_laenge - 2*deckel_toleranz - 2*wand, rand_hoehe + 2]);
        }
}