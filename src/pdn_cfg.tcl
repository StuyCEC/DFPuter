source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl

# Global power connections for the SRAM macro
add_global_connection -net $::env(VDD_NET) -inst_pattern sram_inst -pin_pattern {^VDD.*|^vdd.*}
add_global_connection -net $::env(GND_NET) -inst_pattern sram_inst -pin_pattern {^VSS.*|^vss.*}

set_global_connections

set_voltage_domain \
    -name CORE \
    -power $::env(VDD_NET) \
    -ground $::env(GND_NET)

# Standard cell power grid definition using explicit layers
define_pdn_grid \
    -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain CORE \
    -pins "Metal4"

add_pdn_stripe \
    -grid stdcell_grid \
    -layer Metal3 \
    -width 1.6 \
    -pitch 25.0 \
    -offset 2.0 \
    -starts_with POWER \
    -extend_to boundary

add_pdn_stripe \
    -grid stdcell_grid \
    -layer Metal4 \
    -width 1.6 \
    -pitch 25.0 \
    -offset 2.0 \
    -starts_with POWER \
    -extend_to boundary

add_pdn_connect \
    -grid stdcell_grid \
    -layers "Metal3 Metal4"

# Dedicated macro grid for sram_inst using upper metal layers
define_pdn_grid \
    -macro \
    -instances "sram_inst" \
    -name sram_grid \
    -starts_with POWER \
    -halo "2.0 2.0"

add_pdn_connect \
    -grid sram_grid \
    -layers "Metal3 Metal4"