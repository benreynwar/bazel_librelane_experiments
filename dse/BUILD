# DSE (Design Space Exploration) flow targets

load("//bazel:verilog.bzl", "generate_verilog_rule")
load("//bazel/flow:defs.bzl",
    "librelane_full_flow",
    "librelane_hard_macro",
)
load("@sky130_fd_sc_hd_config//:defs.bzl", "pdk")

# PDK (loaded from generated repository)
pdk(name = "sky130hd")

# ============================================================================
# Simple Adder (default configuration) - full flow with hard macro outputs
# ============================================================================

generate_verilog_rule(
    name = "Adder_default_verilog",
    generator_tool = "//src/main/scala/hwexample:adder",
    top = "Adder",
    config = "//configs:adder_default.json",
)

librelane_hard_macro(
    name = "Adder",
    verilog_files = [":Adder_default_verilog"],
    top = "Adder_default_verilog",
    pdk = ":sky130hd",
)

# ============================================================================
# Hard macros for hierarchical design
# ============================================================================

generate_verilog_rule(
    name = "Adder32_verilog",
    generator_tool = "//src/main/scala/hwexample:adder",
    top = "Adder",
    config = "//configs:adder32.json",
)

librelane_hard_macro(
    name = "Adder32",
    verilog_files = [":Adder32_verilog"],
    top = "Adder32_verilog",
    pdk = ":sky130hd",
    pin_order_cfg = "adder_pins.cfg",
)

generate_verilog_rule(
    name = "Adder33_verilog",
    generator_tool = "//src/main/scala/hwexample:adder",
    top = "Adder",
    config = "//configs:adder33.json",
)

librelane_hard_macro(
    name = "Adder33",
    verilog_files = [":Adder33_verilog"],
    top = "Adder33_verilog",
    pdk = ":sky130hd",
    pin_order_cfg = "adder_pins.cfg",
)

# ============================================================================
# FourInputAdder - hierarchical design using hard macros
# ============================================================================

generate_verilog_rule(
    name = "FourInputAdder_verilog",
    generator_tool = "//src/main/scala/hwexample:four_input_adder",
    top = "FourInputAdder",
    config = "//configs:four_input_adder.json",
)

librelane_full_flow(
    name = "FourInputAdder",
    verilog_files = [":FourInputAdder_verilog"],
    top = "FourInputAdder_verilog",
    pdk = ":sky130hd",
    clock_period = "10.0",
    die_area = "0 0 300 340",  # Sized to fit macros: 2x Adder32 (109x120) on top, 1x Adder33 (111x122) on bottom
    macros = [
        ":Adder32_lef",
        ":Adder33_lef",
    ],
    pin_order_cfg = "four_input_adder_pins.cfg",
    macro_placement_cfg = "four_input_adder_macros.cfg",
)
