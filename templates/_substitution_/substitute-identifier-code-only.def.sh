function substitute-identifier {
	local sub_name="$1"; shift

	local template_extension=''
	local template_type='definition'

	# Parse options
	local arg
	for arg in "$@"; do
		if [ "${arg:0:1}" != '-' ]; then break; fi

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
			'-t' | '--type')
				if [ "$set_op" = false ]; then
					template__error true "'-t' or '--type' must have an assignment after it."
					return 1
				elif [ "$set_op" = true ]; then
					template_type="$value"
				fi
				;;

			'-e' | '--extension')
				if [ "$set_op" = false ]; then
					template__error true "'-e' or '--extension' must have an assignment after it."
					return 1
				elif [ "$set_op" = true ]; then
					template_extension="$value"
				fi
				;;

			*)
				# This will happen if the *command-line* was incorrect.
				template__error true "unrecognised option: '%s'" "$option"
				return 1
				;;
		esac

		# Remove it from $@
		shift
	done

	case "$sub_name" in
		'attrs')
			case "$template_type" in
				'script') substitution='.sh';;
				'def' | 'definition') substitution='.def.sh';;
				*)
					# This will happen if the *command-line* was incorrect.
					template__error true "invalid template type: '%s'" "$template_type"
					return 1
			esac

			if [ -n "$template_extension" ]; then
				substitution="${substitution}${template_extension:+.$template_extension}"
			fi
			;;

		*)
			# This will happen if the *template* is incorrect.
			return 2
	esac

	printf '%s' "$substitution"
}
