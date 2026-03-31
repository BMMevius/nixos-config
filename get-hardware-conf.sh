#!/usr/bin/env bash
set -e

mountpoint=""
host=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	-m | --mountpoint)
		mountpoint="$2"
		shift 2
		;;
	-h | --host)
		host="$2"
		shift 2
		;;
	*)
		echo "Usage: $0 --mountpoint <path> --host <name>"
		exit 1
		;;
	esac
done

if [[ -z "$mountpoint" ]]; then
	echo "Error: --mountpoint is required"
	exit 1
fi

if [[ -z "$host" ]]; then
	echo "Error: --host is required"
	exit 1
fi

nixos-generate-config --root "$mountpoint"
cp "$mountpoint/etc/nixos/hardware-configuration.nix" ./hosts/"$host"/hardware-configuration.nix
