source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl

set_global_connections

set secondary []

foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
    if { $vdd != $::env(VDD_NET) } {
        lappend secondary $vdd
        set db_net [[ord::get_db_block] findNet $vdd]
        if { $db_net == "NULL" } {
            set net [odb::dbNet_create [ord::get_db_block] $vdd]
            $net setSpecial
            $net setSigType "POWER"
        }
    }

    if { $gnd != $::env(GND_NET) } {
        lappend secondary $gnd
        set db_net [[ord::get_db_block] findNet $gnd]
        if { $db_net == "NULL" } {
            set net [odb::dbNet_create [ord::get_db_block] $gnd]
            $net setSpecial
            $net setSigType "GROUND"
        }
    }
}

set_voltage_domain \
    -name CORE \
    -power $::env(VDD_NET) \
    -ground $::env(GND_NET) \
    -secondary_power $secondary

define_pdn_grid \
    -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain CORE \
    -pins "Metal4 Metal3"

add_pdn_stripe \
    -grid stdcell_grid \
    -layer Metal4 \
    -width 1.6 \
    -pitch 30.0 \
    -offset 2.0 \
    -starts_with POWER

add_pdn_stripe \
    -grid stdcell_grid \
    -layer Metal3 \
    -width 1.6 \
    -pitch 30.0 \
    -offset 2.0 \
    -starts_with POWER

add_pdn_stripe \
    -grid stdcell_grid \
    -layer Metal1 \
    -width 0.48 \
    -followpins

add_pdn_connect \
    -grid stdcell_grid \
    -layers "Metal1 Metal3"

add_pdn_connect \
    -grid stdcell_grid \
    -layers "Metal3 Metal4"

define_pdn_grid \
    -macro \
    -default \
    -name macro \
    -starts_with POWER \
    -halo "10 10"

add_pdn_connect \
    -grid macro \
    -layers "Metal3 Metal4"