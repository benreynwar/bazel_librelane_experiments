# Placement rules - one step at a time

load(":providers.bzl", "LibrelaneInfo", "PdkInfo")

def _single_step_impl(ctx, step_id, step_slug):
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
    if hasattr(ctx.attr, "target_density") and ctx.attr.target_density:
        config_dict["PL_TARGET_DENSITY_PCT"] = int(float(ctx.attr.target_density) * 100)

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
                --only {step_id} \
                {config}

            # Copy design files from prev_step first (will be overwritten by new outputs)
            cp {prev_step}/*.nl.v {prev_step}/*.pnl.v {prev_step}/*.def {prev_step}/*.odb {prev_step}/*.sdc {output}/ 2>/dev/null || true

            # Move new outputs (overwrites copied files where step produced new versions)
            mv {output}/runs/bazel/01-{step_slug}/* {output}/
            rm -r {output}/runs

            # Rewrite state to use placeholder (strips all path prefixes)
            sed 's|"[^"]*runs/bazel/01-{step_slug}/|"__PREV_STEP__/|g; s|{prev_step}/|__PREV_STEP__/|g' {output}/state_out.json > {output}/state_out.tmp && mv {output}/state_out.tmp {output}/state_out.json
        """.format(
            pdk = pdk_info.name,
            scl = pdk_info.scl,
            config = config.path,
            state_in = src_info.step_dir.path + "/state_out.json",
            prev_step = src_info.step_dir.path,
            output = step_dir.path,
            step_id = step_id,
            step_slug = step_slug,
        ),
        use_default_shell_env = True,
    )

    return [
        DefaultInfo(files = depset([step_dir])),
        LibrelaneInfo(
            step = step_id,
            step_dir = step_dir,
            netlist_path = step_dir.path + "/" + src_info.top + ".nl.v",
            top = src_info.top,
            clock_port = src_info.clock_port,
            clock_period = src_info.clock_period,
        ),
        pdk_info,
    ]

def _io_placement_impl(ctx):
    return _single_step_impl(ctx, "OpenROAD.IOPlacement", "openroad-ioplacement")

def _global_placement_impl(ctx):
    return _single_step_impl(ctx, "OpenROAD.GlobalPlacement", "openroad-globalplacement")

def _detailed_placement_impl(ctx):
    return _single_step_impl(ctx, "OpenROAD.DetailedPlacement", "openroad-detailedplacement")

def _cts_impl(ctx):
    return _single_step_impl(ctx, "OpenROAD.CTS", "openroad-cts")

_common_attrs = {
    "src": attr.label(
        mandatory = True,
        providers = [LibrelaneInfo, PdkInfo],
    ),
    "target_density": attr.string(),
}

librelane_io_placement = rule(
    implementation = _io_placement_impl,
    attrs = _common_attrs,
    provides = [DefaultInfo, LibrelaneInfo, PdkInfo],
)

librelane_global_placement = rule(
    implementation = _global_placement_impl,
    attrs = _common_attrs,
    provides = [DefaultInfo, LibrelaneInfo, PdkInfo],
)

librelane_detailed_placement = rule(
    implementation = _detailed_placement_impl,
    attrs = _common_attrs,
    provides = [DefaultInfo, LibrelaneInfo, PdkInfo],
)

librelane_cts = rule(
    implementation = _cts_impl,
    attrs = _common_attrs,
    provides = [DefaultInfo, LibrelaneInfo, PdkInfo],
)
