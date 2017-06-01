# Global Functions
# ----------------------------------------------------------------------------------------------------

# Documentation Requirements
# --------------------------------------------------

# See '/DOCUMENTATION.md'

# Helper Functions - Arg
# --------------------------------------------------

# type: direct
# signature: bashctl__print_error append_newline error_format [error_msg [...]]
# return:
#   -1 if given arguments are invalid.
# info:
#   This function is overwridden later with a colored version - this is only
#   here to put the chicken & egg to rest.
function bashctl__print_error {
	local append_newline="$1"; shift
	local error_format="$1"; shift

	printf 'old\n' >&2

	printf "Error: $error_format" "$@" >&2
	if [ "$append_newline" = true ]; then
		printf '\n' >&2
	fi

	return 0
}

# type: direct
# signature: bashctl__arg arg_name arg_value [possible_value_of_arg_value [...]]
# return:
#   1 if arg_value is blank
#     this may happen if the arg being tested was not given
#   2 if arg_value is not one of the given possible values for it (if any given)
function bashctl__arg {
	local name="$1"; shift
	local value="$1"; shift
	local optional="$1"; shift

	local valid_value
	local val

	# Check for unset or blank
	if [ -z "$value" ]; then
		if [ "$optional" = false -a "$bashctl__quiet" = false ]; then
			bashctl__print_error true "'%s' must be given" "$name" >&2
		fi
		return 1
	fi

	# Check for valid values, if at least one more argument was given
	if [ ! -z "$1" ]; then
		valid_value=false
		for val in "$@"; do
			if [ "$value" = "$val" ]; then
				valid_value=true
				break
			fi
		done

		if ! "$valid_value"; then
			if [ "$optional" = false -a "$bashctl__quiet" = false ]; then
				bashctl__print_error true "Invalid value for '%s': %s" "$name" "$value" >&2
			fi
			return 2
		fi
	fi

	# Passed checks
	return 0
}

# Helper Functions - Others
# --------------------------------------------------

# type: capture
# signature: bashctl__bool value
function bashctl__bool {
	local value

	# Any integer can be given - the test is for being non-zero, as is
	# often helpful in the shell.

	bashctl__arg 'value' "$1" false && \
		value="$1" && shift || \
		return -1

	test "$value" -eq 0
	case $? in
		0) printf '%s' true;;
		1) printf '%s' false;;
	esac

	return 0
}

# type: capture
# signature: bashctl__append cur_val add_val
function bashctl__append {
	local cur_val="$1"; shift
	local add_val="$1"; shift
	local result

	if [ -z "$cur_val" ]; then
		result="$add_val"
	else
		if [ -z "$add_val" ]; then
			result="$cur_val"
		else
			result="$cur_val"$'\n'"$add_val"
		fi
	fi

	printf '%s' "$result"
	return 0
}

# Basic I/O
# --------------------------------------------------

# type: direct [OR] capture
# signature: bashctl__print_color_escape color_string [bold] [raw]
# return:
#   -1 if given arguments are invalid.
function bashctl__print_color_escape {
	local color_string
	local bold
	local raw

	bashctl__arg 'color_string' "$1" false \
		'normal' 'black' 'red' 'green' 'orange' 'blue' 'magenta' 'turquoise' 'white' && \
		color_string="$1" && shift || \
		return -1

	bashctl__arg 'bold' "$1" true \
		true false && \
		bold="$1" && shift || \
		bold=false

	bashctl__arg 'raw' "$1" true \
		true false && \
		raw="$1" && shift || \
		raw=false

	local bold_string
	case "$bold" in
		true) bold_string="01;";;
		false) bold_string="";;
	esac

	local raw_string
	case "$raw" in
		true) raw_string='\\\';;
		false) raw_string='';;
	esac

	local color_seq
	case "$color_string" in
		'normal') color_seq="${raw_string}\033[${bold_string}0m";;

		'black') color_seq="${raw_string}\033[${bold_string}30m";;
		'red') color_seq="${raw_string}\033[${bold_string}31m";;
		'green') color_seq="${raw_string}\033[${bold_string}32m";;
		'orange') color_seq="${raw_string}\033[${bold_string}33m";;
		'blue') color_seq="${raw_string}\033[${bold_string}34m";;
		'magenta') color_seq="${raw_string}\033[${bold_string}35m";;
		'turquoise') color_seq="${raw_string}\033[${bold_string}36m";;
		'white') color_seq="${raw_string}\033[${bold_string}37m";;
	esac

	printf "$color_seq"
	return 0
}

