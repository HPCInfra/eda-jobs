
# flow.tcl
# 1. Load the PDK and synthesized netlist
read_lef Nangate45_tech.lef
read_lef Nangate45_stdcell.lef
read_liberty Nangate45_typ.lib
read_verilog alu_synth.v
link_design alu

# 2. Floorplan: Set die/core area and the specific site name for Nangate45
initialize_floorplan -die_area "0 0 50 50" -core_area "5 5 45 45" -site FreePDK45_38x28_10R_NP_162NW_34O

# 3. Generate routing tracks for the metal layers
make_tracks

# 4. Place IO pins randomly on specific metal layers
place_pins -random -hor_layers metal3 -ver_layers metal4

# 5. Global and Detailed Placement
global_placement
detailed_placement

# 6. Global and Detailed Routing
global_route
detailed_route

# 7. Save the final layout database
write_def alu_routed.def
write_db alu_routed.odb
