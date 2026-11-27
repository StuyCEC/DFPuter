
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl

set_global_connections

set pdn_rail_layer       "Metal1"
set pdn_vertical_layer   "Metal4"
set pdn_horizontal_layer "Metal3"

set pdn_core_vertical_layer   "Metal4"
set pdn_core_horizontal_layer "Metal3"

set allowed_pdn_layers {
    Metal1
    Metal2
    Metal3
    Metal4
}

foreach layer [list \
    $pdn_rail_layer \
    $pdn_vertical_layer \
    $pdn_horizontal_layer \
    $pdn_core_vertical_layer \
    $pdn_core_horizontal_layer \
] {
    if {[lsearch -exact $allowed_pdn_layers $layer] < 0} {
        error "Invalid GF180MCU PDN layer: $layer"
    }
}

set secondary []

foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
    if {$vdd != $::env(VDD_NET)} {
        lappend secondary $vdd
        set db_net [[ord::get_db_block] findNet $vdd]

        if {$db_net == "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $vdd]
            $net setSpecial
            $net setSigType "POWER"
        }
    }

    if {$gnd != $::env(GND_NET)} {
        lappend secondary $gnd
        set db_net [[ord::get_db_block] findNet $gnd]

        if {$db_net == "NULL"} {
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

if {$::env(PDN_MULTILAYER) == 1} {
    set arg_list [list]

    if {$::env(PDN_ENABLE_PINS)} {
        lappend arg_list -pins "$pdn_vertical_layer $pdn_horizontal_layer"
    }

    define_pdn_grid \
        -name stdcell_grid \
        -starts_with POWER \
        -voltage_domain CORE \
        {*}$arg_list

    set arg_list [list]

    append_if_equals arg_list PDN_EXTEND_TO \
        "core_ring" -extend_to_core_ring

    append_if_equals arg_list PDN_EXTEND_TO \
        "boundary" -extend_to_boundary

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $pdn_vertical_layer \
        -width $::env(PDN_VWIDTH) \
        -pitch $::env(PDN_VPITCH) \
        -offset $::env(PDN_VOFFSET) \
        -spacing $::env(PDN_VSPACING) \
        -starts_with POWER \
        {*}$arg_list

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $pdn_horizontal_layer \
        -width $::env(PDN_HWIDTH) \
        -pitch $::env(PDN_HPITCH) \
        -offset $::env(PDN_HOFFSET) \
        -spacing $::env(PDN_HSPACING) \
        -starts_with POWER \
        {*}$arg_list

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "Metal1 Metal2"

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "Metal2 Metal3"

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "Metal3 Metal4"
} else {
    set arg_list [list]

    if {$::env(PDN_ENABLE_PINS)} {
        lappend arg_list -pins "$pdn_vertical_layer"
    }

    define_pdn_grid \
        -name stdcell_grid \
        -starts_with POWER \
        -voltage_domain CORE \
        {*}$arg_list

    set arg_list [list]

    append_if_equals arg_list PDN_EXTEND_TO \
        "core_ring" -extend_to_core_ring

    append_if_equals arg_list PDN_EXTEND_TO \
        "boundary" -extend_to_boundary

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $pdn_vertical_layer \
        -width $::env(PDN_VWIDTH) \
        -pitch $::env(PDN_VPITCH) \
        -offset $::env(PDN_VOFFSET) \
        -spacing $::env(PDN_VSPACING) \
        -starts_with POWER \
        {*}$arg_list
}

if {$::env(PDN_ENABLE_RAILS) == 1} {
    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $pdn_rail_layer \
        -width $::env(PDN_RAIL_WIDTH) \
        -followpins

    if {$::env(PDN_MULTILAYER) != 1} {
        add_pdn_connect \
            -grid stdcell_grid \
            -layers "Metal1 Metal2"
    }
}

if {$::env(PDN_CORE_RING) == 1} {
    if {$::env(PDN_MULTILAYER) != 1} {
        error "PDN_CORE_RING requires PDN_MULTILAYER"
    }

    set arg_list [list]

    append_if_flag arg_list \
        PDN_CORE_RING_ALLOW_OUT_OF_DIE \
        -allow_out_of_die

    append_if_flag arg_list \
        PDN_CORE_RING_CONNECT_TO_PADS \
        -connect_to_pads

    append_if_equals arg_list PDN_EXTEND_TO \
        "boundary" -extend_to_boundary

    add_pdn_ring \
        -grid stdcell_grid \
        -layers "$pdn_core_vertical_layer $pdn_core_horizontal_layer" \
        -widths "$::env(PDN_CORE_RING_VWIDTH) $::env(PDN_CORE_RING_HWIDTH)" \
        -spacings "$::env(PDN_CORE_RING_VSPACING) $::env(PDN_CORE_RING_HSPACING)" \
        -core_offset "$::env(PDN_CORE_RING_VOFFSET) $::env(PDN_CORE_RING_HOFFSET)" \
        {*}$arg_list

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "Metal3 Metal4"
}

define_pdn_grid \
    -macro \
    -default \
    -name macro \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid macro \
    -layers "Metal1 Metal2"

add_pdn_connect \
    -grid macro \
    -layers "Metal2 Metal3"

add_pdn_connect \
    -grid macro \
    -layers "Metal3 Metal4"

define_pdn_grid \
    -macro \
    -instances "sram_inst" \
    -name sram_grid \
    -starts_with POWER \
    -grid_over_pg_pins

add_pdn_connect -grid sram_grid -layers "Metal3_PIN_hor Metal4"

add_pdn_connect \
    -grid sram_grid \
    -layers "Metal1 Metal2"

add_pdn_connect \
    -grid sram_grid \
    -layers "Metal2 Metal3"

add_pdn_connect \
    -grid sram_grid \
    -layers "Metal3 Metal4"
