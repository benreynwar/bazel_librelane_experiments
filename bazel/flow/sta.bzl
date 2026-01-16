# Static Timing Analysis rules

load(":providers.bzl", "LibrelaneInfo", "PdkInfo")

def _sta_mid_pnr_impl(ctx):
    src_info = ctx.attr.src[LibrelaneInfo]
    pdk_info = ctx.attr.src[PdkInfo]

    step_dir = ctx.actions.declare_directory(ctx.label.name)

    # Netlist is copied forward from previous step
    netlist_path = src_info.step_dir.path + "/" + src_info.top + ".nl.v"

    config_dict = {
        "DESIGN_NAME": src_info.top,
        "VERILOG_FILES": [netlist_path],
        "CLOCK_PORT": src_info.clock_port,
        "CLOCK_PERIOD": float(src_info.clock_period),
    }

    config = ctx.actions.declare_file(ctx.label.name + "_config.json")
    ctx.actions.write(output = config, content = json.encode(config_dict))

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
                --only OpenROAD.STAMidPNR \
                {config}

            # Copy design files from prev_step first
            cp {prev_step}/*.nl.v {prev_step}/*.pnl.v {prev_step}/*.def {prev_step}/*.odb {prev_step}/*.sdc {output}/ 2>/dev/null || true

            # Move STA outputs (reports are in corner subdirectories)
            mv {output}/runs/bazel/01-openroad-stamidpnr/* {output}/
            rm -r {output}/runs

            # Rewrite state to use placeholder
            sed 's|"[^"]*runs/bazel/01-openroad-stamidpnr/|"__PREV_STEP__/|g; s|{prev_step}/|__PREV_STEP__/|g' {output}/state_out.json > {output}/state_out.tmp && mv {output}/state_out.tmp {output}/state_out.json
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
            step = "OpenROAD.STAMidPNR",
            step_dir = step_dir,
            netlist_path = src_info.netlist_path,
            top = src_info.top,
            clock_port = src_info.clock_port,
            clock_period = src_info.clock_period,
        ),
        pdk_info,
    ]

_common_attrs = {
    "src": attr.label(
        mandatory = True,
        providers = [LibrelaneInfo, PdkInfo],
    ),
}

librelane_sta_mid_pnr = rule(
    implementation = _sta_mid_pnr_impl,
    attrs = _common_attrs,
    provides = [DefaultInfo, LibrelaneInfo, PdkInfo],
)
