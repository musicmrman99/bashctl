# Indentation: 1 tab

# Note 1: The redirection of stdout to stdout ('>&1') in some places in this
#         file is to avoid a syntax highlighting bug in gedit, relating to the
#         'case' statement.

# Note 2: Some parts of this scripts used to use a program I wrote called
#         'split-join'. However, 'split-join' is not a Unix, GNU, or other
#         common utility (its userbase is 1 person - me), so I replaced calls to
#         it with 'cut', plus in some cases wrapping it with two 'rev' calls to
#         handle negative offsets. That's what all the 'vs. split-join:' notes
#         are about.

# Note 3: The '-L' option means 'always dereference symlinks' - THIS MAY BREAK
#         in circumstances of recursive linking, but it facilitates symlinking
#         of scripts/definitions from the library to the library components
#         directories.

# FIXME 1: Leaving $template_options unqoted will split it at whitespace, but we
#          don't want to split it at whitespace, we want to split it at argument
#          bounderies!

# Global Variables
# ----------------------------------------------------------------------------------------------------

# Bugs
# --------------------------------------------------
# See 'src-global-var-bugs.txt', same dir as this file.

# Set Defaults (CONST)
# --------------------------------------------------

bashctl__default__component="/bashctl"

bashctl__default__color='nocolor'
bashctl__default__quiet=false
bashctl__default__force=false
bashctl__default__fail_unrecognized=false
bashctl__default__assume_version=''
bashctl__default__default_template='blank-script'
bashctl__default__default_template_options=''
bashctl__default__default_template_copier='copy-substitute'
bashctl__default__default_editor='nano'

bashctl__default__debug=0
bashctl__default__debug_matches=false
bashctl__default__debug_version_selection=false
bashctl__default__debug_exec_checks=false

bashctl__default__fatal_attrs='template'
bashctl__default__soft_fail_attrs='disabled'
bashctl__default__required_attrs='sh'
bashctl__default__information_attrs='suite'

# Global Functions
# ----------------------------------------------------------------------------------------------------

# Documentation Requirements
# --------------------------------------------------

# See '/DOCUMENTATION.md'

# Global Variables
# --------------------------------------------------

# Set (or Reset) to Defaults
# --------------------

# type: direct
# signature: bashctl__set_global_defaults global_control
# return:
#   -1 if given arguments are invalid.
#   64 if global_control is 'const'.
function bashctl__set_global_defaults {
	local global_control

	bashctl__arg 'global_control' "$1" false && \
		global_control="$1" && shift || \
		return -1

	if [ "$global_control" = 'const' ]; then
		return 64
	fi

	bashctl__component="${bashctl__component-$bashctl__default__component}"

	bashctl__color="${bashctl__color-$bashctl__default__color}"
	bashctl__quiet="${bashctl__quiet-$bashctl__default__quiet}"
	bashctl__force="${bashctl__force-$bashctl__default__force}"
	bashctl__fail_unrecognized="${bashctl__fail_unrecognized-$bashctl__default__fail_unrecognized}"
	bashctl__assume_version="${bashctl__assume_version-$bashctl__default__assume_version}"
	bashctl__default_template="${bashctl__default_template-$bashctl__default__default_template}"
	bashctl__default_template_options="${bashctl__default_template_options-$bashctl__default__default_template_options}"
	bashctl__default_template_copier="${bashctl__default_template_copier-$bashctl__default__default_template_copier}"
	bashctl__default_editor="${bashctl__default_editor-$bashctl__default__default_editor}"

	bashctl__debug="${bashctl__debug-$bashctl__default__debug}"
	bashctl__debug_matches="${bashctl__debug_matches-$bashctl__default__debug_matches}"
	bashctl__debug_version_selection="${bashctl__debug_version_selection-$bashctl__default__debug_version_selection}"
	bashctl__debug_exec_checks="${bashctl__debug_exec_checks-$bashctl__default__debug_exec_checks}"

	bashctl__fatal_attrs="${bashctl__fatal_attrs-$bashctl__default__fatal_attrs}"
	bashctl__soft_fail_attrs="${bashctl__soft_fail_attrs-$bashctl__default__soft_fail_attrs}"
	bashctl__required_attrs="${bashctl__required_attrs-$bashctl__default__required_attrs}"
	bashctl__information_attrs="${bashctl__information_attrs-$bashctl__default__information_attrs}"

	return 0
}

# Store and Restore
# --------------------

# type: direct
# signature: bashctl__store_globals global_control
# return:
#   -1 if given arguments are invalid.
#   64 if global_control is 'const'.
function bashctl__store_globals {
	local global_control

	bashctl__arg 'global_control' "$1" false && \
		global_control="$1" && shift || \
		return -1

	if [ "$global_control" = 'const' ]; then
		return 64
	fi

	bashctl__backup__component="$bashctl__component"

	bashctl__backup__color="$bashctl__color"
	bashctl__backup__quiet="$bashctl__quiet"
	bashctl__backup__force="$bashctl__force"
	bashctl__backup__fail_unrecognized="$bashctl__fail_unrecognized"
	bashctl__backup__assume_version="$bashctl__assume_version"
	bashctl__backup__default_template="$bashctl__default_template"
	bashctl__backup__default_template_options="$bashctl__default_template_options"
	bashctl__backup__default_template_copier="$bashctl__default_template_copier"
	bashctl__backup__default_editor="$bashctl__default_editor"

	bashctl__backup__debug="$bashctl__debug"
	bashctl__backup__debug_matches="$bashctl__debug_matches"
	bashctl__backup__debug_version_selection="$bashctl__debug_version_selection"
	bashctl__backup__debug_exec_checks="$bashctl__debug_exec_checks"

	bashctl__backup__fatal_attrs="$bashctl__fatal_attrs"
	bashctl__backup__required_attrs="$bashctl__required_attrs"
	bashctl__backup__soft_fail_attrs="$bashctl__soft_fail_attrs"
	bashctl__backup__information_attrs="$bashctl__information_attrs"

	return 0
}

# type: direct
# signature: bashctl__unset_globals global_control [unset_backups]
# return:
#   -1 if given arguments are invalid.
#   64 if global_control is 'const'
function bashctl__unset_globals {
	local global_control
	local unset_backups

	bashctl__arg 'global_control' "$1" false && \
		global_control="$1" && shift || \
		return -1

	bashctl__arg 'unset_backups' "$1" true \
		true false && \
		unset_backups="$1" && shift || \
		unset_backups=false

	if [ "$global_control" = 'const' ]; then
		return 64
	fi

	if [ "$unset_backups" = true ]; then
		unset bashctl__backup__component

		unset bashctl__backup__color
		unset bashctl__backup__quiet
		unset bashctl__backup__force
		unset bashctl__backup__fail_unrecognized
		unset bashctl__backup__assume_version
		unset bashctl__backup__default_template
		unset bashctl__backup__default_template_options
		unset bashctl__backup__default_template_copier
		unset bashctl__backup__default_editor

		unset bashctl__backup__debug
		unset bashctl__backup__debug_matches
		unset bashctl__backup__debug_version_selection
		unset bashctl__backup__debug_exec_checks

		unset bashctl__backup__fatal_attrs
		unset bashctl__backup__soft_fail_attrs
		unset bashctl__backup__required_attrs
		unset bashctl__backup__information_attrs
	else
		unset bashctl__component

		unset bashctl__color
		unset bashctl__quiet
		unset bashctl__force
		unset bashctl__fail_unrecognized
		unset bashctl__assume_version
		unset bashctl__default_template
		unset bashctl__default_template_options
		unset bashctl__default_template_copier
		unset bashctl__default_editor

		unset bashctl__debug
		unset bashctl__debug_matches
		unset bashctl__debug_version_selection
		unset bashctl__debug_exec_checks

		unset bashctl__fatal_attrs
		unset bashctl__soft_fail_attrs
		unset bashctl__required_attrs
		unset bashctl__information_attrs
	fi

	return 0
}

# type: direct
# signature: bashctl__restore_globals global_control
# return:
#   -1 if given arguments are invalid.
#   64 if 'global_control' is 'const'.
function bashctl__restore_globals {
	local global_control

	bashctl__arg 'global_control' "$1" false && \
		global_control="$1" && shift || \
		return -1

	if [ "$global_control" = 'const' ]; then
		return 64
	fi

	if [ "$global_control" = 'reset' ]; then
		bashctl__component="$bashctl__backup__component"

		bashctl__color="$bashctl__backup__color"
		bashctl__quiet="$bashctl__backup__quiet"
		bashctl__force="$bashctl__backup__force"
		bashctl__fail_unrecognized="$bashctl__backup__fail_unrecognized"
		bashctl__assume_version="$bashctl__backup__assume_version"
		bashctl__default_template="$bashctl__backup__default_template"
		bashctl__default_template_options="$bashctl__backup__default_template_options"
		bashctl__default_template_copier="$bashctl__backup__default_template_copier"
		bashctl__default_editor="$bashctl__backup__default_editor"

		bashctl__debug="$bashctl__backup__debug"
		bashctl__debug_matches="$bashctl__backup__debug_matches"
		bashctl__debug_version_selection="$bashctl__backup__debug_version_selection"
		bashctl__debug_exec_checks="$bashctl__backup__debug_exec_checks"

		bashctl__fatal_attrs="$bashctl__backup__fatal_attrs"
		bashctl__soft_fail_attrs="$bashctl__backup__soft_fail_attrs"
		bashctl__required_attrs="$bashctl__backup__required_attrs"
		bashctl__information_attrs="$bashctl__backup__information_attrs"

		bashctl__unset_globals "$global_control" true
	fi

	return 0
}

