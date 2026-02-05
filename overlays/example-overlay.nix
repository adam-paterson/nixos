# Example Custom Overlay
# See: .agents/skills/nixos-best-practices/rules/overlay-scope.md
#
# IMPORTANT: To use this overlay, add it to your host's default.nix:
#   nixpkgs.overlays = [ (import ../overlays/example-overlay.nix) ];
#
# CRITICAL: With useGlobalPkgs = true, overlays MUST be defined in the host
# configuration (default.nix), NOT in home.nix!

final: prev: {
  # ============================================================================
  # Example 1: Add a custom script
  # ============================================================================
  
  my-hello-script = prev.writeShellScriptBin "my-hello-script" ''
    #!/usr/bin/env bash
    echo "Hello from a custom overlay script!"
    echo "This demonstrates how to add custom packages via overlays."
  '';

  # ============================================================================
  # Example 2: Modify an existing package
  # ============================================================================
  
  # Uncomment to override the hello package with a custom message
  # hello = prev.hello.overrideAttrs (oldAttrs: {
  #   postInstall = ''
  #     ${oldAttrs.postInstall or ""}
  #     echo "Modified by overlay!" > $out/share/hello-overlay-info
  #   '';
  # });

  # ============================================================================
  # Example 3: Add a custom package from source
  # ============================================================================
  
  # my-custom-package = prev.stdenv.mkDerivation {
  #   pname = "my-custom-package";
  #   version = "1.0.0";
  #   
  #   src = prev.fetchFromGitHub {
  #     owner = "username";
  #     repo = "my-custom-package";
  #     rev = "v1.0.0";
  #     sha256 = "0000000000000000000000000000000000000000000000000000";
  #   };
  #   
  #   buildInputs = [ ];
  #   
  #   installPhase = ''
  #     mkdir -p $out/bin
  #     cp my-binary $out/bin/
  #   '';
  # };

  # ============================================================================
  # Example 4: Package with custom patches
  # ============================================================================
  
  # patched-package = prev.somePackage.overrideAttrs (oldAttrs: {
  #   patches = (oldAttrs.patches or []) ++ [
  #     ./patches/my-custom.patch
  #   ];
  # });

  # ============================================================================
  # Example 5: Wrapper script for existing package
  # ============================================================================
  
  # vim-with-config = prev.symlinkJoin {
  #   name = "vim-with-config";
  #   paths = [ prev.vim ];
  #   buildInputs = [ prev.makeWrapper ];
  #   postBuild = ''
  #     wrapProgram $out/bin/vim \
  #       --add-flags "-u ${./vimrc}"
  #   '';
  # };
}
