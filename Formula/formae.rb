class Formae < Formula
  desc "Infrastructure-as-Code platform built for the future"
  homepage "https://platform.engineering/formae"
  version "0.83.1"
  license "FSL-1.1-ALv2"

  depends_on :macos
  depends_on arch: :arm64

  url "https://hub.platform.engineering/binaries/pkgs/formae@#{version}_darwin-arm64.tgz"
  sha256 "55fccccfb4bd92ca7ede5017b65b5bf557954abc148372a11307da81fa9ad9da"

  def install
    # Install the real binary to libexec
    libexec.install "bin/formae" => "formae-bin"
    bin.install "bin/pkl"

    # Install plugins and examples to libexec
    libexec.install "plugins" if File.exist?("plugins")
    libexec.install "resource-plugins" if File.exist?("resource-plugins")
    libexec.install "examples" if File.exist?("examples")

    # Create wrapper script that sets up plugins on first run
    (bin/"formae").write <<~SH
      #!/bin/bash
      PLUGIN_DIR="$HOME/.pel/formae/plugins"
      LIBEXEC="#{opt_libexec}"
      SETUP_MARKER="$PLUGIN_DIR/.homebrew-setup-v#{version}"

      # Setup plugins on first run (or after upgrade)
      if [ ! -f "$SETUP_MARKER" ]; then
        mkdir -p "$PLUGIN_DIR"

        # Copy plugins
        if [ -d "$LIBEXEC/plugins" ]; then
          for f in "$LIBEXEC/plugins"/*; do
            if [ -f "$f" ] && [ -x "$f" ]; then
              name=$(basename "$f")
              dest="$PLUGIN_DIR/$name/v#{version}"
              mkdir -p "$dest"
              cp "$f" "$dest/"
            fi
          done
        fi

        # Copy resource plugins
        if [ -d "$LIBEXEC/resource-plugins" ]; then
          for namespace_dir in "$LIBEXEC/resource-plugins"/*; do
            if [ -d "$namespace_dir" ]; then
              namespace=$(basename "$namespace_dir")
              for version_dir in "$namespace_dir"/*; do
                if [ -d "$version_dir" ]; then
                  ver=$(basename "$version_dir")
                  dest="$PLUGIN_DIR/$namespace/$ver"
                  mkdir -p "$dest"
                  cp -r "$version_dir"/. "$dest/"
                fi
              done
            fi
          done
        fi

        touch "$SETUP_MARKER"
      fi

      exec "$LIBEXEC/formae-bin" "$@"
    SH

    # Generate shell completions
    generate_completions_from_executable(libexec/"formae-bin", "completion", base_name: "formae")
  end

  def caveats
    <<~EOS
      Plugins will be automatically installed to ~/.pel/formae/plugins
      on first run.

      To get started with Formae:
        formae agent start
        formae apply --mode reconcile --watch
        formae inventory resources

      Documentation: https://docs.formae.io
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/formae --version")
  end
end
