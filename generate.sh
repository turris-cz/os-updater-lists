#!/bin/bash
# Updater-ng configuration lists generating script
# (C) 2018-2020 CZ.NIC, z.s.p.o.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
set -eu

usage() {
	echo "Usage: $0 [-h] [-f FEEDS] [-v VERSION] [DIR]" >&2
}

help() {
	usage
	cat >&2 <<EOF
Turris OS lists for updater-ng generator script.

DIR is optional output directory, in default './lists' is used.

Options:
  -f FEEDS   Path to feeds.conf file for target build (in default ./feeds.conf is
             assumed)
  -v VERSION Turris OS version specification for lists (in default 'unknown' is
             used)
  -h         Prints this help text
EOF
}

feeds_conf="./feeds.conf"
tos_version="unknown"
while getopts "hf:v:" opt; do
	case "$opt" in
		h)
			help
			exit 0
			;;
		f)
			feeds_conf="$OPTARG"
			;;
		v)
			tos_version="$OPTARG"
			;;
		*)
			usage
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

case "$#" in
	0)
		output_path="./lists"
		;;
	1)
		output_path="$1"
		;;
	*)
		echo "Only one output directory can be specified" >&2
		usage
		exit 1
		;;
esac

[ -r "$feeds_conf" ] || {
	echo "No such feed file located: $feeds_conf" >&2
	usage
	exit 1
}

lists_dir="${0%/*}"

rm -rf "$output_path"
mkdir -p "$output_path"

( cd "$lists_dir" && git rev-parse HEAD ) > "$output_path/git-hash"

m4args=( "--include=$lists_dir" "-D_INCLUDE_=$lists_dir/" "-D_FEEDS_=$feeds_conf" )
m4args+=( "-D_TURRIS_OS_VERSION_=$tos_version" )

find "$lists_dir" -name '*.lua.m4' -print0 | while read -r -d '' f; do
	output="$output_path/${f##$lists_dir/}"
	mkdir -p "${output%/*}"
	m4 "${m4args[@]}" "$f" > "${output%.m4}"
done
find "$lists_dir" -name '*.lua' -print0 | while read -r -d '' f; do
	output="$output_path/${f##$lists_dir/}"
	mkdir -p "${output%/*}"
	cp "$f" "${output}"
done
