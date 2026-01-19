# Placement rules

load(":providers.bzl", "LibrelaneInfo")
load(":common.bzl", "single_step_impl", "FLOW_ATTRS")

def _macro_placement_impl(ctx):
    extra = {
        "PL_MACRO_HALO": ctx.attr.macro_halo,
        "PL_MACRO_CHANNEL": ctx.attr.macro_channel,
    }
    return single_step_impl(ctx, "OpenROAD.BasicMacroPlacement", extra)

def _manual_macro_placement_impl(ctx):
    extra = {
        "MACRO_PLACEMENT_CFG": ctx.file.macro_placement_cfg.path,
    }
    extra_inputs = [ctx.file.macro_placement_cfg]
    return single_step_impl(ctx, "Odb.ManualMacroPlacement", extra, extra_inputs)

def _cut_rows_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.CutRows")

def _tap_endcap_insertion_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.TapEndcapInsertion")

def _generate_pdn_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.GeneratePDN")

def _global_placement_skip_io_impl(ctx):
    extra = {}
    if ctx.attr.target_density:
        extra["PL_TARGET_DENSITY_PCT"] = int(float(ctx.attr.target_density) * 100)
    return single_step_impl(ctx, "OpenROAD.GlobalPlacementSkipIO", extra)

def _io_placement_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.IOPlacement")

def _custom_io_placement_impl(ctx):
    extra = {
        "FP_PIN_ORDER_CFG": ctx.file.pin_order_cfg.path,
    }
    extra_inputs = [ctx.file.pin_order_cfg]
    return single_step_impl(ctx, "Odb.CustomIOPlacement", extra, extra_inputs)

def _global_placement_impl(ctx):
    extra = {}
    if ctx.attr.target_density:
        extra["PL_TARGET_DENSITY_PCT"] = int(float(ctx.attr.target_density) * 100)
    return single_step_impl(ctx, "OpenROAD.GlobalPlacement", extra)

def _repair_design_post_gpl_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.RepairDesignPostGPL")

def _detailed_placement_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.DetailedPlacement")

def _cts_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.CTS")

def _resizer_timing_post_cts_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.ResizerTimingPostCTS")

_gpl_attrs = dict(FLOW_ATTRS, **{
    "target_density": attr.string(doc = "Target placement density (0.0-1.0)"),
})

_macro_placement_attrs = dict(FLOW_ATTRS, **{
    "macro_halo": attr.string(
        doc = "Macro placement halo '{Horizontal} {Vertical}' in µm",
        default = "10 10",
    ),
    "macro_channel": attr.string(
        doc = "Channel widths between macros '{Horizontal} {Vertical}' in µm",
        default = "20 20",
    ),
})

_manual_macro_placement_attrs = dict(FLOW_ATTRS, **{
    "macro_placement_cfg": attr.label(
        doc = "Macro placement configuration file (instance X Y orientation)",
        allow_single_file = True,
        mandatory = True,
    ),
})

librelane_macro_placement = rule(
    implementation = _macro_placement_impl,
    attrs = _macro_placement_attrs,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_manual_macro_placement = rule(
    implementation = _manual_macro_placement_impl,
    attrs = _manual_macro_placement_attrs,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_cut_rows = rule(
    implementation = _cut_rows_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_tap_endcap_insertion = rule(
    implementation = _tap_endcap_insertion_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_generate_pdn = rule(
    implementation = _generate_pdn_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_global_placement_skip_io = rule(
    implementation = _global_placement_skip_io_impl,
    attrs = _gpl_attrs,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_io_placement = rule(
    implementation = _io_placement_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

_custom_io_attrs = dict(FLOW_ATTRS, **{
    "pin_order_cfg": attr.label(
        doc = "Pin order configuration file for custom IO placement",
        allow_single_file = True,
        mandatory = True,
    ),
})

librelane_custom_io_placement = rule(
    implementation = _custom_io_placement_impl,
    attrs = _custom_io_attrs,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_global_placement = rule(
    implementation = _global_placement_impl,
    attrs = _gpl_attrs,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_repair_design_post_gpl = rule(
    implementation = _repair_design_post_gpl_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_detailed_placement = rule(
    implementation = _detailed_placement_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_cts = rule(
    implementation = _cts_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_resizer_timing_post_cts = rule(
    implementation = _resizer_timing_post_cts_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)
