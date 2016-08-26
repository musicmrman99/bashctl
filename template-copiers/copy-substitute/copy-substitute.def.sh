# Utilities
# --------------------------------------------------

template__force_builtins=false
template__debug_level=0

function template__error {
	bashctl__print_error "$@"
}

function template__warning {
	bashctl__print_warning "$@"
}

function template__debug {
	bashctl__print_debug "$@"
}

function template__mkdir {
	local dirpath="$1"

	if [ -f "$dirpath" ]; then
		template__print_error "file exists but should be a directory: '%s'" "$dirpath"
		return 1
	elif [ -d "$dirpath" ]; then
		: # directory already exists
	else
		mkdir -p "$dirpath"
	fi

	return 0
}

# Components
# --------------------------------------------------

# Check globals
# --------------------

function template__check_globals {
	# These are errors.
	if [ -z "$template__template" ]; then
		template__error true '%s' "the '-t' or '--template' option must be given"
		return 1
	fi

	if [ -z "$template__root" ]; then
		template__error true '%s' "the '-r' or '--root' option must be given"
		return 1
	fi

	if [ -z "$template__path" ]; then
		template__error true '%s' "the '-p' or '--path' option must be given"
		return 1
	fi

	if [ -z "$template__name" ]; then
		template__error true '%s' "the '-n' or '--name' option must be given"
		return 1
	fi
}

# Generic errors
# --------------------

function template__invalid_substitution_name_error {
	local name=$1

	template__error true "invalid substitution: '%s'" "$name"
	template__warning true '... skipping substitution ...'
}

function template__invalid_substitution_modification_error {
	local mod=$1

	template__error true "invalid substitution modification: '%s'" "$mod"
	template__warning true '... skipping substitution modification ...'
}

# Substitution modification components
# --------------------

function template__sub_mod__del_until_first_char_in_set {
	local string=$1
	local set=$2

	while [[ ! ${string:0:1} =~ [$set] ]]; do
		string=${string:1}
		if [[ -z $string ]]; then return 1; fi
	done

	printf '%s' "$string"
	return 0
}

function template__sub_mod__del_until_all_chars_in_set {
	local string=$1
	local set=$2

	local constructed_string=''
	IFS__backup=$IFS
	IFS=''
	set -f
	for char in $string; do
		IFS=$IFS__backup

		if [[ $char =~ [$set] ]]; then
			constructed_string=${constructed_string}${char}
		fi

		IFS=''
	done
	set +f
	IFS=$IFS__backup

	if [[ -z $constructed_string ]]; then
		return 1
	fi

	printf '%s' "$constructed_string"
	return 0
}

# Substitution modifications
# --------------------

function template__sub_mod__funcsafe {
	local substitution="$1"
	local tmp
	local first_char
	local rest

	# Replace:
	#   ' ' -> '_'
	#   '/' -> '__'
	substitution=$(printf '%s' "$substitution" | \
		sed -e 's/[ ]/_/g;s/[/]/__/g')

	# Then remove everything that is not a valid character in a function name:
	tmp=$(template__sub_mod__del_until_first_char_in_set "$substitution" '^/')
	[[ $? != 0 ]] && return 1
	first_char=${tmp:0:1}

	tmp=$(template__sub_mod__del_until_all_chars_in_set "${substitution:1}" '^/')
	if [[ $? = 0 ]]; then
		rest=$tmp
	fi

	substitution=${first_char}${rest}
	printf '%s' "$substitution"
	return 0
}

function template__sub_mod__varsafe {
	local substitution="$1"
	local tmp
	local first_char
	local rest

	# Replace:
	#   '-' or ' ' -> '_'
	#   '/' -> '__'
	substitution=$(printf '%s' "$substitution" | \
		sed -e 's/[- ]/_/g;s/[/]/__/g')

	# Then remove everything that is not a valid character in a variable name:
	tmp=$(template__sub_mod__del_until_first_char_in_set "$substitution" 'a-zA-Z_')
	[[ $? != 0 ]] && return 1
	first_char=${tmp:0:1}

	tmp=$(template__sub_mod__del_until_all_chars_in_set "${substitution:1}" 'a-zA-Z1-9_')
	if [[ $? = 0 ]]; then
		rest=$tmp
	fi

	substitution=${first_char}${rest}
	printf '%s' "$substitution"
	return 0
}

