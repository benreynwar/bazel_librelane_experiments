# Hard macro generation rules (Fill, GDS, LEF) and Magic steps

load(":providers.bzl", "LibrelaneInfo", "MacroInfo")
load(":common.bzl",
    "create_librelane_config",
    "run_librelane_step",
    "single_step_impl",
    "get_input_files",
    "FLOW_ATTRS",
)

def _fill_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.FillInsertion")

def _gds_impl(ctx):
    """Generate GDSII layout."""
    src_info = ctx.attr.src[LibrelaneInfo]
    top = src_info.top

    # Declare GDS output in target directory
    gds = ctx.actions.declare_file(ctx.label.name + "/" + top + ".gds")

    # Get input files
    inputs = get_input_files(src_info)

    # Create config
    config = create_librelane_config(src_info)

    # Run GDS generation
    state_out = run_librelane_step(
        ctx = ctx,
        step_id = "Magic.StreamOut",
        outputs = [gds],
        config_content = json.encode(config),
        inputs = inputs,
        src_info = src_info,
    )

    return [
        DefaultInfo(files = depset([gds])),
        LibrelaneInfo(
            top = top,
            clock_port = src_info.clock_port,
            clock_period = src_info.clock_period,
            pdk_info = src_info.pdk_info,
            verilog_files = src_info.verilog_files,
            state_out = state_out,
            nl = src_info.nl,
            pnl = src_info.pnl,
            odb = src_info.odb,
            sdc = src_info.sdc,
            sdf = src_info.sdf,
            spef = src_info.spef,
            lib = src_info.lib,
            gds = gds,
            mag_gds = src_info.mag_gds,
            klayout_gds = src_info.klayout_gds,
            lef = src_info.lef,
            mag = src_info.mag,
            spice = src_info.spice,
            json_h = src_info.json_h,
            vh = src_info.vh,
            macros = src_info.macros,
            **{"def": getattr(src_info, "def", None)}
        ),
    ]

def _lef_impl(ctx):
    """Generate LEF abstract and provide MacroInfo for hierarchical use."""
    src_info = ctx.attr.src[LibrelaneInfo]
    top = src_info.top

    # Declare LEF output in target directory
    lef = ctx.actions.declare_file(ctx.label.name + "/" + top + ".lef")

    # Get input files
    inputs = get_input_files(src_info)

    # Create config
    config = create_librelane_config(src_info)

    # Run LEF generation
    state_out = run_librelane_step(
        ctx = ctx,
        step_id = "Magic.WriteLEF",
        outputs = [lef],
        config_content = json.encode(config),
        inputs = inputs,
        src_info = src_info,
    )

    # Create MacroInfo for hierarchical designs
    macro_info = MacroInfo(
        name = top,
        lef = lef,
        gds = src_info.gds,
        netlist = src_info.nl,
    )

    return [
        DefaultInfo(files = depset([lef])),
        LibrelaneInfo(
            top = top,
            clock_port = src_info.clock_port,
            clock_period = src_info.clock_period,
            pdk_info = src_info.pdk_info,
            verilog_files = src_info.verilog_files,
            state_out = state_out,
            nl = src_info.nl,
            pnl = src_info.pnl,
            odb = src_info.odb,
            sdc = src_info.sdc,
            sdf = src_info.sdf,
            spef = src_info.spef,
            lib = src_info.lib,
            gds = src_info.gds,
            mag_gds = src_info.mag_gds,
            klayout_gds = src_info.klayout_gds,
            lef = lef,
            mag = src_info.mag,
            spice = src_info.spice,
            json_h = src_info.json_h,
            vh = src_info.vh,
            macros = src_info.macros,
            **{"def": getattr(src_info, "def", None)}
        ),
        macro_info,
    ]

def _drc_impl(ctx):
    return single_step_impl(ctx, "Magic.DRC")

def _spice_extraction_impl(ctx):
    return single_step_impl(ctx, "Magic.SpiceExtraction")

librelane_fill = rule(
    implementation = _fill_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_gds = rule(
    implementation = _gds_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_lef = rule(
    implementation = _lef_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo, MacroInfo],
)

librelane_magic_drc = rule(
    implementation = _drc_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_spice_extraction = rule(
    implementation = _spice_extraction_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)
