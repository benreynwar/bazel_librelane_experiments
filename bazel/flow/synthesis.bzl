# Synthesis rule - produces netlist from RTL

load(":providers.bzl", "LibrelaneInfo")
load(":common.bzl",
    "create_librelane_config",
    "run_librelane_step",
    "get_input_files",
    "FLOW_ATTRS",
)

def _synthesis_impl(ctx):
    """Synthesize verilog to gate-level netlist."""
    src_info = ctx.attr.src[LibrelaneInfo]
    top = src_info.top

    # Declare outputs in target directory (librelane writes elsewhere, we copy)
    # Note: Yosys.Synthesis only outputs netlist, not SDC
    nl = ctx.actions.declare_file(ctx.label.name + "/" + top + ".nl.v")

    # Get input files
    inputs = get_input_files(src_info)

    # Create config
    config = create_librelane_config(src_info)

    # Run synthesis
    state_out = run_librelane_step(
        ctx = ctx,
        step_id = "Yosys.Synthesis",
        outputs = [nl],
        config_content = json.encode(config),
        inputs = inputs,
        src_info = src_info,
    )

    return [
        DefaultInfo(files = depset([nl])),
        LibrelaneInfo(
            top = top,
            clock_port = src_info.clock_port,
            clock_period = src_info.clock_period,
            pdk_info = src_info.pdk_info,
            verilog_files = src_info.verilog_files,
            state_out = state_out,
            nl = nl,
            pnl = None,
            odb = None,
            sdc = None,
            sdf = None,
            spef = None,
            lib = None,
            gds = None,
            mag_gds = None,
            klayout_gds = None,
            lef = None,
            mag = None,
            spice = None,
            json_h = None,
            vh = None,
            macros = src_info.macros,
            **{"def": None}
        ),
    ]

librelane_synthesis = rule(
    implementation = _synthesis_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)