function template__sub_mod__bashctl_format {
	local substitution="$1"

	substitution="$(printf '%s' "$substitution" | tr '/' ':')"

	printf '%s' "$substitution"
	return 0
}

#function template__sub_mod__ {
#	local substitution="$1"
#	local tmp
#
#	# Do something to $substitution, tmp is often useful as a staging variable,
#   # until the return value of the substitution function is checked.
#
#	printf '%s' "$substitution"
#	return 0
#}

# Substitution functions
# --------------------

function template__template_substitute {
	local path="$1"; shift
	local sub_ref="$1"; shift
	local sub_str="$1"; shift

	local substitution
	local substitution_ret

	# If the path doesn't exist, then FAIL.
	printf "path('%s')\n" "$path" >&4
	if [ ! -e "$path" ]; then return 1; fi
	printf 'path:valid\n' >&4

	# Check if the path is a substitution script, or list of locations.
	printf "head_val('%s')\n" "$(head -n 1 "$path")" >&4
	if [ "$(head -n 1 "$path")" = '[list]' ]; then
		# Interpret the given path as a list of suffixes to the substitution
		# path, pointing to other possible locations of a substitution script,
		# or of another list of locations.

		# Initialize substitution_ret to a non-zero value.
		# (ie. invalid until set otherwise)
		substitution_ret=1

		local path_entry
		local path_entry_full
		local i=0

		while read -r path_entry; do
			[ $i -eq 0 ] && let i=$i+1 && continue

			path_entry_full="$(dirname "$path")/$path_entry"
			printf "path_entry_full('%s')\n" "$path_entry_full" >&4

			# If this listed path doesn't exist, then try the next.
			if [ ! -e "$path_entry_full" ]; then continue; fi

			# If it does exist then:
			# ----- RECURSE -----
			substitution="$(template__template_substitute "$path_entry_full" "$sub_ref" "$sub_str")"
			substitution_ret=$?

			# If that doesn't work, then FAIL.
			if [ "$substitution_ret" != 0 ]; then
				return 1

			# If it did work, then stop here.
			else
				break
			fi
		done < "$path"

		# If nothing was found/valid, then FAIL.
		if [ "$substitution_ret" != 0 ]; then return 1; fi
	else
		# Interpret the given path as a substitution script.

		printf 'path:substitution-script\n' >&4

		substitution="$(
			. "$path"
			ret_val=$?
			if [ $ret_val != 0 ]; then exit $ret_val; fi

			# If the substitution string is empty, then this is an identifier
			# substitution. If it's not, then this is a modification substitution.
			if [ -z "$sub_str" ]; then
				substitute-identifier "$sub_ref" "$@"
			else
				substitute-modifier "$sub_str" "$sub_ref" "$@"
			fi
			exit $?
		)"
		substitution_ret=$?

		# If invalid, then FAIL.
		if [ "$substitution_ret" != 0 ]; then return 1; fi
	fi

	printf "substitution('%s')\n" "$substitution" >&4
	printf '%s' "$substitution"
	return 0
}

