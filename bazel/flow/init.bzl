# Init rule - entry point for the flow

load(":providers.bzl", "LibrelaneInfo", "PdkInfo", "MacroInfo")
load(":common.bzl", "ENTRY_ATTRS")

def _init_impl(ctx):
    """Package verilog files and config into LibrelaneInfo for the flow."""
    pdk_info = ctx.attr.pdk[PdkInfo]

    # Collect macros if provided
    macros = []
    if ctx.attr.macros:
        for macro_target in ctx.attr.macros:
            macros.append(macro_target[MacroInfo])

    return [
        DefaultInfo(files = depset(ctx.files.verilog_files)),
        LibrelaneInfo(
            top = ctx.attr.top,
            clock_port = ctx.attr.clock_port,
            clock_period = ctx.attr.clock_period,
            pdk_info = pdk_info,
            verilog_files = depset(ctx.files.verilog_files),
            state_out = None,
            nl = None,
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
            macros = macros,
            **{"def": None}
        ),
    ]

librelane_init = rule(
    implementation = _init_impl,
    attrs = ENTRY_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)