# type: direct [OR] capture
# signature: bashctl__print_globals global_control
# return:
#   -1 if given arguments are invalid.
#   64 if 'global_control' is 'const'.
function bashctl__print_globals {
	local global_control

	bashctl__arg 'global_control' "$1" false && \
		global_control="$1" && shift || \
		return -1

	if [ "$global_control" = 'const' ]; then
		return 64
	fi

	if [ "$global_control" = 'get' ]; then
		bashctl__print_term 'normal' false "bashctl__component('%s')\n" "$bashctl__component"

		bashctl__print_term 'normal' '\n'
		bashctl__print_term 'normal' false "bashctl__color('%s')\n" "$bashctl__color"
		bashctl__print_term 'normal' false "bashctl__quiet('%s')\n" "$bashctl__quiet"
		bashctl__print_term 'normal' false "bashctl__force('%s')\n" "$bashctl__force"
		bashctl__print_term 'normal' false "bashctl__fail_unrecognized('%s')\n" "$bashctl__fail_unrecognized"
		bashctl__print_term 'normal' false "bashctl__assume_version('%s')\n" "$bashctl__assume_version"
		bashctl__print_term 'normal' false "bashctl__default_template('%s')\n" "$bashctl__default_template"
		bashctl__print_term 'normal' false "bashctl__default_template_options('%s')\n" "$bashctl__default_template_options"
		bashctl__print_term 'normal' false "bashctl__default_template_copier('%s')\n" "$bashctl__default_template_copier"
		bashctl__print_term 'normal' false "bashctl__default_editor('%s')\n" "$bashctl__default_editor"

		bashctl__print_term 'normal' '\n'
		bashctl__print_term 'normal' false "bashctl__debug('%s')\n" "$bashctl__debug"
		bashctl__print_term 'normal' false "bashctl__debug_matches('%s')\n" "$bashctl__debug_matches"
		bashctl__print_term 'normal' false "bashctl__debug_version_selection('%s')\n" "$bashctl__debug_version_selection"
		bashctl__print_term 'normal' false "bashctl__debug_exec_checks('%s')\n" "$bashctl__debug_exec_checks"

		bashctl__print_term 'normal' '\n'
		bashctl__print_term 'normal' false "bashctl__fatal_attrs('%s')\n" "$bashctl__fatal_attrs"
		bashctl__print_term 'normal' false "bashctl__soft_fail_attrs('%s')\n" "$bashctl__soft_fail_attrs"
		bashctl__print_term 'normal' false "bashctl__required_attrs('%s')\n" "$bashctl__required_attrs"
		bashctl__print_term 'normal' false "bashctl__information_attrs('%s')\n" "$bashctl__information_attrs"
	fi

	return 0
}

# Parse Arguments
# --------------------------------------------------

# type: direct! (setting globals in a temporary subshell is pointless)
# signature: bashctl__set_global_option option set_op value
# return:
#   -1 if given arguments are invalid.
#   -2 if an invalid value, or no value, in the cases where that is invalid,
#     is given to assign to a valid option.
#   1 if given option name doesn't match any valid global options.
function bashctl__set_global_option {
	local option
	local set_op
	local value

	bashctl__arg 'option' "$1" false && \
		option="$1" && shift || \
		return -1

	bashctl__arg 'set_op' "$1" false && \
		set_op="$1" && shift || \
		return -1

	bashctl__arg 'value' "$1" false && \
		value="$1" && shift || \
		return -1

	local valid_assignment
	local cur_value
	local append_value

	case "$option" in
		# Location
		# --------------------
		'-Comp' | '--bashctl-component')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-Comp' or '--bashctl-component' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				case "$value" in
					*/*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
					*) bashctl__component="$value";;
				esac
			fi
			;;

		# Preferences/Settings
		# --------------------
		'-C' | '--color')
			if [ "$set_op" = false ]; then
				bashctl__color='color'
			elif [ "$set_op" = true ]; then
				case "$value" in
					'color') bashctl__color='color';;
					'rawcolor') bashctl__color='rawcolor';;
					'nocolor') bashctl__color='nocolor';;
					'raw') bashctl__color='raw';;
					*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
				esac
			fi
			;;

		'-Q' | '--quiet')
			if [ "$set_op" = false ]; then
				bashctl__quiet=true
			elif [ "$set_op" = true ]; then
				case "$value" in
					true | false) bashctl__quiet="$value";;
					*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
				esac
			fi
			;;

		'-F' | '--force')
			if [ "$set_op" = false ]; then
				bashctl__force=true
			elif [ "$set_op" = true ]; then
				case "$value" in
					true | false) bashctl__force="$value";;
					*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
				esac
			fi
			;;

		'-U' | '--fail-unrecognized')
			if [ "$set_op" = false ]; then
				bashctl__fail_unrecognized=true
			elif [ "$set_op" = true ]; then
				case "$value" in
					true | false) bashctl__fail_unrecognized="$value";;
					*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
				esac
			fi
			;;

		'-V' | '--assume-version')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-V' or '--assume-version' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				# Verification of the assumed version is done when something with multiple versions is executed.
				bashctl__assume_version="$value"
			fi
			;;

		'-T' | '--default-template')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-T' or '--default-template' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				# Validation that the used template exists is done when something is created using it.
				bashctl__default_template="$value"
			fi
			;;

		'-To' | '--default-template-options')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-To' or '--default-template-options' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				# Validation of the used template options is done by the template when something is created or deleted using it.
				bashctl__default_template_options="$value"
			fi
			;;

		'-Tc' | '--default-template-copier')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-Tc' or '--default-template-copier' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				# Validation that the used template exists is done when something is created using it.
				bashctl__default_template_copier="$value"
			fi
			;;

		'-E' | '--default-editor')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-E' or '--default-editor' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				bashctl__default_editor="$value"
			fi
			;;

		# Debugging
		# --------------------
		'-D' | '--debug')
			if [ "$set_op" = false ]; then
				bashctl__debug=1
			elif [ "$set_op" = true ]; then
				valid_assignment=true

				# Valid integer? `printf` should know:
				if [ "$(printf '%i' "$value" 1>/dev/null 2>&1; printf '%s' $?)" = 0 ]; then
					bashctl__debug="$value"
				else
					bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
					return -2
				fi
			fi
			;;

		# Note: '-Dx' != '-D=x'. The former doesn't exist, but it is
		#       in the correct format. The latter would mean something
		#       completely different, if it was valid (it's not valid
		#       because 'x' is not an integer).

		'-Dm' | '--debug-matches')
			if [ "$set_op" = false ]; then
				bashctl__debug_matches=true
			elif [ "$set_op" = true ]; then
				case "$value" in
					true | false) bashctl__debug_matches="$value";;
					*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
				esac
			fi
			;;

		'-Dv' | '--debug-version-selection')
			if [ "$set_op" = false ]; then
				bashctl__debug_version_selection=true
			elif [ "$set_op" = true ]; then
				case "$value" in
					true | false) bashctl__debug_version_selection="$value";;
					*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
				esac
			fi
			;;

		'-Dc' | '--debug-exec-checks')
			if [ "$set_op" = false ]; then
				bashctl__debug_exec_checks=true
			elif [ "$set_op" = true ]; then
				case "$value" in
					true | false) bashctl__debug_exec_checks="$value";;
					*)
						bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
						return -2
						;;
				esac
			fi
			;;

		# Attribute Status
		# --------------------
		'-Af' | '--attributes-fatal')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-Af' or '--attributes-fatal' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				case "$(printf '%s' "$value" | head -c 1)" in
					'+')
						cur_value="$bashctl__fatal_attrs"
						append_value="$(printf '%s' "$value" | tail -c +2)"
						;;
					*)
						cur_value=''
						append_value="$value"
						;;
				esac

				case "$append_value" in
					'') bashctl__fatal_attrs="${cur_value}";;
					*) bashctl__fatal_attrs="${cur_value}/${append_value}";;
				esac
			fi
			;;

		'-As' | '--attributes-soft-fail')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-As' or '--attributes-soft-fail' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				case "$(printf '%s' "$value" | head -c 1)" in
					'+')
						cur_value="$bashctl__soft_fail_attrs"
						append_value="$(printf '%s' "$value" | tail -c +2)"
						;;
					*)
						cur_value=''
						append_value="$value"
						;;
				esac

				case "$append_value" in
					'') bashctl__soft_fail_attrs="${cur_value}";;
					*) bashctl__soft_fail_attrs="${cur_value}/${append_value}";;
				esac
			fi
			;;

		'-Ar' | '--attributes-required')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-Ar' or '--attributes-required' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				case "$(printf '%s' "$value" | head -c 1)" in
					'+')
						cur_value="$bashctl__required_attrs"
						append_value="$(printf '%s' "$value" | tail -c +2)"
						;;
					*)
						cur_value=''
						append_value="$value"
						;;
				esac

				case "$append_value" in
					'') bashctl__required_attrs="${cur_value}";;
					*) bashctl__required_attrs="${cur_value}/${append_value}";;
				esac
			fi
			;;

		'-Ai' | '--attributes-information')
			if [ "$set_op" = false ]; then
				bashctl__print_error true "'-Ai' or '--attributes-information' must have an assignment after it."
				return -2
			elif [ "$set_op" = true ]; then
				case "$(printf '%s' "$value" | head -c 1)" in
					'+')
						cur_value="$bashctl__information_attrs"
						append_value="$(printf '%s' "$value" | tail -c +2)"
						;;
					*)
						cur_value=''
						append_value="$value"
						;;
				esac

				case "$append_value" in
					'') bashctl__information_attrs="${cur_value}";;
					*) bashctl__information_attrs="${cur_value}/${append_value}";;
				esac
			fi
			;;

		*)
			return 1
			;;
	esac

	return 0
}

# Definition Matching
# --------------------------------------------------

# type: capture
# signature: bashctl__match [given_additional_find_args [additional_find_args]] current_dir current_depth full_pattern
# return:
#   -1 if given arguments are invalid.
function bashctl__match {
	local given_additional_find_args
	local additional_find_args
	local current_dir
	local current_depth
	local full_pattern

	bashctl__arg 'given_additional_find_args' "$1" true \
		true false  && \
		given_additional_find_args="$1" && shift || \
		given_additional_find_args=false

	if [ "$given_additional_find_args" = true ]; then
		# It is optional, but the logic for its optionalness is here,
		# not in bashctl__arg.
		bashctl__arg 'additional_find_args' "$1" false && \
			additional_find_args="$1" && shift || \
			return -1
	else
		additional_find_args=""
	fi

	bashctl__arg 'current_dir' "$1" false && \
		current_dir="$1" && shift || \
		return -1

	bashctl__arg 'current_depth' "$1" false && \
		current_depth="$1" && shift || \
		return -1

	bashctl__arg 'full_pattern' "$1" false && \
		full_pattern="$1" && shift || \
		return -1

	local current_dir_last_depth
	if [ "$current_depth" = 0 ]; then
		current_dir_last_depth=""
	else
		# vs. with 'split-join':
		#   current_dir_last_depth="$(split-join '/' "-$current_depth:" "$current_dir")"
		current_dir_last_depth="$(printf '%s' "$current_dir" | rev | cut -d '/' -f 1-"$current_depth" | rev)"
	fi
	local paths=''

	# For the loop.
	local def_versions
	local defs
	local pattern
	local grep_options

	# Pattern Format:
	#   [-][/]<extended-regex>[/][;...]
	#
	#   - if the first character is '-', then invert the match
	#   - if the rest is of the form '/<extended-regex>/', then match
	#     <extended-regex> against what has already been matched.
	#   - <extended-regex> is a `grep -E`-style regex, see the grep
	#     manpage for details.

	IFS__backup="$IFS"
	IFS=';'
	set -f
	for pattern in $full_pattern; do
		IFS="$IFS__backup"

		# Use extended regex for this.
		grep_options='-E'

		if [ "$(printf '%s' "$pattern" | head -c 1)" = '-' ]; then
			# Invert match
			grep_options="$grep_options -v"

			# Remove dash.
			pattern="$(printf '%s' "$pattern" | tail -c +2)"
		fi

		# Find the current directory to the given depth
		case "$pattern" in
			# Filter
			/*/)
				# Remove slashes at either end.
				pattern="$(printf '%s' "$pattern" | tail -c +2 | head -c -1)"
				paths="$(printf '%s' "$paths" | grep $grep_options "^${current_dir_last_depth}/(${pattern})\$" >&1)"
				;;

			# Add
			*)
				# vs. with 'split-join':
				#   def_versions="$(find "$current_dir" -mindepth 1 -maxdepth 1 $additional_find_args | split-join '/' '-1:')"
				# See: Note 3
				def_versions="$(find -L "$current_dir" -mindepth 1 -maxdepth 1 $additional_find_args | rev | cut -d '/' -f 1 | rev)"

				# Remove all hidden files/directories.
				def_versions="$(printf '%s' "$def_versions" | sed -e '/^\..*/d')"

				# vs. with 'split-join':
				#   defs="$(split-join '.' ':1' "$def_versions" | uniq | grep $grep_options "^$pattern\$" | awk -e "\$0=\"$current_dir_last_depth/\"\$0" >&1)"
				defs="$(printf '%s' "$def_versions" | cut -d '.' -f 1 | uniq | grep $grep_options "^($pattern)\$" | awk -e "\$0=\"$current_dir_last_depth/\"\$0" >&1)"
				paths="$(bashctl__append "$paths" "$defs" >&1)"
				;;
		esac

		IFS=';'
	done
	set +f
	IFS="$IFS__backup"

	printf '%s' "$paths"
	return 0
}

