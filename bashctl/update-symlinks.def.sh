# Global Functions
# ----------------------------------------------------------------------------------------------------

# Documentation Requirements
# --------------------------------------------------

# See '/DOCUMENTATION.md'

# Update Symlinks
# --------------------------------------------------

# type: direct
# signature: update_symlinks__match [--all] [--not] string
# stdin: patterns
# return:
#   0 if:
#     ''            = string matches any line of patterns
#     '--not'       = string fails to match one line of patterns
#     '--all'       = string matches all lines of patterns
#     '--all --not' = string matches no lines of patterns
#   1 if not 0
function update_symlinks__match {
	local return_val=0

	local not=''
	local all=false

	while [ "$(printf '%s' "$1" | head -c 1)" = '-' ]; do
		case "$1" in
			'-n' | '--not') not='v';;
			'-a' | '--all') all=true;;
		esac
		shift
	done

	# If 'all', then invert return value and 'not' status
	if [ "$all" = true ]; then
		return_val=$((! $return_val))

		case "$not" in
			'') not='v';;
			'v') not='';;
		esac
	fi

	while read -r pattern; do
		if [ -z "$pattern" ]; then continue; fi
		if [ -n "$(printf '%s' "$1" | grep -E$not "^$pattern$")" ]; then
			return $return_val
		fi
	done

	return $((! $return_val))
}

# type: direct
# signature: update_symlinks
function update_symlinks {
	bashctl__print_debug true 1 "rm('%s')\n" "$BASH_LIB_ROOT"
	rm -r "$BASH_LIB_ROOT"
	bashctl__print_debug true 1 "mkdir('%s')\n" "$BASH_LIB_ROOT"
	mkdir "$BASH_LIB_ROOT"

	if [ "$bashctl__debug" -ge 2 ]; then
		printf '%0.s-' {1..20}; printf '\n'
	fi

	local whitelist
	local blacklist

	local top_dirs_suffix
	local top_dir_suffix
	local dirs_suffix
	local dir_suffix
	local ignore pattern

	# Get all components
	top_dirs_suffix="$(find -H "$BASH_LIB_COMPONENT_ROOT" -mindepth 1 -maxdepth 1 -type d | cut -c $(printf '%s' "$BASH_LIB_COMPONENT_ROOT/x" | wc -c)-)"

	IFS_backup="$IFS"
	IFS=$'\n'
	set -f
	for top_dir_suffix in $top_dirs_suffix; do
		# Set this component's whitelist and blacklist file paths.
		whitelist="$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/whitelist.txt"
		blacklist="$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/blacklist.txt"

		# Get all dirs/files of the component, then chop of the prefix to get only
		# the path relative to to the component directory.
		dirs_suffix="$(find "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix" -mindepth 1 -type d | \
cut -c $(printf '%s' "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/x" | wc -c)-)"

		files_suffix="$(find "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix" -mindepth 1 \! -type d -a \! \( \
-path "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/whitelist.txt" -o \
-path "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/blacklist.txt" \) | \
cut -c $(printf '%s' "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/x" | wc -c)-)"

		for dir_suffix in $dirs_suffix; do
			if [ -f "$whitelist" ]; then
				update_symlinks__match "$dir_suffix" < "$whitelist" || continue
			fi
			if [ -f "$blacklist" ]; then
				update_symlinks__match --all --not "$dir_suffix" < "$blacklist" || continue
			fi

			# Create the directory as a real directory (not a symlink).
			if [ ! -d "$BASH_LIB_ROOT/$dir_suffix" ]; then
				bashctl__print_debug true 2 "mkdir('%s')\n" "$BASH_LIB_ROOT/$dir_suffix"
				mkdir "$BASH_LIB_ROOT/$dir_suffix"
			fi
		done

		for file_suffix in $files_suffix; do
			# If the blacklist exists, then check against it.
			if [ -f "$whitelist" ]; then
				update_symlinks__match "$file_suffix" < "$whitelist" || continue
			fi
			if [ -f "$blacklist" ]; then
				update_symlinks__match --all --not "$file_suffix" < "$blacklist" || continue
			fi

			bashctl__print_debug true 2 "ln('%s' -> '%s')\n" "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/$file_suffix" "$BASH_LIB_ROOT/$file_suffix"
			ln -s "$BASH_LIB_COMPONENT_ROOT/$top_dir_suffix/$file_suffix" "$BASH_LIB_ROOT/$file_suffix"
		done
	done
	set +f
	IFS="$IFS_backup"
}