# type: direct [OR] capture
# signature: bashctl__print color_string [bold] format_string [format_object [...]]
# return:
#   -1 if given arguments are invalid.
function bashctl__print {
	local color_string
	local bold
	local format_string

	bashctl__arg 'color_string' "$1" false \
		'normal' 'black' 'red' 'green' 'orange' 'blue' 'magenta' 'turquoise' 'white' \
		'n' 'z' 'r' 'g' 'o' 'b' 'm' 't' 'w' && \
		color_string="$1" && shift || \
		return -1

	bashctl__arg 'bold' "$1" true \
		true false && \
		bold="$1" && shift || \
		bold=false

	bashctl__arg 'format_string' "$1" false && \
		format_string="$1" && shift || \
		return -1

	case "$bashctl__color" in
		'color' | 'rawcolor')
			case "$color_string" in
				'normal' | 'n') color_string='normal';;

				'black' | 'z') color_string='black';;
				'red' | 'r') color_string='red';;
				'green' | 'g') color_string='green';;
				'orange' | 'o') color_string='orange';;
				'blue' | 'b') color_string='blue';;
				'magenta' | 'm') color_string='magenta';;
				'turquoise' | 't') color_string='turquoise';;
				'white' | 'w') color_string='white';;
			esac
			;;

		'nocolor')
			case "$color_string" in
				'normal' | 'n') color_string='';;

				'black' | 'z') color_string='z';;
				'red' | 'r') color_string='r';;
				'green' | 'g') color_string='g';;
				'orange' | 'o') color_string='o';;
				'blue' | 'b') color_string='b';;
				'magenta' | 'm') color_string='m';;
				'turquoise' | 't') color_string='t';;
				'white' | 'w') color_string='w';;
			esac
			;;
	esac

	local color_seq
	local normal_seq
	case "$bashctl__color" in
		'color')
			color_seq="$(bashctl__print_color_escape "$color_string" "$bold" >&1)"
			normal_seq="$(bashctl__print_color_escape 'normal')"
			;;

		'rawcolor')
			color_seq="$(bashctl__print_color_escape "$color_string" "$bold" true >&1)"
			normal_seq="$(bashctl__print_color_escape 'normal')"
			;;

		'nocolor')
			local bold_string
			case "$bold" in
				true) bold_string=":b";;
				false) bold_string="";;
			esac

			# 'normal' color (see above)
			if [ -z "$color_string" ]; then
				color_seq=""
				normal_seq=""
			else
				color_seq="${color_string}${bold_string}:("
				normal_seq=")"
			fi
			;;

		'raw')
			color_seq=''
			normal_seq=''
			;;
	esac

	printf "${color_seq}${format_string}${normal_seq}" "$@"
	return 0
}

# General-Purpose I/O
# --------------------------------------------------

# type: direct [OR] capture
# signature: bashctl__print_term <args are the same as `bashctl__print`>
# return:
#   64 if the bashctl__quiet global is true.
#   <same as `bashctl__print`>
function bashctl__print_term {
	if [ "$bashctl__quiet" = true ]; then
		return 64
	fi

	bashctl__print "$@"
	return $?
}

# type: direct
# signature: bashctl__print_error [append_newline] error_format [error_msg [...]]
# return:
#   -1 if given arguments are invalid.
function bashctl__print_error {
	local append_newline
	local error_format

	bashctl__arg 'append_newline' "$1" true \
		true false && \
		append_newline="$1" && shift || \
		append_newline=false

	bashctl__arg 'error_format' "$1" false && \
		error_format="$1" && shift || \
		return -1

	bashctl__print_term 'red' true 'Error: ' >&2
	bashctl__print_term 'normal' false "$error_format" "$@" >&2
	if [ "$append_newline" = true ]; then
		bashctl__print_term 'normal' false '\n' >&2
	fi

	return 0
}

# type: direct
# signature: bashctl__print_warning [append_newline] warning_format [warning_msg [...]]
# return:
#   -1 if given arguments are invalid.
function bashctl__print_warning {
	local append_newline
	local warning_format

	bashctl__arg 'append_newline' "$1" true \
		true false && \
		append_newline="$1" && shift || \
		append_newline=false

	bashctl__arg 'warning_format' "$1" false && \
		warning_format="$1" && shift || \
		return -1

	bashctl__print_term 'blue' true 'Warning: ' >&2
	bashctl__print_term 'normal' false "$warning_format" "$@" >&2
	if [ "$append_newline" = true ]; then
		bashctl__print_term 'normal' false '\n' >&2
	fi

	return 0
}

# type: direct
# signature: bashctl__print_msg <args are the same as `bashctl__print_term`>
# return:
#   <same as `bashctl__print_term`>
function bashctl__print_msg {
	bashctl__print_term "$@" >&3
	return $?
}

# type: direct
# signature: bashctl__print_debug [given_debug_level debug_level] debug_format [debug_msg [...]]
# return:
#   -1 if given arguments are invalid.
function bashctl__print_debug {
	local given_debug_level
	local debug_level
	local debug_format

	bashctl__arg 'given_debug_level' "$1" true \
		true false && \
		given_debug_level="$1" && shift || \
		given_debug_level=false

	if [ "$given_debug_level" = true ]; then
		bashctl__arg 'debug_level' "$1" false && \
			debug_level="$(printf '%i' "$1")" && shift || \
			return -1
	else
		# A minimum level of 1 ensures that it is not printed by default.
		debug_level=1
	fi

	bashctl__arg 'debug_format' "$1" false && \
		debug_format="$1" && shift || \
		return -1

	# Function body
	# ----------
	if [ "$bashctl__debug" -ge "$debug_level" ]; then
		bashctl__print_term 'blue' true 'Debug: ' >&4
		bashctl__print_term 'normal' false "$debug_format" "$@" >&4
	fi

	return 0
}

