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
    # Use Ruby's FileUtils instead of system commands to avoid sandbox restrictions
    plugin_dir = Pathname.new(Dir.home)/".pel"/"formae"/"plugins"
    FileUtils.mkdir_p(plugin_dir)

    # Copy plugins to user directory
    plugin_src = libexec/"plugins"
    if plugin_src.exist?
      plugin_src.children.each do |f|
        if f.file? && f.executable?
          dest = plugin_dir/f.basename.to_s/"v#{version}"
          FileUtils.mkdir_p(dest)
          FileUtils.cp(f, dest)
        end
      end
    end

    # Copy resource plugins
    resource_src = libexec/"resource-plugins"
    if resource_src.exist?
      resource_src.children.select(&:directory?).each do |namespace_dir|
        namespace = namespace_dir.basename.to_s
        namespace_dir.children.select(&:directory?).each do |version_dir|
          ver = version_dir.basename.to_s
          dest = plugin_dir/namespace/ver
          FileUtils.mkdir_p(dest)
          FileUtils.cp_r(version_dir.children, dest)
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
