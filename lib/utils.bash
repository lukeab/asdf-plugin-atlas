#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/ariga/atlas"
DL_BASEURL="https://release.ariga.io/atlas"
TOOL_NAME="atlas"
TOOL_TEST="atlas version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if atlas is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# For now, by default we simply list the tag names from GitHub releases.
	# The releases download location listed in the official docs doesn't offer a list,
	# so use github to determine available versions for now.
	# TODO: we could verify the listed versions are actually available at some point
	list_github_tags
}

download_release() {
	
	local ATLAS_VERSION filename url
	ATLAS_VERSION="$([ $1 == "latest" ] && echo "$1" || echo "v${1}")"
	filename="$2"

	## ported considerable architecture detection code from: 
	# https://atlasgo.sh

	local _ostype _cputype _os
    _ostype="$(uname -s)"
    _cputype="$(uname -m)"

    if [ "$_ostype" = Darwin ] && [ "$_cputype" = i386 ]; then
        # Darwin `uname -m` lies
        if sysctl hw.optional.x86_64 | grep -q ': 1'; then
            _cputype=x86_64
        fi
    fi

    case "$_cputype" in
    xscale | arm | armv6l | armv7l | armv8l | aarch64 | arm64)
        _cputype=arm64
        ;;
    x86_64 | x86-64 | x64 | amd64)
        _cputype=amd64
        ;;
    *)
        err "unknown CPU type: $_cputype"
        ;;
    esac

    case "$_ostype" in
    Linux | FreeBSD | NetBSD | DragonFly)
        _ostype=linux
        _os=Linux
        # If the requested Atlas Version is prior to v0.12.1, the libc implementation is musl,
        # or the glibc version is <2.31, use the musl build.
        if [ "$ATLAS_VERSION" != "latest" ] &&
            [ "$(printf '%s\n' "v0.12.1" "$ATLAS_VERSION" | sort -V | head -n1)" = "$ATLAS_VERSION" ]; then
            if ldd --version 2>&1 | grep -q 'musl' ||
                [ $(version "$(ldd --version | awk '/ldd/{print $NF}')") -lt $(version "2.31") ]; then
                _cputype="$_cputype-musl"
            fi
        fi
        ;;
    Darwin)
        _ostype=darwin
        _os=MacOS
        # We only provide arm64 builds for Mac starting with v0.12.1. If the requested version below
        # v0.12.1, fallback to amd64 builds, since M1 chips are capable of running amd64 binaries.
        if [ "$ATLAS_VERSION" != "latest" ] &&
            [ "$(printf '%s\n' "v0.12.1" "$ATLAS_VERSION" | sort -V | head -n1)" = "$ATLAS_VERSION" ]; then
            _cputype=amd64
        fi
        ;;
    *)
        err "unrecognized OS type: $_ostype"
        ;;
    esac

    PLATFORM="$_ostype-$_cputype"

	#https://release.ariga.io/atlas/atlas-[{PLATFORM}[{OS}linux|darwin]-[{arch}arm64|amd64]-[{ATLAS_VERSION}latest|v{semver}]]
	url="$DL_BASEURL/atlas-${PLATFORM}-${ATLAS_VERSION}"

	echo "* Downloading ${TOOL_NAME} release ${ATLAS_VERSION} from ${url}..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download ${url}"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
