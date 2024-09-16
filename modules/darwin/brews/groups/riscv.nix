{
  homebrew.taps = [
    "riscv-software-src/riscv"
  ];

  homebrew.brews = [
    "gawk"
    "gnu-sed"
    "gmp"
    "mpfr"
    "libmpc"
    "isl"
    "zlib"
    "expat"
    "texinfo"
    "flock"
    "libslirp"

    "riscv-tools" # From tap
  ];
}
