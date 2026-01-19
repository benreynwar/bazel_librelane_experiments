# Routing rules

load(":providers.bzl", "LibrelaneInfo")
load(":common.bzl", "single_step_impl", "FLOW_ATTRS")

def _global_routing_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.GlobalRouting")

def _check_antennas_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.CheckAntennas")

def _repair_design_post_grt_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.RepairDesignPostGRT")

def _repair_antennas_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.RepairAntennas")

def _resizer_timing_post_grt_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.ResizerTimingPostGRT")

def _detailed_routing_impl(ctx):
    return single_step_impl(ctx, "OpenROAD.DetailedRouting")

librelane_global_routing = rule(
    implementation = _global_routing_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_check_antennas = rule(
    implementation = _check_antennas_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_repair_design_post_grt = rule(
    implementation = _repair_design_post_grt_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_repair_antennas = rule(
    implementation = _repair_antennas_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_resizer_timing_post_grt = rule(
    implementation = _resizer_timing_post_grt_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_detailed_routing = rule(
    implementation = _detailed_routing_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)
