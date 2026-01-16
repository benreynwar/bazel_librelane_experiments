load("//bazel:chisel.bzl", "chisel_binary")

filegroup(
    name = "sources",
    srcs = glob(["*.scala"]),
    visibility = ["//visibility:public"],
)

DEPS = [
    "@maven//:io_circe_circe_core_2_13",
    "@maven//:io_circe_circe_generic_2_13",
    "@maven//:io_circe_circe_parser_2_13",
    "@maven//:org_typelevel_cats_core_2_13",
    "@maven//:org_typelevel_cats_kernel_2_13",
    "@maven//:com_chuusai_shapeless_2_13",
]

chisel_binary(
    name = "adder",
    srcs = [":sources"],
    main_class = "hwexample.AdderMain",
    deps = DEPS,
    visibility = ["//visibility:public"],
)
