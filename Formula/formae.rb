class Formae < Formula
  desc "Infrastructure-as-Code platform built for the future"
  homepage "https://platform.engineering/formae"
  version "0.80.1"
  license "FSL-1.1-ALv2"

  depends_on :macos
  depends_on arch: :arm64

  url "https://hub.platform.engineering/binaries/pkgs/formae@#{version}_darwin-arm64.tgz"
  sha256 "98f18a20ccdaae9c8b041953650fdd7b8f80213d86ac166dd1047d459727c992"

  def install
    # Homebrew strips top-level formae/ directory
    bin.install "bin/formae"
    bin.install "bin/pkl"

    # Install plugins and examples to libexec
    libexec.install "plugins" if File.exist?("plugins")
    libexec.install "resource-plugins" if File.exist?("resource-plugins")
    libexec.install "examples" if File.exist?("examples")

    # Generate shell completions
    generate_completions_from_executable(bin/"formae", "completion")
  end

  def post_install
    # Create plugin directory in user home (same as official installer)
    plugin_dir = "#{ENV["HOME"]}/.pel/formae/plugins"
    system "mkdir", "-p", plugin_dir

    # Copy plugins to user directory
    plugin_src = libexec/"plugins"
    if plugin_src.exist?
      Dir.glob("#{plugin_src}/*").each do |f|
        if File.file?(f) && File.executable?(f)
          name = File.basename(f)
          dest = "#{plugin_dir}/#{name}/v#{version}"
          system "mkdir", "-p", dest
          system "cp", f, dest
        end
      end
    end

    # Copy resource plugins
    resource_src = libexec/"resource-plugins"
    if resource_src.exist?
      Dir.glob("#{resource_src}/*").each do |namespace_dir|
        if File.directory?(namespace_dir)
          namespace = File.basename(namespace_dir)
          Dir.glob("#{namespace_dir}/*").each do |version_dir|
            if File.directory?(version_dir)
              ver = File.basename(version_dir)
              dest = "#{plugin_dir}/#{namespace}/#{ver}"
              system "mkdir", "-p", dest
              system "cp", "-r", "#{version_dir}/.", dest
            end
          end
        end
      end
    end
  end

  def caveats
    <<~EOS
      Plugin directory created at:
        ~/.pel/formae/plugins

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
