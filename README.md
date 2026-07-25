# rustBench - Heavy Rust Development Environment

`rustBench` is the workBenches development environment for native Rust,
Tauri desktop applications, services, command-line tools, embedded
foundations, WebAssembly, and cross-platform crates.

## Container architecture

- **Layer 0:** `workbench-base:latest`
- **Layer 1a:** `dev-bench-base:latest`
- **Layer 2:** `rust-bench:latest` (Rust-specific, user-agnostic)
- **Layer 3:** `rust-bench:{user}` (personalized user image)

The root [`Dockerfile.layer2`](Dockerfile.layer2) is the source of truth. The
devcontainer starts the Layer 3 image and mounts the shared workBenches
credentials and project directories.

## Included Rust environment

### Official toolchains and components

- Current stable and nightly toolchains via `rustup`
- `rustc`, Cargo, Rustdoc, rustfmt, Clippy, rust-analyzer, Rust source, and
  LLVM tools
- Miri on nightly
- GNU Linux, musl, WebAssembly, WASI Preview 1, and AArch64 targets

### Build, test, and quality

- `cargo-nextest`, `cargo-watch`, `bacon`, `watchexec`, `just`
- `cargo-llvm-cov`, `cargo-tarpaulin`, `cargo-mutants`, `cargo-insta`
- `cargo-audit`, `cargo-deny`, `cargo-machete`, `cargo-vet`
- `cargo-hack`, `cargo-semver-checks`, `cargo-msrv`, `cargo-outdated`
- `cargo-expand`, `cargo-bloat`, `cargo-show-asm`, `cargo-flamegraph`
- `sccache`, mold, LLDB, GDB, Valgrind, heaptrack, and Linux perf tools

### Packaging, cross-platform, and WebAssembly

- `cross`, `cargo-zigbuild`, `cargo-release`, and `cargo-generate`
- `wasm-pack`, `wasm-bindgen-cli`, `trunk`, Binaryen, and WABT
- `cargo-about`, `cargo-license`, `cargo-sbom`, and `cargo-cyclonedx`
- Protocol Buffers, CMake, Ninja, Clang/LLVM, musl, and AArch64 build tools
- Tauri v2 Linux prerequisites, including WebKitGTK 4.1, GTK 3,
  AppIndicator, XDO, and librsvg development libraries

Cargo downloads and source builds use the current user's writable
`$HOME/.cargo` cache. Shared preinstalled Rust tools remain available from
`/opt/rust/cargo/bin`.

### Tauri desktop applications

On Windows/WSL, rustBench forwards the WSLg display, Wayland, and PulseAudio
sockets into the container and uses Mesa software rendering for predictable
WebKitGTK behavior without exposing a host GPU device. Start a Tauri
application from its project directory:

```bash
pnpm install
pnpm tauri dev
```

The application window opens on the Windows desktop. WSLg must be available at
`/mnt/wslg`; standard native Linux Docker hosts can supply equivalent display
socket mounts and environment variables in a local Compose override.

## Build and launch

From this directory:

```bash
./scripts/build-layer.sh --user "$(whoami)"
code .
```

To build only the user-agnostic Layer 2 image:

```bash
./scripts/build-layer2.sh --user "$(whoami)"
```

The root workBenches cascade build also auto-discovers this bench:

```bash
../../scripts/update-and-rebuild.sh --layer 1a --cascade --user "$(whoami)"
```

## Create a project

Inside the bench:

```bash
new-rust-project my-service
new-rust-project --lib my-library
```

Or call the repository script directly:

```bash
./scripts/new-rust-project.sh my-service
```

## Common commands

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo nextest run --workspace --all-features
cargo llvm-cov --workspace --all-features
cargo audit
cargo deny check
cargo +nightly miri test
```

For SonarQube Cloud/Server coverage import, run
`sonarcloud-rust-coverage`. It generates LCOV with `cargo llvm-cov`, loads the
shared Sonar credentials without printing them, and invokes `sonar-scanner`.

## License

Apache-2.0. See [`LICENSE`](LICENSE).
