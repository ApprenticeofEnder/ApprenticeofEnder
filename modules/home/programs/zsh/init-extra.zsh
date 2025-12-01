function pathappend() {
	local var="${1}"
	shift
	while [[ $# -ge 1 ]]; do
		if [[ -d "${1}" ]] && ! [[ "${(P)var}" =~ (^|:)$1($|:) ]]; then
			eval "$var=${(P)var}:$1; export $var;"
		fi
		shift
	done
}

function pathprepend() {
	local var="${1}"
	shift
	while [[ $# -ge 1 ]]; do
		if [[ -d "${1}" ]] && ! [[ "${(P)var}" =~ (^|:)$1($|:) ]]; then
			eval "$var=$1:${(P)var}; export $var;"
		fi
		shift
	done
}

function pathunmunge() {
	local var="${1}"
	local value="${(P)var}"
	shift
	while [[ $# -ge 1 ]]; do
		local newpath=""
		local sep=""
		local p=
		for p in ${(s,:,)value}; do
			debug "p=${p}"
			if [[ "x${p}" != "x${1}" ]]; then
				newpath="${newpath}${sep}${p}"
				sep=":"
			fi
		done
		value="${newpath}"
		shift
	done
	eval "$var=${value}; export $var;"
}

pathappend PATH "${HOME}/.local/bin"

# TODO: Move this out of the `files` directory
source "${HOME}/.config/op/plugins-nix.sh"
