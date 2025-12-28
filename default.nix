{ pkgs ? import <nixpkgs> {},
  pythonPkgs ? pkgs.python3Packages,
}:

let
  # ---------------------------------------------------------------------------
  # MAIN PACKAGE
  # ---------------------------------------------------------------------------
  killy = pythonPkgs.buildPythonApplication rec {
    pname = "killy";
    version = "0.1.0";

    # This tells nix where to find the package source root
    # It assumes a src/killy layout for the killy package
    src = ./.;

    pyproject = true;

    nativeBuildInputs = with pythonPkgs; [
      setuptools
      wheel
    ];

    propagatedBuildInputs = [
      pkgs.age
      pkgs.sops
      pythonPkgs.pyyaml
      pythonPkgs.click
    ];

    # Skip checks for now
    doCheck = false;

    meta = with pkgs.lib; {
      description = "Killy infrastructure bootstrap system";
      license = licenses.mit;
    };
  };

  # ---------------------------------------------------------------------------
  # MINIMAL SHELL (default nix-shell)
  # ---------------------------------------------------------------------------
  shell = pkgs.mkShell {
    buildInputs = [ killy ];
  };

  # ---------------------------------------------------------------------------
  # DEVELOPMENT SHELL (nix-shell -A devShell or nix-shell -A dev-shell)
  # ---------------------------------------------------------------------------
  devShell = pkgs.mkShell {
    buildInputs = [
      pkgs.age
      pkgs.sops
      pkgs.git
      pkgs.gh
      pkgs.zola
      pythonPkgs.pyyaml
      pythonPkgs.click
      pythonPkgs.pytest
    ];

    shellHook = ''
      old_opts=$(set +o)
      set -euo pipefail

      # Set up PYTHONPATH to include src directory for local development
      export PYTHONPATH=$PWD/src:''${PYTHONPATH:-}

      # Display environment info
      echo "Killy Development Environment"
      echo "=============================="
      echo "Python:  $(python --version)"
      echo "PyYAML:  $(python -c 'import yaml; print(yaml.__version__)' 2>/dev/null || echo 'not found')"
      echo "age:     $(age --version 2>&1 | head -n1)"
      echo "sops:    $(sops --version 2>&1 | head -n1)"
      echo ""
      echo "PYTHONPATH: $PYTHONPATH"
      echo ""
      echo "Available commands:"
      echo "  Setup:"
      echo "    - python -m killy.configure killy age            # Generate age key"
      echo ""
      echo "  Configure system:"
      echo "    - python -m killy.configure killy set-system     # Set hostname, timezone, etc."
      echo "    - python -m killy.configure killy add-wifi       # Add WiFi network"
      echo "    - python -m killy.configure killy add-user       # Add user account"
      echo "    - python -m killy.configure killy import-ssh-keys # Import SSH host keys"
      echo ""
      echo "  View:"
      echo "    - python -m killy.configure killy show           # Show config in clear"
      echo ""
      echo "  Build:"
      echo "    - python -m killy.configure killy make-iso       # Create bootable USB ISO"
      echo ""

      eval "$old_opts"
    '';
  };

in
{
  default = killy;
  killy = killy;
  shell = shell;
  devShell = devShell;
  dev-shell = devShell;  # alias for compatibility
}