# type: capture
# signature: bashctl__resolve_reference ref cur_dir [cur_depth]
# return:
#   -1 if given arguments are invalid.
#   64 if there was nothing to do, because the given definition reference is blank.
function bashctl__resolve_reference {
	local ref
	local cur_dir
	local cur_depth

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	bashctl__arg 'ref' "$1" false && \
		ref="$1" && shift || \
		return -1

	bashctl__arg 'cur_depth' "$1" true && \
		cur_depth="$1" && shift || \
		cur_depth=0

	local def_paths=''
	local def_names=''
	local def_list=''

	local cur_ref_part
	local remaining_ref_parts
	local next_dir
	local next_depth

	local def_path

	# vs. with 'split-join':
	#   cur_ref_part="$(split-join ':' ':1' "$ref")"
	cur_ref_part="$(printf '%s' "$ref" | cut -d ':' -f 1)"

	bashctl__print_debug true 3 "cur_ref_part('%s')\n" "$cur_ref_part"

	# If the 'current reference' is blank then nothing was given,
	# so skip everything.
	if [ -z "$cur_ref_part" ]; then return 64; fi

	# Get all matching definitions for the current reference part and
	# add them to the list.
	def_names="$(bashctl__match true '-type f' "$cur_dir" "$cur_depth" "$cur_ref_part")"

	bashctl__print_debug true 3 "def_names('%s')\n" "$def_names"

	if [ ! -z "$def_names" ]; then
		def_list="$(bashctl__append "$def_list" "$def_names")"
	fi

	# vs. with 'split-join' (the 'case' is only needed with 'cut'):
	#   remaining_ref_parts="$(split-join ':' '1:' "$ref")"
	case "$ref" in
		*:*) remaining_ref_parts="$(printf '%s' "$ref" | cut -d ':' -f 2-)";;
		*) remaining_ref_parts='';;
	esac

	bashctl__print_debug true 3 "remaining_ref_parts('%s')\n" "$remaining_ref_parts"

	# If there is no 'next reference', then skip groups (as nothing in
	# them can match anyway - there's no next reference to match against).
	if [ ! -z "$remaining_ref_parts" ]; then
		# Get all matching directories for the current reference part and resolve
		# the next reference part with each directory as the current directory.
		def_paths="$(bashctl__match true '-type d' "$cur_dir" "$cur_depth" "$cur_ref_part")"

		bashctl__print_debug true 3 "def_paths('%s')\n" "$def_paths"

		# If no groups matched, then skip looking for matches in matched groups.
		if [ ! -z "$def_paths" ]; then
			# Get the definition name(s) matching the given reference name,
			# within the definition group(s) matching this reference group.
			while read -r directory; do
				next_dir="$cur_dir/$directory"
				let next_depth="$cur_depth"+1

				bashctl__print_debug true 3 "next_dir('%s')\n" "$next_dir"

				# RECURSE
				def_names="$(bashctl__resolve_reference "$next_dir" "$remaining_ref_parts" "$next_depth")"

				bashctl__print_debug true 3 "def_names:in_group('%s')\n" "$def_names"

				if [ ! -z "$def_names" ]; then
					def_list="$(bashctl__append "$def_list" "$def_names")"
				fi

# vs. with 'split-join':
#   $(split-join '/' '-1:' "$def_paths")
			done <<EOF
$(printf '%s' "$def_paths" | rev | cut -d '/' -f 1 | rev)
EOF
		fi
	fi

	# Remove blank lines.
	def_list="$(printf '%s' "$def_list" | sed -e '/^$/d')"
	printf '%s' "$def_list"
	return 0
}

# type: capture
# signature: bashctl__get_def_versions cur_dir def_name
# return:
#   -1 if given arguments are invalid.
function bashctl__get_def_versions {
	local cur_dir
	local def_name

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	local def_versions
	local constructed_def_versions

	# Get all versions with def_name in cur_dir -> get filename -> remove hidden files/directories -> get extension.
	# See: Note 3
	def_versions="$(find -L "$cur_dir" -mindepth 1 -maxdepth 1 -type f | rev | cut -d '/' -f 1 | rev | grep "^$def_name\(\|\..*\)$" | sed -e '/^\..*/d')"

	local def_version

	IFS__backup="$IFS"
	IFS=$'\n'
	set -f
	for def_version in $def_versions; do
		IFS="$IFS__backup"

		case "$def_version" in
			*.*) def_version="$(printf '%s' "$def_version" | cut -d '.' -f 2-)";;
			*) def_version='';;
		esac

		if [ -z "$def_version" ]; then
			# '/' is a character that cannot appear in a valid file extension,
			# therefore it can be checked for later.
			def_version='/no-extension'
		fi

		constructed_def_versions="${constructed_def_versions}${constructed_def_versions+$'\n'}${def_version}"

		IFS=$'\n'
	done
	set +f
	IFS="$IFS__backup"

	def_versions="$constructed_def_versions"

	printf '%s' "$def_versions"
	return 0
}

