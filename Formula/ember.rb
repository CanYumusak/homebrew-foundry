class Ember < Formula
  desc "Foundry local daemon, Forge CLI, and Forge web workbench"
  homepage "https://github.com/CanYumusak/foundry"
  url "https://github.com/CanYumusak/homebrew-foundry/releases/download/v0.1.0/foundry-cli-darwin-arm64.tar.gz"
  sha256 "6d7650039e984e3c9020108ec56f2c84c6e5cfad413399dc9bbe99f02e87b93d"
  license "MIT"

  depends_on "node"

  resource "forge-web" do
    url "https://github.com/CanYumusak/homebrew-foundry/releases/download/v0.1.0/foundry-forge-web-darwin-arm64.tar.gz"
    sha256 "29f42986b2c9f4a67d36748b386bf9031b541dc688157b1ad0f4dbedb94099d9"
  end

  def install
    bin.install Dir["cli/bin/*"]

    resource("forge-web").stage do
      libexec.install Dir["forge-web/*"]
    end

    bin.install_symlink libexec/"bin/forge-web" => "forge-web"

    (pkgshare/"com.foundry.forge-web.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>com.foundry.forge-web</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/forge-web</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>StandardOutPath</key>
        <string>/tmp/foundry-forge-web.log</string>
        <key>StandardErrorPath</key>
        <string>/tmp/foundry-forge-web.log</string>
      </dict>
      </plist>
    PLIST
  end

  service do
    run [opt_bin/"ember"]
    keep_alive true
    working_dir Dir.home
    log_path "/tmp/ember.log"
    error_log_path "/tmp/ember.log"
  end

  def caveats
    <<~EOS
      Start the daemon:
        brew services start ember

      Start the Forge web UI manually:
        forge-web

      Or install the optional launch agent template:
        cp #{pkgshare}/com.foundry.forge-web.plist ~/Library/LaunchAgents/
        launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.foundry.forge-web.plist

      Forge web defaults to:
        http://127.0.0.1:4000
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ember --version")
    assert_match version.to_s, shell_output("#{bin}/forge --version")
  end
end
