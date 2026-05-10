class Ticketfairy < Formula
  desc "Ticket Fairy command-line interface"
  homepage "https://github.com/theticketfairy/ticketfairy-cli"
  version "0.0.0"
  license "MIT"

  # Placeholder formula. The first `vX.Y.Z` tag pushed to
  # theticketfairy/ticketfairy-cli triggers the release workflow,
  # which runs `scripts/update-formula.sh` and replaces this file
  # with one whose URLs + sha256 hashes point at the real release
  # tarballs. Until then `brew install theticketfairy/tap/ticketfairy`
  # will fail with a clear "no release published yet" error rather
  # than installing nothing silently.
  on_macos do
    on_arm do
      url "https://github.com/theticketfairy/ticketfairy-cli/releases/download/v0.0.0/ticketfairy-v0.0.0-darwin-arm64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://github.com/theticketfairy/ticketfairy-cli/releases/download/v0.0.0/ticketfairy-v0.0.0-darwin-x64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/theticketfairy/ticketfairy-cli/releases/download/v0.0.0/ticketfairy-v0.0.0-linux-arm64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://github.com/theticketfairy/ticketfairy-cli/releases/download/v0.0.0/ticketfairy-v0.0.0-linux-x64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/ticketfairy"
  end

  test do
    assert_match "@theticketfairy/cli", shell_output("#{bin}/ticketfairy --version")
  end
end
