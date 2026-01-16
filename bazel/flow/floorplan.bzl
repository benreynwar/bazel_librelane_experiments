# Floorplan rule wrapping librelane OpenROAD.Floorplan step

load(":providers.bzl", "LibrelaneInfo", "PdkInfo")

def _floorplan_impl(ctx):
    src_info = ctx.attr.src[LibrelaneInfo]
    pdk_info = ctx.attr.src[PdkInfo]

    step_dir = ctx.actions.declare_directory(ctx.label.name + "_floorplan")

    # Build config with floorplan settings
    config_dict = {
        "DESIGN_NAME": src_info.top,
        "VERILOG_FILES": [src_info.step_dir.path + "/01-yosys-synthesis/" + src_info.top + ".nl.v"],
        "CLOCK_PORT": src_info.clock_port,
        "CLOCK_PERIOD": float(src_info.clock_period),
    }
    if ctx.attr.die_area:
        config_dict["DIE_AREA"] = ctx.attr.die_area
    if ctx.attr.core_area:
        config_dict["CORE_AREA"] = ctx.attr.core_area
    if ctx.attr.core_utilization:
        config_dict["FP_CORE_UTIL"] = int(ctx.attr.core_utilization)

    config_content = json.encode(config_dict)

    config = ctx.actions.declare_file(ctx.label.name + "_config.json")
    ctx.actions.write(output = config, content = config_content)

    ctx.actions.run_shell(
        outputs = [step_dir],
        inputs = [src_info.step_dir, config],
        command = """
            mkdir -p {output}

            # Replace placeholder with actual input path
            sed 's|__PREV_STEP__|{prev_step}|g' {state_in} > {output}/input_state.json

            librelane \
                --manual-pdk \
                --pdk-root "$PDK_ROOT" \
                --pdk {pdk} \
                --scl {scl} \
                --design-dir {output} \
                --run-tag bazel \
                -i {output}/input_state.json \
                --only OpenROAD.Floorplan \
                {config}

            mv {output}/runs/bazel/01-openroad-floorplan/* {output}/
            rm -r {output}/runs

            # Rewrite state to use placeholder (strips all path prefixes)
            sed 's|"[^"]*runs/bazel/01-openroad-floorplan/|"__PREV_STEP__/|g; s|{prev_step}/|__PREV_STEP__/|g' {output}/state_out.json > {output}/state_out.tmp && mv {output}/state_out.tmp {output}/state_out.json

            # Copy netlist forward for subsequent steps
            cp {prev_step}/01-yosys-synthesis/*.nl.v {output}/
        """.format(
            pdk = pdk_info.name,
            scl = pdk_info.scl,
            config = config.path,
            state_in = src_info.step_dir.path + "/state_out.json",
            prev_step = src_info.step_dir.path,
            output = step_dir.path,
        ),
        use_default_shell_env = True,
    )

    return [
        DefaultInfo(files = depset([step_dir])),
        LibrelaneInfo(
            step = "OpenROAD.Floorplan",
            step_dir = step_dir,
            netlist_path = step_dir.path + "/" + src_info.top + ".nl.v",
            top = src_info.top,
            clock_port = src_info.clock_port,
            clock_period = src_info.clock_period,
        ),
        pdk_info,
    ]

librelane_floorplan = rule(
    implementation = _floorplan_impl,
    attrs = {
        "src": attr.label(
            doc = "Source stage (synthesis)",
            mandatory = True,
            providers = [LibrelaneInfo, PdkInfo],
        ),
        "die_area": attr.string(doc = "Die area as 'x0 y0 x1 y1' in microns"),
        "core_area": attr.string(doc = "Core area as 'x0 y0 x1 y1' in microns"),
        "core_utilization": attr.string(doc = "Target core utilization (0-100)"),
    },
    provides = [DefaultInfo, LibrelaneInfo, PdkInfo],
)
