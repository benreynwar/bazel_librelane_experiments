# Floorplan rule - creates initial placement area

load(":providers.bzl", "LibrelaneInfo")
load(":common.bzl",
    "create_librelane_config",
    "run_librelane_step",
    "get_input_files",
    "FLOW_ATTRS",
)

def _floorplan_impl(ctx):
    """Create floorplan with die area and pin placement."""
    src_info = ctx.attr.src[LibrelaneInfo]
    top = src_info.top

    # Declare outputs in target directory (librelane writes elsewhere, we copy)
    def_out = ctx.actions.declare_file(ctx.label.name + "/" + top + ".def")
    odb_out = ctx.actions.declare_file(ctx.label.name + "/" + top + ".odb")

    # Get input files
    inputs = get_input_files(src_info)

    # Create config with floorplan settings
    config = create_librelane_config(src_info)
    if ctx.attr.die_area:
        config["FP_SIZING"] = "absolute"
        config["DIE_AREA"] = [float(x) for x in ctx.attr.die_area.split(" ")]
    if ctx.attr.core_area:
        config["CORE_AREA"] = [float(x) for x in ctx.attr.core_area.split(" ")]
    if ctx.attr.core_utilization and not ctx.attr.die_area:
        config["FP_CORE_UTIL"] = int(ctx.attr.core_utilization)

    # Run floorplan
    state_out = run_librelane_step(
        ctx = ctx,
        step_id = "OpenROAD.Floorplan",
        outputs = [def_out, odb_out],
        config_content = json.encode(config),
        inputs = inputs,
        src_info = src_info,
    )

    return [
        DefaultInfo(files = depset([def_out, odb_out])),
        LibrelaneInfo(
            top = top,
            clock_port = src_info.clock_port,
            clock_period = src_info.clock_period,
            pdk_info = src_info.pdk_info,
            verilog_files = src_info.verilog_files,
            state_out = state_out,
            nl = src_info.nl,
            pnl = src_info.pnl,
            odb = odb_out,
            sdc = src_info.sdc,
            sdf = src_info.sdf,
            spef = src_info.spef,
            lib = src_info.lib,
            gds = src_info.gds,
            mag_gds = src_info.mag_gds,
            klayout_gds = src_info.klayout_gds,
            lef = src_info.lef,
            mag = src_info.mag,
            spice = src_info.spice,
            json_h = src_info.json_h,
            vh = src_info.vh,
            macros = src_info.macros,
            **{"def": def_out}
        ),
    ]

librelane_floorplan = rule(
    implementation = _floorplan_impl,
    attrs = dict(FLOW_ATTRS, **{
        "die_area": attr.string(doc = "Die area as 'x0 y0 x1 y1' in microns"),
        "core_area": attr.string(doc = "Core area as 'x0 y0 x1 y1' in microns"),
        "core_utilization": attr.string(
            doc = "Target core utilization percentage (0-100)",
            default = "40",
        ),
    }),
    provides = [DefaultInfo, LibrelaneInfo],
)
