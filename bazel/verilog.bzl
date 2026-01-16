# Verilog generation utilities

def generate_verilog_rule(name, generator_tool, top, config = None):
    """
    Generate Verilog by running a Chisel generator.

    Args:
        name: Name for the target, output file ({name}.sv), and resulting Verilog module
        generator_tool: Chisel binary that generates Verilog
        top: The top-level module name that Chisel generates (will be renamed to name)
        config: Config file label (e.g. //configs:adder_default.json)
    """
    output_name = "{}.sv".format(name)

    if config:
        cmd = """
    TMPDIR=$$(mktemp -d)
    $(location {generator_tool}) $$TMPDIR $(location {config})
    cat $$TMPDIR/*.sv | sed 's/^module {top}(/module {name}(/' > $@
    rm -rf $$TMPDIR
    """.format(
            generator_tool = generator_tool,
            config = config,
            top = top,
            name = name,
        )
        srcs = [config]
    else:
        cmd = """
    TMPDIR=$$(mktemp -d)
    $(location {generator_tool}) $$TMPDIR
    cat $$TMPDIR/*.sv | sed 's/^module {top}(/module {name}(/' > $@
    rm -rf $$TMPDIR
    """.format(
            generator_tool = generator_tool,
            top = top,
            name = name,
        )
        srcs = []

    native.genrule(
        name = name,
        srcs = srcs,
        outs = [output_name],
        cmd = cmd,
        tools = [generator_tool],
    )
