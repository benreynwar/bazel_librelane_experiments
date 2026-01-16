# Use librelane's flake via flake-compat
let
  librelane-flake = (import (fetchTarball
    "https://github.com/edolstra/flake-compat/archive/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9.tar.gz"
  ) { src = builtins.fetchGit {
    url = "https://github.com/librelane/librelane";
    ref = "main";
  }; }).defaultNix;

  pkgs = librelane-flake.legacyPackages.${builtins.currentSystem};
  sky130-pdk = import ./nix/sky130.nix;
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Chisel/Scala
    jdk21
    circt
    scala-cli

    # EDA tools (from librelane's overlay)
    openroad
    yosys
    magic-vlsi
    verilator
    klayout
    python3.pkgs.librelane

    # Build tools
    bazel_7
    python313
    git
  ];

  PDK_ROOT = sky130-pdk;
  PDK = "sky130A";

  shellHook = ''
    echo "Hardware Example Development Environment"
    echo "  OpenROAD: $(openroad -version 2>/dev/null | head -1 || echo 'available')"
    echo "  Yosys:    $(yosys -V 2>/dev/null | head -1 || echo 'available')"
    echo "  Bazel:    $(bazel --version 2>/dev/null | head -1 || echo 'available')"
    echo "  PDK_ROOT: $PDK_ROOT"
    echo "  PDK:      $PDK"
    echo ""
  '';
}
