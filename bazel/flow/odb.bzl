# Odb (OpenDB) manipulation rules

load(":common.bzl", "single_step_impl", "FLOW_ATTRS")
load(":providers.bzl", "LibrelaneInfo")

def _check_macro_antenna_properties_impl(ctx):
    return single_step_impl(ctx, "Odb.CheckMacroAntennaProperties")

def _set_power_connections_impl(ctx):
    return single_step_impl(ctx, "Odb.SetPowerConnections")

def _manual_macro_placement_impl(ctx):
    return single_step_impl(ctx, "Odb.ManualMacroPlacement")

def _add_pdn_obstructions_impl(ctx):
    return single_step_impl(ctx, "Odb.AddPDNObstructions")

def _remove_pdn_obstructions_impl(ctx):
    return single_step_impl(ctx, "Odb.RemovePDNObstructions")

def _add_routing_obstructions_impl(ctx):
    return single_step_impl(ctx, "Odb.AddRoutingObstructions")

def _custom_io_placement_impl(ctx):
    return single_step_impl(ctx, "Odb.CustomIOPlacement")

def _apply_def_template_impl(ctx):
    return single_step_impl(ctx, "Odb.ApplyDEFTemplate")

def _write_verilog_header_impl(ctx):
    return single_step_impl(ctx, "Odb.WriteVerilogHeader")

def _manual_global_placement_impl(ctx):
    return single_step_impl(ctx, "Odb.ManualGlobalPlacement")

def _diodes_on_ports_impl(ctx):
    return single_step_impl(ctx, "Odb.DiodesOnPorts")

def _heuristic_diode_insertion_impl(ctx):
    return single_step_impl(ctx, "Odb.HeuristicDiodeInsertion")

def _remove_routing_obstructions_impl(ctx):
    return single_step_impl(ctx, "Odb.RemoveRoutingObstructions")

def _report_disconnected_pins_impl(ctx):
    return single_step_impl(ctx, "Odb.ReportDisconnectedPins")

def _report_wire_length_impl(ctx):
    return single_step_impl(ctx, "Odb.ReportWireLength")

def _cell_frequency_tables_impl(ctx):
    return single_step_impl(ctx, "Odb.CellFrequencyTables")

def _check_design_antenna_properties_impl(ctx):
    return single_step_impl(ctx, "Odb.CheckDesignAntennaProperties")

# Rule declarations
librelane_check_macro_antenna_properties = rule(
    implementation = _check_macro_antenna_properties_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_set_power_connections = rule(
    implementation = _set_power_connections_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_manual_macro_placement = rule(
    implementation = _manual_macro_placement_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_add_pdn_obstructions = rule(
    implementation = _add_pdn_obstructions_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_remove_pdn_obstructions = rule(
    implementation = _remove_pdn_obstructions_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_add_routing_obstructions = rule(
    implementation = _add_routing_obstructions_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_custom_io_placement = rule(
    implementation = _custom_io_placement_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_apply_def_template = rule(
    implementation = _apply_def_template_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_write_verilog_header = rule(
    implementation = _write_verilog_header_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_manual_global_placement = rule(
    implementation = _manual_global_placement_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_diodes_on_ports = rule(
    implementation = _diodes_on_ports_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_heuristic_diode_insertion = rule(
    implementation = _heuristic_diode_insertion_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_remove_routing_obstructions = rule(
    implementation = _remove_routing_obstructions_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_report_disconnected_pins = rule(
    implementation = _report_disconnected_pins_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_report_wire_length = rule(
    implementation = _report_wire_length_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_cell_frequency_tables = rule(
    implementation = _cell_frequency_tables_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)

librelane_check_design_antenna_properties = rule(
    implementation = _check_design_antenna_properties_impl,
    attrs = FLOW_ATTRS,
    provides = [DefaultInfo, LibrelaneInfo],
)
