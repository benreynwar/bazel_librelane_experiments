# DSE (Design Space Exploration) flow targets

load("//bazel:verilog.bzl", "generate_verilog_rule")
load("//bazel/flow:defs.bzl",
    "librelane_pdk",
    "librelane_synthesis",
    "librelane_floorplan",
    "librelane_io_placement",
    "librelane_global_placement",
    "librelane_detailed_placement",
    "librelane_cts",
    "librelane_global_routing",
    "librelane_detailed_routing",
    "librelane_sta_mid_pnr",
)

# PDK
librelane_pdk(
    name = "sky130hd",
    pdk_name = "sky130A",
    scl = "sky130_fd_sc_hd",
)

# Generate Verilog from Chisel
generate_verilog_rule(
    name = "Adder_default_verilog",
    generator_tool = "//src/main/scala/hwexample:adder",
    top = "Adder",
    config = "//configs:adder_default.json",
)

# Flow
librelane_synthesis(
    name = "Adder_synth",
    verilog_files = [":Adder_default_verilog"],
    top = "Adder_default_verilog",
    pdk = ":sky130hd",
    clock_period = "10.0",
    clock_port = "clock",
)

librelane_floorplan(
    name = "Adder_floorplan",
    src = ":Adder_synth",
    core_utilization = "40",
)

librelane_io_placement(
    name = "Adder_io",
    src = ":Adder_floorplan",
)

librelane_global_placement(
    name = "Adder_gpl",
    src = ":Adder_io",
    target_density = "0.5",
)

librelane_detailed_placement(
    name = "Adder_dpl",
    src = ":Adder_gpl",
)

librelane_cts(
    name = "Adder_cts",
    src = ":Adder_dpl",
)

librelane_global_routing(
    name = "Adder_grt",
    src = ":Adder_cts",
)

librelane_detailed_routing(
    name = "Adder_drt",
    src = ":Adder_grt",
)

librelane_sta_mid_pnr(
    name = "Adder_sta",
    src = ":Adder_drt",
)
