#!/usr/bin/env bash
set -e

password=""
host=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	-p | --password)
		password="$2"
		shift 2
		;;
	-h | --host)
		host="$2"
		shift 2
		;;
	*)
		echo "Usage: $0 --password <password> --host <name>"
		exit 1
		;;
	esac
done

if [[ -z "$password" ]]; then
	echo "Error: --password is required"
	exit 1
fi

if [[ -z "$host" ]]; then
	echo "Error: --host is required"
	exit 1
fi

# 1. Boot NixOS installer
# 2. Set up the LUKS password file
echo -n "$password" > /tmp/secret.key
# 3. Run disko to partition/format/mount
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount "./hosts/$host/disko.nix"
# 4. Install
sudo nixos-install --flake ".#$host"