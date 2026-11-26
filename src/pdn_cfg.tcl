source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl


add_global_connection \
    -net $::env(VDD_NET) \
    -inst_pattern {sram_inst} \
    -pin_pattern {^(VDD.*|vdd.*)$}

add_global_connection \
    -net $::env(GND_NET) \
    -inst_pattern {sram_inst} \
    -pin_pattern {^(VSS.*|vss.*)$}

set_global_connections


set secondary {}

foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {

    if {$vdd ne $::env(VDD_NET)} {
        lappend secondary $vdd

        set db_net [[ord::get_db_block] findNet $vdd]

        if {$db_net eq "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $vdd]
            $net setSpecial
            $net setSigType POWER
        }
    }

    if {$gnd ne $::env(GND_NET)} {
        lappend secondary $gnd

        set db_net [[ord::get_db_block] findNet $gnd]

        if {$db_net eq "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $gnd]
            $net setSpecial
            $net setSigType GROUND
        }
    }
}


set_voltage_domain \
    -name CORE \
    -power $::env(VDD_NET) \
    -ground $::env(GND_NET) \
    -secondary_power $secondary


set extend_options {}

if {$::env(PDN_EXTEND_TO) eq "core_ring"} {
    lappend extend_options -extend_to_core_ring
} elseif {$::env(PDN_EXTEND_TO) eq "boundary"} {
    lappend extend_options -extend_to_boundary
}


set grid_options {}

if {$::env(PDN_ENABLE_PINS)} {
    lappend grid_options -pins Metal4
}

define_pdn_grid \
    -name stdcell_grid \
    -voltage_domains CORE \
    -starts_with POWER \
    {*}$grid_options


if {$::env(PDN_MULTILAYER)} {

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(PDN_VERTICAL_LAYER) \
        -width $::env(PDN_VWIDTH) \
        -pitch $::env(PDN_VPITCH) \
        -offset $::env(PDN_VOFFSET) \
        -spacing $::env(PDN_VSPACING) \
        -starts_with POWER \
        {*}$extend_options

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(PDN_HORIZONTAL_LAYER) \
        -width $::env(PDN_HWIDTH) \
        -pitch $::env(PDN_HPITCH) \
        -offset $::env(PDN_HOFFSET) \
        -spacing $::env(PDN_HSPACING) \
        -starts_with POWER \
        {*}$extend_options

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

} else {

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(PDN_VERTICAL_LAYER) \
        -width $::env(PDN_VWIDTH) \
        -pitch $::env(PDN_VPITCH) \
        -offset $::env(PDN_VOFFSET) \
        -spacing $::env(PDN_VSPACING) \
        -starts_with POWER \
        {*}$extend_options
}


if {$::env(PDN_ENABLE_RAILS)} {

    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(PDN_RAIL_LAYER) \
        -width $::env(PDN_RAIL_WIDTH) \
        -followpins

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "$::env(PDN_RAIL_LAYER) $::env(PDN_VERTICAL_LAYER)"
}


if {$::env(PDN_CORE_RING)} {

    if {!$::env(PDN_MULTILAYER)} {
        error "PDN_CORE_RING requires PDN_MULTILAYER"
    }

    set ring_options {}

    if {
        [info exists ::env(PDN_CORE_RING_ALLOW_OUT_OF_DIE)] &&
        $::env(PDN_CORE_RING_ALLOW_OUT_OF_DIE)
    } {
        lappend ring_options -allow_out_of_die
    }

    if {
        [info exists ::env(PDN_CORE_RING_CONNECT_TO_PADS)] &&
        $::env(PDN_CORE_RING_CONNECT_TO_PADS)
    } {
        lappend ring_options -connect_to_pads
    }

    if {$::env(PDN_EXTEND_TO) eq "boundary"} {
        lappend ring_options -extend_to_boundary
    }

    set pdn_core_vertical_layer $::env(PDN_VERTICAL_LAYER)
    set pdn_core_horizontal_layer $::env(PDN_HORIZONTAL_LAYER)

    if {[info exists ::env(PDN_CORE_VERTICAL_LAYER)]} {
        set pdn_core_vertical_layer $::env(PDN_CORE_VERTICAL_LAYER)
    }

    if {[info exists ::env(PDN_CORE_HORIZONTAL_LAYER)]} {
        set pdn_core_horizontal_layer $::env(PDN_CORE_HORIZONTAL_LAYER)
    }

    add_pdn_ring \
        -grid stdcell_grid \
        -layers "$pdn_core_vertical_layer $pdn_core_horizontal_layer" \
        -widths "$::env(PDN_CORE_RING_VWIDTH) $::env(PDN_CORE_RING_HWIDTH)" \
        -spacings "$::env(PDN_CORE_RING_VSPACING) $::env(PDN_CORE_RING_HSPACING)" \
        -core_offset "$::env(PDN_CORE_RING_VOFFSET) $::env(PDN_CORE_RING_HOFFSET)" \
        {*}$ring_options

    if {[info exists ::env(PDN_CORE_VERTICAL_LAYER)]} {
        add_pdn_connect \
            -grid stdcell_grid \
            -layers "$::env(PDN_CORE_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"
    }

    if {[info exists ::env(PDN_CORE_HORIZONTAL_LAYER)]} {
        add_pdn_connect \
            -grid stdcell_grid \
            -layers "$::env(PDN_CORE_HORIZONTAL_LAYER) $::env(PDN_VERTICAL_LAYER)"
    }

    if {
        [info exists ::env(PDN_CORE_VERTICAL_LAYER)] &&
        [info exists ::env(PDN_CORE_HORIZONTAL_LAYER)]
    } {
        add_pdn_connect \
            -grid stdcell_grid \
            -layers "$::env(PDN_CORE_VERTICAL_LAYER) $::env(PDN_CORE_HORIZONTAL_LAYER)"
    }
}


define_pdn_grid \
    -macro \
    -instances {sram_inst} \
    -name sram_grid \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_grid \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"


pdngen
