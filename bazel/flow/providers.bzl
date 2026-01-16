# Providers for librelane flow stages

LibrelaneInfo = provider(
    doc = "State passed between librelane flow stages.",
    fields = {
        "step": "The step that produced this state (e.g., 'Yosys.Synthesis')",
        "step_dir": "The step output directory (TreeArtifact)",
        "netlist_path": "Path to Verilog netlist file (.nl.v)",
        "top": "Top module name",
        "clock_port": "Clock port name",
        "clock_period": "Clock period in nanoseconds",
    },
)

PdkInfo = provider(
    doc = "PDK information for the flow.",
    fields = {
        "name": "PDK name (e.g., 'sky130A')",
        "scl": "Standard cell library name",
    },
)
