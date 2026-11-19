add_global_connection \
    -net $::env(VDD_NET) \
    -inst_pattern {.*} \
    -pin_pattern {^VDD$} \
    -power

add_global_connection \
    -net $::env(GND_NET) \
    -inst_pattern {.*} \
    -pin_pattern {^VSS$} \
    -ground

global_connect

set_voltage_domain \
    -name CORE \
    -power $::env(VDD_NET) \
    -ground $::env(GND_NET)

define_pdn_grid \
    -name core_grid \
    -voltage_domains {CORE} \
    -starts_with POWER

add_pdn_stripe \
    -grid core_grid \
    -layer Metal1 \
    -width 0.6 \
    -followpins

add_pdn_stripe \
    -grid core_grid \
    -layer Metal4 \
    -width 1.6 \
    -pitch 50.0 \
    -offset 13.0 \
    -starts_with POWER

add_pdn_stripe \
    -grid core_grid \
    -layer Metal5 \
    -width 1.6 \
    -pitch 50.0 \
    -offset 13.0 \
    -starts_with POWER

add_pdn_connect \
    -grid core_grid \
    -layers {Metal1 Metal4}

add_pdn_connect \
    -grid core_grid \
    -layers {Metal4 Metal5}

define_pdn_grid \
    -macro \
    -name sram_grid \
    -instances {memory} \
    -starts_with POWER \
    -halo {15 15}

add_pdn_stripe \
    -grid sram_grid \
    -layer Metal4 \
    -width 1.6 \
    -pitch 20.0 \
    -offset 5.0 \
    -starts_with POWER

add_pdn_connect \
    -grid sram_grid \
    -layers {Metal2 Metal4}

add_pdn_connect \
    -grid sram_grid \
    -layers {Metal4 Metal5}
