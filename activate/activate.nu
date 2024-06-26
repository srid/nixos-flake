use std log
use nixos-flake.nu getData  # This module is generated in Nix

let CURRENT_HOSTNAME = (hostname | str trim)

# Activate system configuration of local machine
#
# To activate a remote machine, use run with subcommands: `host <hostname>`
def main [] {
    main host ($CURRENT_HOSTNAME)
}

# Activate system configuration of the given host
def 'main host' [
  host: string # Hostname to activate (must match flake.nix name)
] {
    let data = getData
    if $host not-in $data.nixos-flake-configs {
        log error $"Host '($host)' not found in flake. Available hosts=($data.nixos-flake-configs | columns)"
        exit 1
    }
    let hostData = $data.nixos-flake-configs 
        | get $host
        | insert "flake" $"($data.cleanFlake)#($host)"

    log info $"(ansi grey)currentSystem=($data.system) currentHost=(ansi green_bold)($CURRENT_HOSTNAME)(ansi grey) targetHost=(ansi green_reverse)($host)(ansi reset)(ansi grey) hostData=($hostData)(ansi reset)"

    let runtime = {
        local: ($CURRENT_HOSTNAME == $host)
        darwin: ($hostData.outputs.system in ["aarch64-darwin" "x86_64-darwin"])
    }

    if $runtime.local {
        # Since the user asked to activate current host, do so.
        log info $"Activating (ansi purple)locally(ansi reset)"
        if $runtime.darwin {
            log info $"(ansi blue_bold)>>>(ansi reset) darwin-rebuild switch --flake ($hostData.flake) ($hostData.outputs.nixArgs | str join)"
            darwin-rebuild switch --flake $hostData.flake ...$hostData.outputs.nixArgs 
        } else {
            log info $"(ansi blue_bold)>>>(ansi reset) nixos-rebuild switch --flake ($hostData.flake) ($hostData.outputs.nixArgs | str join) --use-remote-sudo "
            nixos-rebuild switch --flake $hostData.flake ...$hostData.outputs.nixArgs --use-remote-sudo
        }
    } else {
        # Remote activation request, so copy the flake and the necessary inputs
        # and then activate over SSH.
        if $hostData.sshTarget == null {
            log error $"sshTarget not found in host data for ($host). Add `nixos-flake.sshTarget = \"user@hostname\";` to your configuration."
            exit 1
        }
        log info $"Activating (ansi purple_reverse)remotely(ansi reset) on ($hostData.sshTarget)"
        nix copy ($data.cleanFlake) --to ($"ssh-ng://($hostData.sshTarget)")

        $hostData.outputs.overrideInputs | transpose key value | each { |input|
            log info $"Copying input ($input.key) to ($hostData.sshTarget)"
            log info $"(ansi blue_bold)>>>(ansi reset) nix copy ($input.value) --to ($"ssh-ng://($hostData.sshTarget)")"
            nix copy ($input.value) --to ($"ssh-ng://($hostData.sshTarget)")
        }

        # We re-run this script, but on the remote host.
        log info $'(ansi blue_bold)>>>(ansi reset) ssh -t ($hostData.sshTarget) nix --extra-experimental-features '"nix-command flakes"' run ($hostData.outputs.nixArgs | str join) $"($data.cleanFlake)#activate" host ($host)'
        ssh -t $hostData.sshTarget nix --extra-experimental-features '"nix-command flakes"' run ...$hostData.outputs.nixArgs $"($data.cleanFlake)#activate host ($host)"
    }
}

# TODO: Implement this, resolving https://github.com/srid/nixos-flake/issues/18
def 'main home' [] {
    log error "Home activation not yet supported; use .#activate-home instead"
    exit 1
}

