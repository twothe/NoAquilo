#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

require_command() {
	local command_name="$1"
	if ! command -v "${command_name}" >/dev/null 2>&1; then
		echo "Required command not found: ${command_name}" >&2
		exit 1
	fi
}

require_path() {
	local path="$1"
	if [ ! -e "${path}" ]; then
		echo "Required release path is missing: ${path}" >&2
		exit 1
	fi
}

copy_if_present() {
	local path="$1"
	if [ -e "${path}" ]; then
		cp -a "${path}" "${package_root}/"
	fi
}

require_command jq
require_command zip

mod_name="$(jq -r '.name // empty' info.json | tr -d '\r')"
mod_version="$(jq -r '.version // empty' info.json | tr -d '\r')"

if [[ ! "${mod_name}" =~ ^[A-Za-z0-9_-]+$ ]]; then
	echo "Invalid or missing Factorio mod name in info.json: ${mod_name}" >&2
	exit 1
fi

if [[ ! "${mod_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Invalid or missing Factorio mod version in info.json: ${mod_version}" >&2
	exit 1
fi

for required_path in info.json data.lua data-updates.lua data-final-fixes.lua prototypes locale; do
	require_path "${required_path}"
done

package_name="${mod_name}_${mod_version}"
archive_name="${package_name}.zip"
archive_path="${repo_root}/dist/${archive_name}"
tmp_dir="$(mktemp -d)"
package_root="${tmp_dir}/${package_name}"

cleanup() {
	if [ -n "${tmp_dir}" ] && [ -d "${tmp_dir}" ]; then
		find "${tmp_dir}" -type f -delete
		find "${tmp_dir}" -depth -type d -empty -delete
	fi
}
trap cleanup EXIT

mkdir -p "${package_root}" "${repo_root}/dist"

runtime_paths=(
	info.json
	thumbnail.png
	data.lua
	data-updates.lua
	data-final-fixes.lua
	control.lua
	settings.lua
	settings-updates.lua
	settings-final-fixes.lua
	prototypes
	locale
	graphics
	sounds
	simulations
	scenarios
	migrations
)

for runtime_path in "${runtime_paths[@]}"; do
	copy_if_present "${runtime_path}"
done

rm -f "${archive_path}"
(
	cd "${tmp_dir}"
	zip -r -q "${archive_path}" "${package_name}"
)

echo "Built ${archive_path}"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
	{
		echo "archive_name=${archive_name}"
		echo "archive_path=${archive_path}"
		echo "mod_name=${mod_name}"
		echo "mod_version=${mod_version}"
		echo "package_name=${package_name}"
	} >> "${GITHUB_OUTPUT}"
fi
