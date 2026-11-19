source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read_current_odb

# 1. Connect global VDD/VSS nets to standard cells and the SRAM macro
add_global_connection -net $::env(VDD_NET) -inst_pattern {.*} -pin_pattern {^VDD$} -power
add_global_connection -net $::env(GND_NET) -inst_pattern {.*} -pin_pattern {^VSS$} -ground
global_connect

# 2. Define voltage domain
set_voltage_domain -name CORE -power $::env(VDD_NET) -ground $::env(GND_NET)

# 3. Standard cell & top-level PDN grid (Metal1 rails -> Metal4 vertical -> Metal5 horizontal)
define_pdn_grid -name core_grid -voltage_domains {CORE} -starts_with POWER
add_pdn_stripe -grid core_grid -layer Metal1 -width 0.6 -followpins
add_pdn_stripe -grid core_grid -layer Metal4 -width 1.6 -pitch 50.0 -offset 13.0 -starts_with POWER
add_pdn_stripe -grid core_grid -layer Metal5 -width 1.6 -pitch 50.0 -offset 13.0 -starts_with POWER
add_pdn_connect -grid core_grid -layers {Metal1 Metal4}
add_pdn_connect -grid core_grid -layers {Metal4 Metal5}

# 4. Macro PDN grid: bridge the SRAM's Metal3 power pins up to Metal4/Metal5
define_pdn_grid -macro -name sram_grid -instances {memory} -starts_with POWER -halo {15 15}
add_pdn_stripe -grid sram_grid -layer Metal4 -width 1.6 -pitch 20.0 -offset 5.0 -starts_with POWER
add_pdn_connect -grid sram_grid -layers {Metal3 Metal4}
add_pdn_connect -grid sram_grid -layers {Metal4 Metal5}

pdngen
write_views