function template__substitute_str {
	local string
	if [[ $1 = '--stdin' ]]; then
		string="$(cat /dev/stdin)"
	else
		string=$1
	fi
	shift

	template__debug true 3 "str:before-substitution('%s')\n" "$string"

	local match
	local new_string=$string

	local sub_name
	local sub_mods
	local substitution

	local template_path
	local template_substitution
	local template_substitution_ret

	local tmp

	# Substitution format:
	# (Things surrounded by '(' and ')' should be substituted for their appropriate
	#  value and things surrounded by '[' and ']' are optional. Every other symbol
	#  is literal)
	#   <{(name)[:(modifier)[,...]]}>
	# eg.
	#   <{name:varsafe}>

	# from: http://tldp.org/LDP/abs/html/string-manipulation.html
	match="$(expr match "$new_string" '.*<{\(.*\)}>')"

	while [[ $match != '' ]]; do
		# Reset substitution
		substitution=''

		# Get match value (eg. 'name') and modifiers (eg. 'varsafe')
		sub_name=$(printf '%s' "$match" | cut -d ':' -f 1)
		case "$match" in
			*:*)
				sub_mods=$(printf '%s' "$match" | cut -d ':' -f 2);;
			*)
				sub_mods='';;
		esac

		# Set the replacement string according to the sub_name
		case "$sub_name" in
			'template')
				substitution=$template__template;;
			'root')
				substitution=$template__root;;
			'path')
				substitution=$template__path;;
			'name')
				substitution=$template__name;;

			*)
				template_path="$template__root/templates/$template__template"

				printf "template_path('%s')\n" "$template_path" >&4
				printf "sub_name('%s')\n" "$sub_name" >&4

				# First, try the template's own substitution script.
				template_substitution="$(template__template_substitute "$template_path/substitute-identifier.def.sh" "$sub_name" '' "$@" >&1)"
				template_substitution_ret=$?

				# If that doesn't work, then try the file containing other
				# possible locations.
				if [ "$template_substitution_ret" != 0 ]; then
					template_substitution="$(template__template_substitute "$template_path/substitute-identifier.txt" "$sub_name" '' "$@" >&1)"
					template_substitution_ret=$?
				fi

				# If it still doesn't work, then issue an error and exit.
				if [ "$template_substitution_ret" != 0 ]; then
					template__invalid_substitution_name_error "$sub_name"
					substitution="<!{${sub_name}${sub_mods:+:$sub_mods}}!>"

				# If it does work, use it.
				else
					substitution="$template_substitution"
				fi
				;;
		esac

		# If not an invalid substitution ...
		case "$substitution" in
		'<!{'*'}!>') ;;
		*)
			# Modify the replacement string according to sub_mods
			IFS__backup=$IFS
			IFS=','
			set -f
			for sub_mod in $sub_mods; do
				IFS="$IFS__backup"

				case "$sub_mod" in
					# Built-in substitution modifications
					# --------------------

					'funcsafe')
						tmp="$(template__sub_mod__funcsafe "$substitution" >&1)"
						[[ $? != 0 ]] && template__invalid_substitution_modification_error "$sub_mod"
						substitution=$tmp
						;;

					'varsafe')
						tmp="$(template__sub_mod__varsafe "$substitution" >&1)"
						[[ $? != 0 ]] && template__invalid_substitution_modification_error "$sub_mod"
						substitution=$tmp
						;;

					'bashctl-reference')
						tmp="$(template__sub_mod__bashctl_format "$substitution" >&1)"
						[[ $? != 0 ]] && template__invalid_substitution_modification_error "$sub_mod"
						substitution=$tmp
						;;

					# Template-specific substitution modifications
					# --------------------

					*)
						template_path="$template__root/templates/$template__template"

						printf "template_path('%s')\n" "$template_path" >&4
						printf "sub_mod('%s')\n" "$sub_mod" >&4

						# First, try the template's own substitution modification script.
						template_substitution="$(template__template_substitute "$template_path/substitute-modifier.def.sh" "$sub_mod" "$substitution" "$@" >&1)"
						template_substitution_ret=$?

						# If that doesn't work, then try the file containing other
						# possible locations.
						if [ "$template_substitution_ret" != 0 ]; then
							template_substitution="$(template__template_substitute "$template_path/substitute-modifier.txt" "$sub_mod" "$substitution" "$@" >&1)"
							template_substitution_ret=$?
						fi

						# If it still doesn't work, then issue an error and skip this modification.
						if [ "$template_substitution_ret" != 0 ]; then
							template__invalid_substitution_modification_error "$sub_mod"

						# If it does work, use it.
						else
							substitution="$template_substitution"
						fi
						;;
				esac

				IFS=','
			done
			set +f
			IFS=$IFS__backup
			;;
		esac

		# Replace the substring of the final string
		# sed 's/[\/&]/\\&/g' = escape all '\', '/' and '&' characters (or sed will interpret them)
		substitution_escaped="$(printf '%s' "$substitution" | sed 's/[\/&]/\\&/g')"

		# from: http://stackoverflow.com/a/9453461
		new_string="$(printf '%s' "$new_string" | sed -e "0,/<{$match}>/{s/<{$match}>/$substitution_escaped/}")"

		# Get the next match
		match="$(expr match "$new_string" '.*<{\(.*\)}>')"
	done

	template__debug true 3 "str:after-substitution('%s')\n" "$new_string"
	printf '%s\n' "$new_string"
	return 0
}

function template__substitute {
	local filepath="$1"; shift

	cat "$filepath" | template__substitute_str --stdin "$@" > /tmp/substituted-file.default.template
	cp -f /tmp/substituted-file.default.template "$filepath"
	rm /tmp/substituted-file.default.template

	return 0
}

