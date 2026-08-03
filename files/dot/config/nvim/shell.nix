{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    lua-language-server
    perlnavigator
    rustup
    typescript
    clang-tools
  ];


  shellHook = ''
    silent_which() {
        which 2>/dev/null "$@"
    }
    DATA_DIR="$HOME/.local/share/nvim"
    #DATA_DIR="$("$(silent_which nvim)" --headless -c 'echo stdpath("data")' -c 'qa' 2>&1)"
    MASON_DIR="$DATA_DIR/mason"
    LUA_BIN="$(silent_which lua-language-server)"
    PERL_BIN="$(silent_which perlnavigator)"
    RUST_BIN="$(silent_which rust-analyzer)"
    TSS_BIN="$(silent_which tsserver)"

    [[ -n "$LUA_BIN" ]] && ln -sf "$LUA_BIN" "$MASON_DIR/bin/lua-language-server"
    [[ -n "$PERL_BIN" ]] && ln -sf "$PERL_BIN" "$MASON_DIR/bin/perlnavigator"
    [[ -n "$RUST_BIN" ]] && ln -sf "$RUST_BIN" "$MASON_DIR/bin/rust-analyzer"
    [[ -n "$TSS_BIN" ]] && ln -sf "$TSS_BIN" "$MASON_DIR/bin/tsserver"

    export RA_LOG=rust_analyzer=debug
    export NVIM_LOG_FILE="$HOME/nvim.log"
    export NVIM_LOG_LEVEL="debug"
  '';
}
