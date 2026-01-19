This is a project where I'm experimenting with using nix, bazel and librelane.

Nix is setting up the environment.
Bazel is taking care of building.
librelane.steps is being used for build steps 

Currently the main example is building an 4-input adder our of 2-input adder hard macros.

The following builds the adder using auto placement, and then using manual placement.

```
nix-shell
bazel build //dse:FourInputAdder_auto_sta
bazel build //dse:FourInputAdder_manual_sta
```

This project is pretty AI sloppy, so don't use it as a template.  
