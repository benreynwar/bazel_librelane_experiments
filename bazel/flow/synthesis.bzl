# Synthesis rule wrapping librelane Yosys.Synthesis step

load(":providers.bzl", "LibrelaneInfo", "PdkInfo")

def _synthesis_impl(ctx):
    step_dir = ctx.actions.declare_directory(ctx.label.name + "_synth")

    pdk_info = ctx.attr.pdk[PdkInfo]
    verilog_files = [f.path for f in ctx.files.verilog_files]

    config_content = json.encode({
        "DESIGN_NAME": ctx.attr.top,
        "CLOCK_PERIOD": float(ctx.attr.clock_period),
        "CLOCK_PORT": ctx.attr.clock_port,
        "VERILOG_FILES": verilog_files,
    })

    config = ctx.actions.declare_file(ctx.label.name + "_config.json")
    ctx.actions.write(
        output = config,
        content = config_content,
    )

    # Use --design-dir to control where runs/ is created
    ctx.actions.run_shell(
        outputs = [step_dir],
        inputs = ctx.files.verilog_files + [config],
        command = """
            mkdir -p {output}
            librelane \
                --manual-pdk \
                --pdk-root "$PDK_ROOT" \
                --pdk {pdk} \
                --scl {scl} \
                --design-dir {output} \
                --run-tag bazel \
                --only Yosys.Synthesis \
                {config}

            mv {output}/runs/bazel/* {output}/
            rmdir {output}/runs/bazel {output}/runs

            # Rewrite absolute paths in state_out.json with placeholder
            sed 's|"[^"]*runs/bazel/|"__PREV_STEP__/|g' {output}/01-yosys-synthesis/state_out.json > {output}/state_out.json
        """.format(
            pdk = pdk_info.name,
            scl = pdk_info.scl,
            config = config.path,
            output = step_dir.path,
        ),
        use_default_shell_env = True,
    )

    netlist_path = step_dir.path + "/final/nl/" + ctx.attr.top + ".nl.v"

    return [
        DefaultInfo(files = depset([step_dir])),
        LibrelaneInfo(
            step = "Yosys.Synthesis",
            step_dir = step_dir,
            netlist_path = netlist_path,
            top = ctx.attr.top,
            clock_port = ctx.attr.clock_port,
            clock_period = ctx.attr.clock_period,
        ),
        pdk_info,
    ]

librelane_synthesis = rule(
    implementation = _synthesis_impl,
    attrs = {
        "verilog_files": attr.label_list(
            doc = "Verilog/SystemVerilog source files",
            allow_files = [".v", ".sv"],
            mandatory = True,
        ),
        "top": attr.string(
            doc = "Top module name",
            mandatory = True,
        ),
        "clock_period": attr.string(
            doc = "Clock period in nanoseconds",
            default = "10.0",
        ),
        "clock_port": attr.string(
            doc = "Clock port name",
            default = "clk",
        ),
        "pdk": attr.label(
            doc = "PDK target providing PdkInfo",
            mandatory = True,
            providers = [PdkInfo],
        ),
    },
    provides = [DefaultInfo, LibrelaneInfo, PdkInfo],
)