# type: capture
# signature: bashctl__path_to_ref def_path def_name
# return:
#   -1 if given arguments are invalid.
function bashctl__path_to_ref {
	local def_path
	local def_name

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	case "$def_path" in
		*/*)
			printf '%s:%s' "$(printf '%s' "$def_path" | tr '/' ':')" "$def_name"
			;;
		'')
			printf '%s' "$def_name"
			;;
		*)
			printf '%s:%s' "$def_path" "$def_name"
	esac
	return 0
}

# Determine Definition Version
# --------------------------------------------------

# type: capture
# signature: bashctl__select_version cur_dir def_path def_name
# return:
#   -1 if given arguments are invalid.
#   64 to request skipping of taking action on the output of this function by caller,
#     due to input or global variables stating that the definition is to be skipped.
#   65 to request skipping of taking action on the output of this function by caller,
#     due to debugging.
#   66 to request skipping of taking action on the output of this function by caller,
#     due to the output likely being invalid. This is probably caused by invalid input.
function bashctl__select_version {
	local cur_dir
	local def_path
	local def_name

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	local def_versions_exts
	local def_versions_lines
	local def_version_ext
	local def_version_abspath

	local def_version_ext_notfound

	def_versions_exts="$(bashctl__get_def_versions "$cur_dir/$def_path" "$def_name")"
	def_versions_lines="$(printf '%s' "$def_versions_exts" | wc -l)"

	# Single version.
	# *0* lines as there is no newline ('\n') character at the end of the variable.
	if [ "$def_versions_lines" -eq 0 ]; then
		def_version_ext="$def_versions_exts"
		def_version_abspath="$cur_dir/$def_path/$def_name.$def_version_ext"

	# Multiple versions.
	else
		bashctl__print_warning true "definition '%s' has multiple versions:" "$(bashctl__path_to_ref "$def_path" "$def_name")"
		# Instead of just printing the versions found above, print a pretty list with (possibly colored) attributes.
		bashctl__print_msg 'normal' false '%s\n' "$(bashctl__list "$cur_dir" "$def_path" "$def_name")"

		# If we aren't assuming a particular version, then give the user the options and
		# ask them which version to use.
		if [ "$bashctl__assume_version" = '' ]; then
			read -rp "Which version to act on (eg. 'def/sh', or '/skip')? " def_version_ext < /dev/tty

		# If we are assuming a particular version, then just use that one.
		else
			def_version_ext="$bashctl__assume_version"
		fi

		# If the given extension is '', then convert to no extension
		if [ -z "$def_version_ext" ]; then
			def_version_ext='/no-extension'
		fi

		# TODO: Does it need to check for dots (the attribute-delimination character),
		#       and what to do if it finds any?

		# This is a built-in extension (i.e. a special identifier).
		if [ "$(printf '%s' "$def_version_ext" | head -c 1)" = '/' ]; then
			case "$def_version_ext" in
				'/skip')
					bashctl__print_warning true "skipping definition: '%s'" "$(bashctl__path_to_ref "$def_path" "$def_name" >&1)"
					return 65
					;;

				'/no-extension')
					def_version_abspath="$cur_dir/$def_path/$def_name"

					# Check if file exists.
					if [ ! -e "$def_version_abspath" ]; then
						# ${param:+word} = substitute word if param set and not null
						def_version_ext_notfound='/no-extension./not found'

						bashctl__print_msg 'normal' false '%s\n' "$(bashctl__list_version "$def_path" "$def_name" "$def_version_ext_notfound" >&1)"
						bashctl__print_msg 'normal' false '... skipping ...\n'
						return 66
					fi
					;;

				*)
					bashctl__print_error true 'invalid built-in %s' "$ext"
					return 66 # Close enough
					;;
			esac

		# This is a valid extension, not a built-in.
		else
			# Convert from the form 'def/sh' to 'def.sh'.
			def_version_ext="$(printf '%s' "$def_version_ext" | tr '/' '.')"
			def_version_abspath="$cur_dir/$def_path/$def_name.$def_version_ext"

			# Check if file exists.
			if [ ! -e "$def_version_abspath" ]; then
				# ${param:+word} = substitute word if param set and not null
				def_version_ext_notfound="${def_version_ext}${def_version_ext:+.}/not found"

				bashctl__print_msg 'normal' false '%s\n' "$(bashctl__list_version "$def_path" "$def_name" "$def_version_ext_notfound")"
				bashctl__print_msg 'normal' false '... skipping ...\n'
				return 66
			fi
		fi

		# Print a message stating the use of a particular version.
		bashctl__print_debug "using version '%s' of definition '%s'\n" "$def_version_ext" "$(bashctl__path_to_ref "$def_path" "$def_name")"
	fi

	if [ "$bashctl__debug_version_selection" = true -o "$bashctl__debug" -gt 1 ]; then
		bashctl__print_debug '\n'
		bashctl__print_debug "def_version_ext('%s')\n" "$def_version_ext"
		bashctl__print_debug "def_version_abspath('%s')\n" "$def_version_abspath"
	fi
	if [ "$bashctl__debug_version_selection" = true ]; then
		# DEBUG: Return before actually performing any version-specific actions.
		bashctl__print_debug "would have used the above version, but didn't perform any actions on it as you asked (--debug-version-selection)\n"
		return 64
	fi

	printf '%s' "$def_version_ext"
	return 0
}

# Create Action
# --------------------------------------------------

# type: direct
# signature: bashctl__create cur_components_dir def_component def_path def_name
#                            [template [template_options [template_copier
#                            [bashctl_component] ]]]
# return:
#   -1 if given arguments are invalid.
#   1 if creation fails
function bashctl__create {
	local cur_components_dir

	# to
	local def_component
	local def_path
	local def_name

	# template information
	local template
	local template_options
	local template_copier

	# from
	local bashctl_component

	bashctl__arg 'cur_components_dir' "$1" false && \
		cur_components_dir="$1" && shift || \
		return -1

	bashctl__arg 'def_component' "$1" false && \
		def_component="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	bashctl__arg 'template' "$1" true && \
		template="$1" && shift || \
		template="$bashctl__default_template"

	bashctl__arg 'template_options' "$1" true && \
		template_options="$1" && shift || \
		template_options="$bashctl__default_template_options"

	bashctl__arg 'template_copier' "$1" true && \
		template_copier="$1" && shift || \
		template_copier="$bashctl__default_template_copier"

	bashctl__arg 'bashctl_component' "$1" true && \
		bashctl_component="$1" && shift || \
		bashctl_component="$bashctl__component"

	# The `template` function defined in the given template copier is meant to
	# instantiate the template into the given location. However, precisely what
	# this function does is not defined here. See the documentation of the
	# relevant template copier for detailed info.

	# The template copier is sourced in a subshell so that if there is a command,
	# alias, function, etc. already defined in this shell named 'template', the
	# one from this file does not overwrite it. This also makes sure the definition
	# of the `template` function from the template is forgotten once the subshell
	# returns, as it is no longer needed.

	(
		. "$cur_components_dir/$bashctl_component/template-copiers/$template_copier/$template_copier.def.sh"
		# FIXME [1]
		template --create --template="$template" --root="$cur_components_dir" --component="$def_component" --path="$def_path" --name="$def_name" -- $template_options
	)

	if [ $? != 0 ]; then
		bashctl__print_error true "creating new definition failed: template '%s', options '%s' -> '%s'" \
			"$template" "$template_options" "[$def_component]$(bashctl__path_to_ref "$def_path" "$def_name")"
		bashctl__print_warning true "... skipping what has not been done ..."

		return 1
	fi

	return 0
}

# Delete Action
# --------------------------------------------------

# type: direct
# signature: bashctl__delete cur_components_dir component def_path def_name
#                            [template [template_options [template_copier]]]
# return:
#   -1 if given arguments are invalid.
#   1 if deletion fails
function bashctl__delete {
	local cur_components_dir

	# to
	local def_component
	local def_path
	local def_name

	# template information
	local template
	local template_options
	local template_copier

	# from
	local bashctl_component

	bashctl__arg 'cur_components_dir' "$1" false && \
		cur_components_dir="$1" && shift || \
		return -1

	bashctl__arg 'def_component' "$1" false && \
		def_component="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	bashctl__arg 'template' "$1" true && \
		template="$1" && shift || \
		template="$bashctl__default_template"

	bashctl__arg 'template_options' "$1" true && \
		template_options="$1" && shift || \
		template_options="$bashctl__default_template_options"

	bashctl__arg 'template_copier' "$1" true && \
		template_copier="$1" && shift || \
		template_copier="$bashctl__default_template_copier"

	bashctl__arg 'bashctl_component' "$1" true && \
		bashctl_component="$1" && shift || \
		bashctl_component="$bashctl__component"

	# The `template` function defined in the given template copier is meant to
	# delete the files that would have been copied to the given location when
	# created with the given template. However, precisely what this function
	# does is not defined here. See the documentation of the relevant template
	# copier for detailed info.

	# The template copier is sourced in a subshell so that if there is a command,
	# alias, function, etc. already defined in this shell named 'template', the
	# one from this file does not overwrite it. This also makes sure the definition
	# of the `template` function from the template is forgotten once the subshell
	# returns, as it is no longer needed.

	(
		. "$cur_components_dir/$bashctl_component/template-copiers/$template_copier/$template_copier.def.sh"
		# FIXME [1]
		template --delete --template="$template" --root="$cur_components_dir" --component="$def_component" --path="$def_path" --name="$def_name" -- $template_options
	)

	if [ $? != 0 ]; then
		bashctl__print_error true "deleting definition failed: '%s' (reference template '%s', options '%s')" \
			"[$def_component]$(bashctl__path_to_ref "$def_path" "$def_name")" "$template" "$template_options"
		bashctl__print_warning true "... skipping what has not been done ..."

		return 1
	fi

	return 0
}

# List Action
# --------------------------------------------------

# type: direct [OR] capture
# signature: bashctl__colorize_extension ext
# return:
#   -1 if given arguments are invalid.
function bashctl__colorize_extension {
	local ext

	bashctl__arg 'ext' "$1" false && \
		ext="$1" && shift || \
		return -1

	# Built-Ins
	# --------------------
	if [ "$(printf '%s' "$ext" | head -c 1)" = '/' ]; then
		case "$ext" in
			# Black: Not found
			'/not found')
				# This is a kind of error (technically recoverable, though),
				# so put it in bold.
				bashctl__print 'black' true "not found"
				return 0;;

			# Magenta: Special
			'/no-extension')
				# For how this can be it's value, see 'bashctl__get_def_versions'.
				bashctl__print 'magenta' false "no extension"
				return 0;;

			# Invalid built-in
			*)
				bashctl__print_error true 'invalid built-in %s' "$ext"
				return 1;;
		esac
	fi

	# User-Definable
	# --------------------
	case "/$bashctl__fatal_attrs/" in
		*"/$ext/"*)
			bashctl__print 'red' false "$ext"
			return 0;;
	esac
	case "/$bashctl__soft_fail_attrs/" in
		*"/$ext/"*)
			bashctl__print 'blue' false "$ext"
			return 0;;
	esac
	case "/$bashctl__required_attrs/" in
		*"/$ext/"*)
			bashctl__print 'green' false "$ext"
			return 0;;
	esac
	case "/$bashctl__information_attrs/" in
		*"/$ext/"*)
			bashctl__print 'turquoise' false "$ext"
			return 0;;
	esac

	# Orange: unrecognized attrs
	bashctl__print 'orange' false 'unrecognized'
	bashctl__print 'normal' false "($ext)"
	return 0
}

# type: direct [OR] capture
# signature: bashctl__convert_version_extension def_version_extension
# return:
#   -1 if given arguments are invalid.
function bashctl__convert_version_extension {
	local version_extension

	bashctl__arg 'def_version_extension' "$1" false && \
		def_version_extension="$1" && shift || \
		return -1

	local append_slash=false

	IFS__backup="$IFS"
	IFS='.'
	set -f
	for ext in $def_version_extension; do
		IFS="$IFS__backup"

		case "$append_slash" in
			true) printf '/';;
			false) append_slash=true;;
		esac

		bashctl__colorize_extension "$ext"

		IFS='.'
	done
	set +f
	IFS="$IFS__backup"

	return 0
}

# type: direct [OR] capture
# signature: bashctl__list_version def_path def_name def_version_extension
# return:
#   -1 if given arguments are invalid.
function bashctl__list_version {
	local def_path
	local def_name
	local def_version_extension

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	bashctl__arg 'def_version_extension' "$1" false && \
		def_version_extension="$1" && shift || \
		return -1

	local attribute_list
	attribute_list="$(bashctl__convert_version_extension "$def_version_extension")"

	# Note: even though this is printed in 'normal' color, the attribute
	#       list will be colored (or adorned with color-ids if coloring
	#       is disabled).
	bashctl__print_term 'normal' false '%s (%s)\n' "$(bashctl__path_to_ref "$def_path" "$def_name")" "$attribute_list"
	return 0
}

# type: direct
# signature: bashctl__list cur_dir def_path def_name
# return:
#   -1 if given arguments are invalid.
function bashctl__list {
	local cur_dir
	local def_path
	local def_name

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	local def_versions_extensions="$(bashctl__get_def_versions "$cur_dir/$def_path" "$def_name")"
	if [ -z "$def_versions_extensions" ]; then
		bashctl__list_version "$def_path" "$def_name" "/not found"
		return 0
	fi

	local def_version_extension
	while read -r def_version_extension; do
		bashctl__list_version "$def_path" "$def_name" "$def_version_extension"
	done <<EOF
$def_versions_extensions
EOF

	return 0
}

# Source/Run Actions
# --------------------------------------------------

# type: capture
# signature: bashctl__match_attrs [invert_match:'not'] attrs against_attrs
# return:
#   -1 if given arguments are invalid.
#   1 if no match is found.
#   0 if at least one match is found.
function bashctl__match_attrs {
	local invert_match
	local attrs
	local against_attrs

	bashctl__arg 'invert_match' "$1" true \
		'not' && \
		invert_match=true && shift || \
		invert_match=false

	bashctl__arg 'attrs' "$1" false && \
		attrs="$1" && shift || \
		return -1

	bashctl__arg 'against_attrs' "$1" false && \
		against_attrs="$1" && shift || \
		return -1

	local matched_attrs=''
	local has_matched=1
	local attr

	IFS__backup="$IFS"
	IFS='/'
	set -f
	for attr in $against_attrs; do
		IFS="$IFS__backup"

		case "/$attrs/" in
			*/$attr/*)
				if [ "$invert_match" = false ]; then
					if [ "$matched_attrs" = '' ]; then
						matched_attrs="$attr"
						has_matched=0
					else
						matched_attrs="$matched_attrs/$attr"
					fi
				fi
				;;
			*)
				if [ "$invert_match" = true ]; then
					if [ "$matched_attrs" = '' ]; then
						matched_attrs="$attr"
						has_matched=0
					else
						matched_attrs="$matched_attrs/$attr"
					fi
				fi
				;;
		esac

		IFS='/'
	done
	set +f
	IFS="$IFS__backup"

	printf '%s' "$matched_attrs"
	return $has_matched
}

# type: direct
# signature: bashctl__check_attrs attrs
# return:
#   -1 if given arguments are invalid.
#   1 if the given attrs include a fail attribute, or exclude a required attribute.
function bashctl__check_attrs {
	local attrs

	bashctl__arg 'attrs' "$1" false && \
		attrs="$1" && shift || \
		return -1

	local fail_attrs
	local missing_required_attrs
	local has_fail_attrs
	local has_missing_required_attrs

	# Get whitelist and blacklist
	# --------------------
	local check_fail_attrs="$bashctl__fatal_attrs/$bashctl__soft_fail_attrs"
	if [ "$bashctl__fail_unrecognized" = true ]; then
	  check_fail_attrs="$check_fail_attrs/unrecognized(*)"
	fi

	# Check against blacklist
	# --------------------
	fail_attrs="$(bashctl__match_attrs "$attrs" "$check_fail_attrs")"
	has_fail_attrs="$(bashctl__bool $?)"

	if [ "$bashctl__debug_exec_checks" = true -o "$bashctl__debug" -gt 1 ]; then
		bashctl__print_debug "has_fail_attrs('%s')\n" "$has_fail_attrs"
		bashctl__print_debug "fail_attrs('%s')\n" "$fail_attrs"
	fi

	if [ "$has_fail_attrs" = true ]; then
		printf '%s:%s' 'has_fail_attrs' "$fail_attrs"
		return 1
	fi

	# Check against whitelist
	# --------------------
	local check_missing_required_attrs="$bashctl__required_attrs"

	missing_required_attrs="$(bashctl__match_attrs not "$attrs" "$check_missing_required_attrs")"
	has_missing_required_attrs="$(bashctl__bool $?)"

	if [ "$bashctl__debug_exec_checks" = true -o "$bashctl__debug" -gt 1 ]; then
		bashctl__print_debug "has_missing_required_attrs('%s')\n" "$has_missing_required_attrs"
		bashctl__print_debug "missing_required_attrs('%s')\n" "$missing_required_attrs"
	fi

	if [ "$has_missing_required_attrs" = true ]; then
		printf '%s:%s' 'has_missing_required_attrs' "$missing_required_attrs"
		return 1
	fi

	return 0
}

# type: direct
# signature: bashctl__exec cur_dir def_path def_name def_version_ext (exec_type:'run'|'source')
# return:
#   -1 if given arguments are invalid.
function bashctl__exec {
	local cur_dir
	local def_path
	local def_name
	local def_version_ext
	local exec_type

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	def_version_ext="$1" && shift

	bashctl__arg 'exec_type' "$1" false && \
		exec_type="$1" && shift || \
		return -1

	local attrs
	local output
	local reason
	local related_attrs
	local good_exec

	local tmp_backup__color
	tmp_backup__color="$bashctl__color"
	bashctl__color='raw'
	attrs="$(bashctl__convert_version_extension "$def_version_ext")"
	bashctl__color="$tmp_backup__color"

	output="$(bashctl__check_attrs "$attrs")"
	good_exec="$(bashctl__bool $?)"

	if [ "$good_exec" = false ]; then
		# vs. with 'split-join':
		#   reason="$(split-join ':' ':1' "$output")"
		#   related_attrs="$(split-join ':' '1:' "$output")"
		reason="$(printf '%s' "$output" | cut -d ':' -f 1)"
		# This doesn't need a 'case', becuase there will always be at least 2 fields.
		# IF THIS ASSUMTION CHANGES THEN CHANGE THIS CODE!!!!!
		related_attrs="$(printf '%s' "$output" | cut -d ':' -f 2-)"
	fi

	# Unless we're forcing sourcing, if anything is wrong, then don't source.
	if [ "$bashctl__force" = false -a "$good_exec" = false ]; then
		if [ "$reason" = 'has_fail_attrs' ]; then
			bashctl__print_warning true "did not %s '%s' (version: '%s'): matches fail attribute(s) '%s'" \
				"$exec_type" "$(bashctl__path_to_ref "$def_path" "$def_name")" "$attrs" "$related_attrs"
		elif [ "$reason" = 'has_missing_required_attrs' ]; then
			bashctl__print_warning true "did not %s '%s' (version: '%s'): did not match required attribute(s) '%s'" \
				"$exec_type" "$(bashctl__path_to_ref "$def_path" "$def_name")" "$attrs" "$related_attrs"
		fi
	else
		local word

		# If the definition was only sourced due to '--force', then print a warning.
		if [ "$bashctl__force" = true -a "$good_exec" = false ]; then
			if [ "$exec_type" = 'run' ]; then
				word='ran'
			elif [ "$exec_type" = 'source' ]; then
				word='sourced'
			fi

			bashctl__print_warning true "%s '%s' (version: '%s'), as you asked (--force) dispite matching fail attribute(s) '%s'" \
				"$word" "$(bashctl__path_to_ref "$def_path" "$def_name")" "$attrs" "$related_attrs"
		fi

		# If we are debugging the checks then print a message and stop here.
		if [ "$bashctl__debug_exec_checks" = true ]; then
			if [ "$exec_type" = 'run' ]; then
				word='run'
			elif [ "$exec_type" = 'source' ]; then
				word='sourced'
			fi

			# DEBUG: Return before actually sourcing the def.
			bashctl__print_debug "would have %s '%s' (version: '%s'), but didn't as you asked (--debug-exec-checks)\n" \
				"$word" "$(bashctl__path_to_ref "$def_path" "$def_name")" "$attrs"

			return 0

		# If we are not debugging the checks specifically, but are verbosely
		# debugging, then still print the seperator.
		elif [ "$bashctl__debug" -gt 1 ]; then
			bashctl__print_debug '\n'
		fi

		local def_version_abspath="$cur_dir/$def_path/$def_name.$def_version_ext"
		if [ "$exec_type" = 'run' ]; then
			bash "$def_version_abspath"
		elif [ "$exec_type" = 'source' ]; then
			. "$def_version_abspath"
		fi
	fi

	return 0
}

# type: direct
# signature: bashctl__source <args are the same as bashctl__exec, but without 'exec_type'>
# return:
#   -1 if given arguments are invalid.
function bashctl__source {
	bashctl__exec "$@" 'source'
}

# type: direct
# signature: bashctl__run <args are the same as bashctl__exec, but without 'exec_type'>
# return:
#   -1 if given arguments are invalid.
function bashctl__run {
	bashctl__exec "$@" 'run'
}

# Enable/Disable Attribute Actions
# --------------------------------------------------

# type: direct
# signature: bashctl__enable cur_dir def_path def_name def_version_ext attr
# return:
#   -1 if given arguments are invalid.
function bashctl__enable {
	local cur_dir
	local def_path
	local def_name
	local def_version_ext
	local attr

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	def_version_ext="$1" && shift

	bashctl__arg 'attr' "$1" false && \
		attr="$1" && shift || \
		return -1

	local def_version_abspath="$cur_dir/$def_path/$def_name.$def_version_ext"

	output="$(rename "s/\$/\.$attr/" "$def_version_abspath")"
	if [ "$output" != '' ]; then
		bashctl__print_error true "could not rename '%s' (version: '%s')\n  rename output: '%s'" "$(bashctl__path_to_ref "$def_path" "$def_name")" "$def_version_ext" "$output"
	fi

	return 0
}

# type: direct
# signature: bashctl__enable cur_dir def_path def_name def_version_ext attr
# return:
#   -1 if given arguments are invalid.
function bashctl__disable {
	local cur_dir
	local def_path
	local def_name
	local def_version_ext
	local attr

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	def_version_ext="$1" && shift

	bashctl__arg 'attr' "$1" false && \
		attr="$1" && shift || \
		return -1

	local def_version_abspath="$cur_dir/$def_path/$def_name.$def_version_ext"

	output="$(rename "s/\.$attr//" "$def_version_abspath")"
	if [ "$output" != '' ]; then
		bashctl__print_error true "could not rename '%s' (version: '%s')\n  rename output: '%s'" "$(bashctl__path_to_ref "$def_path" "$def_name")" "$def_version_ext" "$output"
	fi

	return 0
}

# Find Action
# --------------------------------------------------

# type: direct
# signature: bashctl__find cur_dir def_path def_name def_version_ext regex
# return:
#   -1 if given arguments are invalid.
function bashctl__find {
	local cur_dir
	local def_path
	local def_name
	local def_version_ext
	local regex

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	def_version_ext="$1" && shift

	bashctl__arg 'regex' "$1" true && \
		regex="$1" && shift || \
		return -1

	local def_version_abspath="$cur_dir/$def_path/$def_name.$def_version_ext"

	# This will strip grep's coloring, which is annoying, but not super-bad.
	local results="$(grep "$regex" "$def_version_abspath")"

	if [ ! -z "$results" ]; then
		bashctl__print_term 'normal' false '\n'
		bashctl__print_term 'normal' false '%s\n' "$(bashctl__path_to_ref "$def_path" "$def_name")"
		bashctl__print_term 'normal' false '%s\n' '--------------------------------------------------'
		bashctl__print_term 'normal' false '%s\n' "$results"
	fi

	return 0
}

# Edit Action
# --------------------------------------------------

# type: direct
# signature: bashctl__edit cur_dir def_path def_name def_version_ext [editor]
# return:
#   -1 if given arguments are invalid.
function bashctl__edit {
	local cur_dir
	local def_path
	local def_name
	local def_version_ext
	local attr

	bashctl__arg 'cur_dir' "$1" false && \
		cur_dir="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	def_version_ext="$1" && shift

	bashctl__arg 'editor' "$1" true && \
		editor="$1" && shift || \
		editor="$bashctl__default_editor"

	local def_version_abspath="$cur_dir/$def_path/$def_name.$def_version_ext"

	# bashctl__edit is called in the context of redirected input (a while
	# loop with read), so make sure it's getting input from the right source
	# (/dev/tty). This isonly useful if $editor is a command-line editor,
	# and in some other circumstances.
	$editor "$def_version_abspath" < /dev/tty

	return 0
}

# Create-Version Action
# --------------------------------------------------

# type: direct
# signature: bashctl__create_version cur_components_dir component def_path def_name
#                                    def_version_ext new_version
# return:
#   -1 if given arguments are invalid.
#   1 if creation fails
function bashctl__create_version {
	local cur_components_dir
	local component
	local def_path
	local def_name

	local def_version_ext
	local new_version

	bashctl__arg 'cur_components_dir' "$1" false && \
		cur_components_dir="$1" && shift || \
		return -1

	bashctl__arg 'component' "$1" false && \
		component="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	bashctl__arg 'def_version_ext' "$1" false && \
		def_version_ext="$1" && shift || \
		return -1

	bashctl__arg 'new_version' "$1" false && \
		new_version="$1" && shift || \
		return -1

	local new_version_ext="$(printf '%s' "$new_version" | tr '/' '.')"
	local def_abspath="$cur_components_dir/$component/$def_path/$def_name"

	bashctl__print_debug true 3 "copy('%s' -> '%s')\n" \
		"$def_abspath.$def_version_ext" "$def_abspath.$new_version_ext"
	cp "$def_abspath.$def_version_ext" "$def_abspath.$new_version_ext"

	if [ $? != 0 ]; then
		bashctl__print_error true "creating new definition version failed: '%s' -> '%s'" \
			"$(bashctl__path_to_ref "$def_path" "$def_name").$def_version_ext" \
			"$(bashctl__path_to_ref "$def_path" "$def_name").$new_version"
		return 1
	fi

	return 0
}

# Delete-Version Action
# --------------------------------------------------

# type: direct
# signature: bashctl__delete_version cur_components_dir component def_path def_name
#                                    def_version_ext new_version
# return:
#   -1 if given arguments are invalid.
#   1 if deletion fails
function bashctl__delete_version {
	local cur_components_dir
	local component
	local def_path
	local def_name
	local def_version_ext

	bashctl__arg 'cur_components_dir' "$1" false && \
		cur_components_dir="$1" && shift || \
		return -1

	bashctl__arg 'component' "$1" false && \
		component="$1" && shift || \
		return -1

	def_path="$1" && shift

	bashctl__arg 'def_name' "$1" false && \
		def_name="$1" && shift || \
		return -1

	bashctl__arg 'def_version_ext' "$1" false && \
		def_version_ext="$1" && shift || \
		return -1

	local def_version_abspath="$cur_components_dir/$component/$def_path/$def_name.$def_version_ext"

	# Remove the file
	bashctl__print_debug true 3 "rm('%s')\n" "$def_version_abspath"
	rm "$def_version_abspath"

	# Check if it worked
	if [ $? != 0 ]; then
		bashctl__print_error true "removing file failed: '%s'" \
			"$(bashctl__path_to_ref "$def_path" "$def_name").$def_version_ext"
		return 1
	fi

	# Check each directory in its path, starting from the immediate parent,
	# for being empty and delete each found that is. Stop on the first directory
	# found that is not empty.
	local abspath="$def_version_abspath"

	# Keep going until we get to the root directory ...
	while [ "$path" = '/' ]; do
		path="$(dirname "$path")"

		if [ -z "$(find "$abspath")" ]; then
			rm -r "$abspath"
		else
			# ... or until we get to a folder with something in.
			break
		fi
	done

	return 0
}

# Main Function
# --------------------------------------------------

# type: direct
# signature: <see help file - `bashctl --help`>
# return: <see help file - `bashctl --help`>
function bashctl__ {
	# The following is a modified version of this: http://stackoverflow.com/a/246128
	local bashctl_source
	local bashctl_dir

	local bashctl_source="${BASH_SOURCE[0]}"

	# resolve $bashctl_source until the file is no longer a symlink
	local bashctl_dir
	local bashctl_source
	while [ -h "$bashctl_source" ]; do
		bashctl_dir="$(cd -P "$( dirname "$bashctl_source" )" && pwd)"
		bashctl_source="$(readlink "$bashctl_source")"

		# If $bashctl_source was a relative symlink, we need to resolve it relative
		# to the path where the symlink file was located.
		[[ $bashctl_source != /* ]] && bashctl_source="$bashctl_dir/$bashctl_source"
	done
	bashctl_dir="$(cd -P "$( dirname "$bashctl_source" )" && pwd)"

	# --------------------------------------------------

	# For both option-scanning loops.
	local set_op
	local option
	local value
	local global_opt

	# Special vars
	local bashctl_set_active_status=''
	local bashctl_update_symlinks=false

	# Used in various places.
	local global_control='reset'

	# ====================================================================================================
	# Parse Special Arguments
	# ====================================================================================================

	while [ "$(printf '%s' "$1" | head -c 1)" = '-' ]; do
		# Whether it is a 'set' (ie. assignment) operation.
		case "$1" in
			*'='*)
				set_op=true
				option="$(printf '%s' "$1" | cut -f 1 -d'=')"
				value="$(printf '%s' "$1" | cut -f 2- -d'=')"
				;;
			*)
				set_op=false
				option="$1"
				value=false
				;;
		esac

		case "$option" in
			# Local, but effects the modification of globals.
			'--global-control')
				if [ "$set_op" = false ]; then
					global_control=''
				elif [ "$set_op" = true ]; then
					case "$value" in
						'get' | 'set' | 'reset' | 'const') global_control="$value";;
						*)
							bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
							return -2
							;;
					esac
				fi
				;;

			'--update-symlinks')
				if [ "$set_op" = false ]; then
					bashctl_update_symlinks=true
				elif [ "$set_op" = true ]; then
					bashctl__print_error true ""
					return -1
				fi
				;;

			'--activate')
				if [ "$set_op" = false ]; then
					bashctl_set_active_status='activate'
				elif [ "$set_op" = true ]; then
					bashctl__print_error true ""
					return -1
				fi
				;;

			'--deactivate')
				if [ "$set_op" = false ]; then
					bashctl_set_active_status='deactivate'
				elif [ "$set_op" = true ]; then
					bashctl__print_error true ""
					return -1
				fi
				;;

			*)
				# If no more special option then break and go onto normal options.
				break
				;;
		esac
		shift
	done

	# A lockfile to deactivate most of bashctl (not including special options/actions)
	# This persists over sessions.
	if [ "$bashctl_set_active_status" = 'activate' ]; then
		if [ -e "$BASH_LIB_COMPONENT_ROOT/.inactive" ]; then
			rm "$BASH_LIB_COMPONENT_ROOT/.inactive"
		else
			bashctl__print 'normal' false '%s\n' 'already active'
		fi
	elif [ "$bashctl_set_active_status" = 'deactivate' ]; then
		if [ -e "$BASH_LIB_COMPONENT_ROOT/.inactive" ]; then
			bashctl__print 'normal' false '%s\n' 'already inactive'
		else
			touch "$BASH_LIB_COMPONENT_ROOT/.inactive"
		fi
	fi

	if [ -e "$BASH_LIB_COMPONENT_ROOT/.inactive" ]; then
		return 2
	fi

	if [ "$bashctl_update_symlinks" = true ]; then
		(
			. "$BASH_LIB_COMPONENT_ROOT/$bashctl__component/bashctl/update-symlinks.def.sh"
			update_symlinks
		)
		return 0
	fi

	bashctl__store_globals "$global_control"

	# ====================================================================================================
	# Parse Normal Arguments
	# ====================================================================================================

	# Action
	local action='none'

	# Action-specific vars
	local help_action
	local create_template
	local delete_template
	local enable_attr
	local disable_attr
	local edit_editor
	local create_version_new_version

	while [ "$(printf '%s' "$1" | head -c 1)" = '-' ]; do
		# Whether it is a 'set' (ie. assignment) operation.
		case "$1" in
			*'='*)
				set_op=true
				option="$(printf '%s' "$1" | cut -f 1 -d'=')"
				value="$(printf '%s' "$1" | cut -f 2- -d'=')"
				;;
			*)
				set_op=false
				option="$1"
				value=false
				;;
		esac

		case "$option" in
			# General
			'-h' | '-?' | '--help')
				action='help'
				if [ "$set_op" = false ]; then
					help_action='bashctl'
				elif [ "$set_op" = true ]; then
					case "$value" in
						'bashctl' | 'help')
							help_action="$value"
							;;

						*)
							bashctl__print_error true "value of option '%s' is invalid: '%s'" "$option" "$value"
							bashctl__restore_globals "$global_control"; return -1
							;;
					esac
				fi
				;;

			# Acts on a reference directly
			'-c' | '--create')
				action='create'
				if [ "$set_op" = false ]; then
					# This will be judged invalid by bashctl__arg and the default uesd instead.
					create_template=''
				elif [ "$set_op" = true ]; then
					# Validation that the used template exists is done when something is created using it.
					create_template="$value"
				fi
				;;
			'-del' | '--delete')
				action='delete'
				if [ "$set_op" = false ]; then
					# This will be judged invalid by bashctl__arg and the default uesd instead.
					delete_template=''
				elif [ "$set_op" = true ]; then
					# Validation that the used template exists is done when it
					# is used as the reference template when deleting something.
					delete_template="$value"
				fi
				;;

			# Version-Independent
			'-l' | '--list') action='list';;

			# Version-Dependent
			'-r' | '--run') action='run';;
			'-s' | '--source') action='source';;

			'-e' | '--enable')
				action='enable'
				if [ "$set_op" = false ]; then
					enable_attr='disabled'
				elif [ "$set_op" = true ]; then
					enable_attr="$value"
				fi
				;;
			'-d' | '--disable')
				action='disable'
				if [ "$set_op" = false ]; then
					disable_attr='disabled'
				elif [ "$set_op" = true ]; then
					disable_attr="$value"
				fi
				;;

			'-f' | '--find' | '-g' | '--grep')
				action='find'
				if [ "$set_op" = false ]; then
					bashctl__print_error true "'-f' or '--find' (or '-g' or '--grep') must have an assignment after it."
					bashctl__restore_globals "$global_control"; return -1
				elif [ "$set_op" = true ]; then
					find_regex="$value"
				fi
				;;

			'-ed' | '--edit')
				action='edit'
				if [ "$set_op" = false ]; then
					# This will be judged invalid by bashctl__arg and the default uesd instead.
					edit_editor=''
				elif [ "$set_op" = true ]; then
					edit_editor="$value"
					local command="$(printf '%s' "$edit_editor" | cut -d ' ' -f 1)"
					bashctl__print_debug "command('%s')" "$command"

					if ! type "$command" > /dev/null; then
						bashctl__print_error true "value of option '%s' is invalid (no such command): '%s'" "$option" "$command"
						bashctl__restore_globals "$global_control"; return -1
					fi
				fi
				;;

			'-cv' | '--create-version')
				action='create-version'
				if [ "$set_op" = false ]; then
					# This will be judged invalid by bashctl__arg and the default uesd instead.
					create_version_new_version=''
				elif [ "$set_op" = true ]; then
					# Validation that the used base version exists is done when something is created using it.
					create_version_new_version="$value"
				fi
				;;
			'-dv' | '--delete-version') action='delete-version';;

			*)
				bashctl__set_global_option "$option" "$set_op" "$value"
				global_opt=$?

				case "$global_opt" in
					0)
						# Matched something, nothing wrong.
						;;
					1)
						bashctl__print_error true "unrecognised option: '%s'" "$option"
						bashctl__restore_globals "$global_control"; return -1
						;;
					*)
						# 'bashctl__set_global_option' will have already printed whatever is needed.
						bashctl__restore_globals "$global_control"; return -1
						;;
				esac
				;;
		esac
		shift
	done

	# If we are getting globals then print them.
	if [ "$global_control" = 'get' ]; then
		bashctl__print_globals "$global_control"
	fi

	# If we are getting or setting globals, then don't perform any actions
	case "$global_control" in
		'get' | 'set')
			return 0;;
	esac

	if [ "$action" = 'none' ]; then
		# If someone just runs `bashctl`, this is a friendly message saying:
		#   "Don't worry, you didn't just do something disastrous with no output saying what you just did."
		bashctl__print 'normal' false '%s\n' 'nothing to do, exiting ...'

	elif [ "$action" = 'help' ]; then
		case "$help_action" in
			'bashctl') cat "$bashctl_dir/help/bashctl.help.txt";;
			'help') cat "$bashctl_dir/help/bashctl-help.help.txt";;
		esac
		bashctl__restore_globals "$global_control"; return 0
	fi

	# ====================================================================================================
	# Perform Actions on References
	# ====================================================================================================

	# Used in multiple places
	local ref
	local def_path
	local def_name

	local component_ref
	local component

	case "$action" in
		'create' | 'delete')
			for component_ref in "$@"; do
				case "$component_ref" in
					\[*\]*)
						component="$(printf '%s' "$component_ref" | tail -c +2 | rev | cut -d ']' -f 2- | rev)"

						case "$component_ref" in
							*:*) ref="$(printf '%s' "$component_ref" | cut -d ']' -f 2-)";;
							*) ref='';;
						esac
						;;

					*)
						bashctl__print_error true "component must be given: '%s'" "$component_ref" >&2
						bashctl__restore_globals "$global_control"; return 0
						;;
				esac

				# vs. with 'split-join' (the 'case' is only needed with 'cut'):
				#   def_path="$(split-join ':' ':-1' "$ref" | tr ':' '/')"
				#   def_name="$(split-join ':' '-1:' "$ref" >&1)"
				case "$ref" in
					*:*) def_path="$(printf '%s' "$ref" | rev | cut -d ':' -f 2- | rev | tr ':' '/')";;
					*) def_path='';;
				esac
				def_name="$(printf '%s' "$ref" | rev | cut -d ':' -f 1 | rev)"

				case "$action" in
					# TODO: These also take two optional arguments ('template_options' and 'template_copier') -
					#       how, if at all, should these be given?
					'create')
						bashctl__create "$BASH_LIB_COMPONENT_ROOT" "$component" "$def_path" "$def_name" "$create_template";;
					'delete')
						bashctl__delete "$BASH_LIB_COMPONENT_ROOT" "$component" "$def_path" "$def_name" "$delete_template";;
				esac
			done

			bashctl__restore_globals "$global_control"; return 0
			;;
	esac

	# ====================================================================================================
	# Find Definitions
	# ====================================================================================================

	# Full list of definitions matched against all reference groups/defs.
	local def_list=''

	case "$action" in
		'create-version' | 'delete-version')
			for component_ref in "$@"; do
				case "$component_ref" in
					\[*\]*)
						component="$(printf '%s' "$component_ref" | tail -c +2 | rev | cut -d ']' -f 2- | rev)"

						case "$component_ref" in
							*:*) ref="$(printf '%s' "$component_ref" | cut -d ']' -f 2-)";;
							*) ref='';;
						esac
						;;

					*)
						bashctl__print_error true "component must be given: '%s'" "$component_ref" >&2
						bashctl__restore_globals "$global_control"; return 0
						;;
				esac

				# Sets $def_list to the real set of files in the bash components library.
				def_list="$(bashctl__append "$def_list" "$component/$(bashctl__resolve_reference "$BASH_LIB_ROOT" "$ref")")"
			done
			;;

		*)
			for ref in "$@"; do
				# Sets $def_list to the symlinked set of files in the bash library.
				def_list="$(bashctl__append "$def_list" "$(bashctl__resolve_reference "$BASH_LIB_ROOT" "$ref")")"
			done
			;;
	esac

	def_list="$(printf '%s' "$def_list" | sort | uniq)"

	if [ "$bashctl__debug_matches" = true -o "$bashctl__debug" -gt 1 ]; then
		bashctl__print_debug true 1 "defs('%s')\n" "$def_list"
	fi
	if [ "$bashctl__debug_matches" = true ]; then
		# DEBUG: Exit before actually performing any actions on the matches.
		bashctl__restore_globals "$global_control"; return 0
	fi

	# If there is nothing to perform actions on, then don't.
	if [ -z "$def_list" ]; then
		bashctl__restore_globals "$global_control"; return 0
	fi

	# ====================================================================================================
	# Perform Other Actions
	# ====================================================================================================

	# Dynamically set the 'def' attribute.
	if [ "$global_control" != 'const' ]; then
		case "$action" in
			'run')
				local fatal_attrs_backup="$bashctl__fatal_attrs"
				bashctl__fatal_attrs="$bashctl__fatal_attrs/def"
				;;
			'source')
				local required_attrs_backup="$bashctl__required_attrs"
				bashctl__required_attrs="$bashctl__required_attrs/def"
				;;
			*)
				local information_attrs_backup="$bashctl__information_attrs"
				bashctl__information_attrs="$bashctl__information_attrs/def"
				;;
		esac
	fi

	local def
	while read -r def; do
		# These two actions require a component to be specified as well. This
		# gets the component given, which was added to $def_list earlier
		# (therefore it's now in $def).

		case "$action" in
			'create-version' | 'delete-version')
				component="$(printf '%s' "$def" | cut -d '/' -f 1)"
				def="$(printf '%s' "$def" | cut -d '/' -f 2-)"
				bashctl__print_debug true 2 "component('%s')\n" "$component"
				;;
		esac

		# vs. with 'split-join' (the 'case' is only needed with 'cut'):
		#   def_path="$(split-join '/' ':-1' "$def" >&1)"
		#   def_name="$(split-join '/' '-1:' "$def" >&1)"
		case "$def" in
			*/*) def_path="$(printf '%s' "$def" | rev | cut -d '/' -f 2- | rev)";;
			*) def_path='';;
		esac
		def_name="$(printf '%s' "$def" | rev | cut -d '/' -f 1 | rev)"

		bashctl__print_debug true 2 "def_path('%s')\n" "$def_path"
		bashctl__print_debug true 2 "def_name('%s')\n" "$def_name"

		# Version-Independent Actions
		# --------------------------------------------------

		case "$action" in
			'list')
				bashctl__list "$BASH_LIB_ROOT" "$def_path" "$def_name";;
		esac

		# If the action was a version-independent action, then skip the
		# rest of this loop.
		case "$action" in
			'list')
				continue;;
		esac

		# Determine Definition Version
		# --------------------------------------------------

		# These cannot be combined, as 'local' is a (built-in) command,
		# so will return it's own status and hide the return value of
		# bashctl__select_version.
		local version
		version="$(bashctl__select_version "$BASH_LIB_ROOT" "$def_path" "$def_name")"
		local ret_val=$?

		bashctl__print_debug true 2 "version('%s')\n" "$version"

		# Skip due to:
		#   - explicit input OR bashctl__assume_version global
		#   - debugging
		#   - invalid input OR bashctl__assume_version global
		case $ret_val in
			64 | 65 | 66)
				continue;;
		esac
		unset ret_val

		# Version-Dependent Actions
		# --------------------------------------------------

		case "$action" in
			'run')
				bashctl__run "$BASH_LIB_ROOT" "$def_path" "$def_name" "$version";;
			'source')
				bashctl__source "$BASH_LIB_ROOT" "$def_path" "$def_name" "$version";;

			'enable')
				bashctl__enable "$BASH_LIB_ROOT" "$def_path" "$def_name" "$version" "$enable_attr";;
			'disable')
				bashctl__disable "$BASH_LIB_ROOT" "$def_path" "$def_name" "$version" "$disable_attr";;

			'find')
				bashctl__find "$BASH_LIB_ROOT" "$def_path" "$def_name" "$version" "$find_regex";;
			'edit')
				bashctl__edit "$BASH_LIB_ROOT" "$def_path" "$def_name" "$version" "$edit_editor";;

			'create-version')
				bashctl__create_version "$BASH_LIB_COMPONENT_ROOT" "$component" "$def_path" "$def_name" "$version" "$create_version_new_version";;
			'delete-version')
				bashctl__delete_version "$BASH_LIB_COMPONENT_ROOT" "$component" "$def_path" "$def_name" "$version";;
		esac
	done <<EOF
