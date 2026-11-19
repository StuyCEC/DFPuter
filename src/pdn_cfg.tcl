# Source LibreLane's standard PDN script first
source $::env(SCRIPTS_DIR)/openroad/pdn.tcl

# Bridge the SRAM macro's Metal3 power pins to the Metal4/Metal5 PDN straps
add_pdn_connect \
    -grid {macro} \
    -layers {Metal3 Metal4}