# Main Function
# --------------------------------------------------

function template {
	# The following is a modified version of this: http://stackoverflow.com/a/246128
	local template_source
	local template_dir

	template_source="${BASH_SOURCE[0]}"

	# resolve $template_source until the file is no longer a symlink
	while [ -h "$template_source" ]; do
		template_dir="$(cd -P "$( dirname "$template_source" )" && pwd)"
		template_source="$(readlink "$template_source")"

		# if $template_source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
		[[ $template_source != /* ]] && template_source="$template_dir/$template_source"
	done
	template_dir="$(cd -P "$( dirname "$template_source" )" && pwd)"

	# ------------------------------------------------------------

	# Option parsing vars
	local set_op
	local option
	local value

	# Action
	local action='help'

	# Action-specific vars
	local help_action='template'

	# General vars
	export template__template=''
	export template__root=''
	export template__path=''
	export template__name=''

	while [ "${1:0:1}" = '-' ]; do
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
			# Special options
			# --------------------
			'-D' | '--debug')
				if [ "$set_op" = false ]; then
					template__debug_level=1
				elif [ "$set_op" = true ]; then
					template__debug_level="$value"
				fi
				;;

			'-B' | '--force-builtins')
				if [ "$set_op" = false ]; then
					template__force_builtins=true
				elif [ "$set_op" = true ]; then
					template__force_builtins="$value"
				fi
				;;

			# Action Options
			# --------------------

			'-h' | '-?' | '--help')
				action='help'
				if [ "$set_op" = false ]; then
					help_action='template'
				elif [ "$set_op" = true ]; then
					case "$value" in
						'template' | 'help')
							help_action="$value"
							;;

						*)
							template__error true "value of option '%s' is invalid: '%s'" "$option" "$value"
							return 1
							;;
					esac
				fi
				;;

			'-c' | '--create') action='create';;
			'-d' | '--delete') action='delete';;

			# Other Options
			# --------------------

			'-t' | '--template')
				if [ "$set_op" = false ]; then
					template__error true "'-t' or '--template' must have an assignment after it."
					return 1
				elif [ "$set_op" = true ]; then
					template__template="$value"
				fi
				;;

			'-r' | '--root')
				if [ "$set_op" = false ]; then
					template__error true "'-r' or '--root' must have an assignment after it."
					return 1
				elif [ "$set_op" = true ]; then
					template__root="$value"
				fi
				;;

			'-p' | '--path')
				if [ "$set_op" = false ]; then
					template__error true "'-p' or '--path' must have an assignment after it."
					return 1
				elif [ "$set_op" = true ]; then
					template__path="$value"
				fi
				;;

			'-n' | '--name')
				if [ "$set_op" = false ]; then
					template__error true "'-n' or '--name' must have an assignment after it."
					return 1
				elif [ "$set_op" = true ]; then
					template__name="$value"
				fi
				;;

			'--')
				shift
				break
				;;

			*)
				template__error true "unrecognised option: '%s'" "$option"
				return 1
				;;
		esac
		shift
	done

	if [ "$action" = 'help' ]; then
		case "$help_action" in
			'template') cat "$template_dir/help/copy-substitute.help.txt";;
			'help' | 'create' | 'remove' | 'substitutions')
				cat "$template_dir/help/copy-substitute-$help_action.help.txt";;
		esac
		return 0
	fi

	# Check all the required options were given.
	template__check_globals
	if [[ $? != 0 ]]; then return 1; fi

	# Get the full path to the given template and that path's length in chars.
	local template_path="$template__root/templates/$template__template"
	template_path="${template_path%/}"

	# 'x' = padding, ie. start_char=len+1
	local template_path_len="$(printf '%s' "x$template_path" | wc -c)"

	template__debug true 2 "template_path('%s')\n" "$template_path"
	template__debug true 2 "template_path_len('%s')\n" "$template_path_len"
	template__debug true 2 '\n'

	# Check the template exists
	if [ ! -d "$template_path" ]; then
		template__error true "template directory does not exist: '%s'" "$template_path"
		return 2
	fi

	# Find all files needed.
	# Note: '-L' = dereference symlinks
	# Note: dirs is meant to include the template directory itself.
	# Note: files must exclude the files 'substitute-identifier.def.sh' and
	#       'substitute-modifier.def.sh' in the root of the template, because
	#       these are special files to template__substitute_str.
	local template_dirs="$(find -L "$template_path" -type d)"
	local template_files="$(find -L "$template_path" -type f -a ! \( \
-path "$template_path/substitute-identifier.def.sh" -o \
-path "$template_path/substitute-modifier.def.sh" -o \
-path "$template_path/substitute-identifier.txt" -o \
-path "$template_path/substitute-modifier.txt" \))"

	template__debug true 2 "template_dirs('%s')\n" "$template_dirs"
	template__debug true 2 "template_files('%s')\n" "$template_files"

	# Determine the order in which to loop through the items.
	# When creating new instances of a template, directories must exist before
	# copying files to them and when deleting instances of a template, all files
	# should be removed before checking for empty directories.
	local template_items
	case "$action" in
		'create')
			template_items="$template_dirs"$'\n'"$template_files";;
		'delete')
			template_items="$template_files"$'\n'"$template_dirs";;
	esac

	template__debug true 2 "template_items('%s')\n" "$template_items"
	template__debug true 2 '\n'

	# Create/Delete files and directories in the order determined above.
	while read -r template_item_path; do
		template__debug true 2 "template_item_path('%s')\n" "$template_item_path"

		# Determine the new path to copy to (create action), or the path to delete (delete action).
		local template_item_path_suffix="$(printf '%s' "$template_item_path" | tail -c +$template_path_len)"
		local new_item_path_suffix="$(template__substitute_str "$template_item_path_suffix" "$@" 1>&1)"
		local new_item_path="$template__root/$template__path/$new_item_path_suffix"

		template__debug true 2 "template_item_path_suffix('%s')\n" "$template_item_path_suffix"
		template__debug true 2 "new_item_path_suffix('%s')\n" "$new_item_path_suffix"
		template__debug true 2 "new_item_path('%s')\n" "$new_item_path"

		case "$action" in
			'create')
				# If the item to copy is a directory, then create a new directory at the new path.
				if [ -d "$template_item_path" ]; then
					template__debug true 2 "mkdir('%s')\n" "$new_item_path"
					template__mkdir "$new_item_path"

					if [ "$?" != 0 ]; then
						template__error true 'failed to make group: %s' "$template_item_path"
						return 2
					fi

				# If the item to copy is a file, then copy it over.
				elif [ -f "$template_item_path" ]; then
					template__debug true 2 "copy('%s' -> '%s')\n" "$template_item_path" "$new_item_path"
					# Note: '-L' = dereference symlinks
					cp -L "$template_item_path" "$new_item_path"

					if [ "$?" != 0 ]; then
						template__error true 'failed to make file: %s' "$template_item_path"
						return 2
					fi

					# Parse the file and replace substitution specifiers.
					template__debug true 2 "substitute('%s')\n" "$new_item_path"
					template__substitute "$new_item_path" "$@"
				fi
				;;

			'delete')
				# If the item is a file, then delete it.
				if [ -f "$new_item_path" ]; then
					template__debug true 2 "remove:file('%s')\n" "$new_item_path"
					rm "$new_item_path"

					if [ "$?" != 0 ]; then
						template__error true 'failed to delete file: %s' "$new_item_path"
						return 2
					fi

				# If the item to copy is a directory, then delete it if there is nothing left in it.
				elif [ -d "$new_item_path" ]; then
					# If this loop has deleted a directory above this one, then this
					# directory will have already been deleted with it, so skip it.
					if [ ! -d "$new_item_path" ]; then continue; fi

					# What's left in this directory?
					# Note: I'm not sure whether the '-L' is a good idea in this
					#       case, but I'm including it anyway.
					remaining="$(find -L "$new_item_path" -type f)"
					template__debug true 3 "remaining:in-directory('%s')\n" "$remaining"

					# If nothing, then delete it.
					if [ -z "$remaining" ]; then
						template__debug true 2 "remove:group('%s')\n" "$new_item_path"
						rm -r "$new_item_path"

						if [ "$?" != 0 ]; then
							template__error true 'failed to delete group: %s' "$new_item_path"
							return 2
						fi
					fi
				fi
				;;
		esac

		template__debug true 2 '\n'
	done <<EOF
$template_items
EOF
}