$def_list
EOF

	# Restore the attribute lists from before dynamically setting the 'def' attribute.
	if [ "$global_control" != 'const' ]; then
		case "$action" in
			'run')
				bashctl__fatal_attrs="$fatal_attrs_backup";;
			'source')
				bashctl__required_attrs="$required_attrs_backup";;
			*)
				bashctl__information_attrs="$information_attrs_backup";;
		esac
	fi

	bashctl__restore_globals "$global_control"; return 0
}

# User-Friendly Wrapper functions
# --------------------------------------------------

# Note:
#   The const version of all of the following functions should **always** be
#   used in cases where one of these functions is, or may be, called while
#   being sourced due to a call of any non-const bashctl function.

#   This is related to the 'flow' of global variables in the cases of 1-level or
#   higher recursion. See 'Bug 3' in 'misc-info/src-global-var-bugs.txt' for a
#   detailed explanation of why this is necessary.

# Note:
#   I haven't put function attributes on these functions, as they're not useful
#   enough to justify the space the comments take up.

function bashctl {
	bashctl__ "$@" 3>&1 4>&1
	return $?
}

function bashctl-set {
	bashctl --global-control='set' "$@"
	return $?
}

function bashctl-get {
	bashctl --global-control='get'
	return $?
}

function src {
	bashctl --source "$@"
	return $?
}

function run {
	bashctl --run "$@"
	return $?
}

# Const Versions
# --------------------
# (of functions that need a const version)

function const-bashctl {
	bashctl --global-control='const' "$@"
}

function const-src {
	const-bashctl --source "$@"
	return $?
}

function const-run {
	const-bashctl --run "$@"
	return $?
}
