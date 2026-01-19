# Full P&R flow macros

load(":init.bzl", "librelane_init")
load(":synthesis.bzl", "librelane_synthesis")
load(":floorplan.bzl", "librelane_floorplan")
load(":place.bzl",
    "librelane_macro_placement",
    "librelane_io_placement",
    "librelane_global_placement",
    "librelane_detailed_placement",
    "librelane_cts",
)
load(":route.bzl",
    "librelane_global_routing",
    "librelane_detailed_routing",
)
load(":sta.bzl", "librelane_rcx", "librelane_sta_post_pnr")
load(":macro.bzl",
    "librelane_fill",
    "librelane_gds",
    "librelane_lef",
)


def librelane_full_flow(
    name,
    verilog_files,
    top,
    pdk,
    clock_period = "10.0",
    clock_port = "clock",
    core_utilization = "40",
    target_density = "0.5",
    macros = []):
    """Flow from Verilog through detailed routing and STA.

    Args:
        name: Base name for all targets
        verilog_files: List of Verilog source files
        top: Top module name
        pdk: PDK target
        clock_period: Clock period in ns
        clock_port: Clock port name
        core_utilization: Target core utilization (0-100)
        target_density: Target placement density (0.0-1.0)
        macros: List of hard macro targets (for hierarchical designs)
    """

    # Init - package inputs
    librelane_init(
        name = name + "_init",
        verilog_files = verilog_files,
        top = top,
        pdk = pdk,
        clock_period = clock_period,
        clock_port = clock_port,
        macros = macros,
    )

    # Synthesis
    librelane_synthesis(
        name = name + "_synth",
        src = ":" + name + "_init",
    )

    # Floorplan
    librelane_floorplan(
        name = name + "_floorplan",
        src = ":" + name + "_synth",
        core_utilization = core_utilization,
    )

    # Placement
    librelane_io_placement(
        name = name + "_io",
        src = ":" + name + "_floorplan",
    )

    librelane_global_placement(
        name = name + "_gpl",
        src = ":" + name + "_io",
        target_density = target_density,
    )

    # Macro placement (for hierarchical designs with hard macros)
    # Must come after global placement to have initial macro positions
    if macros:
        librelane_macro_placement(
            name = name + "_mpl",
            src = ":" + name + "_gpl",
        )
        dpl_src = ":" + name + "_mpl"
    else:
        dpl_src = ":" + name + "_gpl"

    librelane_detailed_placement(
        name = name + "_dpl",
        src = dpl_src,
    )

    # CTS
    librelane_cts(
        name = name + "_cts",
        src = ":" + name + "_dpl",
    )

    # Routing
    librelane_global_routing(
        name = name + "_grt",
        src = ":" + name + "_cts",
    )

    librelane_detailed_routing(
        name = name + "_drt",
        src = ":" + name + "_grt",
    )

    # Parasitic extraction
    librelane_rcx(
        name = name + "_rcx",
        src = ":" + name + "_drt",
    )

    # Final STA
    librelane_sta_post_pnr(
        name = name + "_sta",
        src = ":" + name + "_rcx",
    )


def librelane_hard_macro(
    name,
    verilog_files,
    top,
    pdk,
    clock_period = "10.0",
    clock_port = "clock",
    core_utilization = "40",
    target_density = "0.5",
    macros = []):
    """Complete flow from Verilog to hard macro (GDS + LEF).

    Args:
        name: Base name for all targets
        verilog_files: List of Verilog source files
        top: Top module name
        pdk: PDK target
        clock_period: Clock period in ns
        clock_port: Clock port name
        core_utilization: Target core utilization (0-100)
        target_density: Target placement density (0.0-1.0)
        macros: List of hard macro targets (for hierarchical designs)
    """

    # Run the full flow first
    librelane_full_flow(
        name = name,
        verilog_files = verilog_files,
        top = top,
        pdk = pdk,
        clock_period = clock_period,
        clock_port = clock_port,
        core_utilization = core_utilization,
        target_density = target_density,
        macros = macros,
    )

    # Fill insertion
    librelane_fill(
        name = name + "_fill",
        src = ":" + name + "_drt",
    )

    # GDS generation
    librelane_gds(
        name = name + "_gds",
        src = ":" + name + "_fill",
    )

    # LEF generation (provides MacroInfo for hierarchical use)
    librelane_lef(
        name = name + "_lef",
        src = ":" + name + "_gds",
    )
