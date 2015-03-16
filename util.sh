# Copy this to the top of scripts that use utils.sh (uncomment the last line)
# -- Find util.sh ------------------------------------------------------------
set -e -u
SCRIPTNAME=$0
if [ ! -e "$SCRIPTNAME" ]; then
  case $SCRIPTNAME in
    (*/*) exit 1;;
    (*) SCRIPTNAME=$(command -v -- "$SCRIPTNAME") || exit;;
  esac
fi
SCRIPTPATH=$(cd -P -- "$(dirname -- "$SCRIPTNAME")" && pwd -P) || exit
# source "$SCRIPTPATH/util.sh"
# ----------------------------------------------------------------------------


# Get the directory the script resides in.
function getScriptDir {
	prg=$0
	if [ ! -e "$prg" ]; then
	  case $prg in
	    (*/*) exit 1;;
	    (*) prg=$(command -v -- "$prg") || exit;;
	  esac
	fi
	dir=$(
	  cd -P -- "$(dirname -- "$prg")" && pwd -P
	) || exit
	prg=$dir/$(basename -- "$prg") || exit 

	printf '%s\n' "$prg"
}

# Get the absolute path. Converts home dir and relative references.
function getAbsolutePath {
	original=${1%/}
	stripped=${original#"~/"}
	if [[ "$stripped" != "$original" ]]; then
		echo "$HOME/$stripped"
		exit
	fi
	stripped=${original#/}
	if [[ "$stripped" == "$original" ]]; then
		echo "$PWD/$stripped"
		exit
	fi
	echo "$original"
}

# Strip leading "./" and trailing "/", if any
function stripPath {
	path=${1##./}
	echo ${path%/}
}

function removeExtension {
	echo ${1%.*}
}

function getExtension {
	echo ${1##*.}
}

# Make a temporary directory. You are responsible for deleting it later.
function makeTempDir {
	echo `mktemp -d 2>/dev/null || mktemp -d -t 'bash_tmp'`
}

# Call a function for each file in the specified directory and subdirs.
# The function will be called with the first parameter being the path of the file
# relative to the searched directory.
# @param dir (string) - The directory to search.
# @param function_name (string) - The name of the function to call.
# @param ... (any) - Optional arguments to pass to the function after the file name.
function forEachFile {
	dir=$1
	shift
	function_name=$1
	shift

	pushd "$dir" >>/dev/null
	find -s . -type f -print0 | while read -d $'\0' file
	do
		path=$(stripPath "$file")
		$function_name "$path" "$@"
	done
	popd >>/dev/null
}

# Call a function for each file with the specified extension in the specified directory and subdirs.
# The function will be called with the first parameter being the path of the file
# relative to the searched directory.
# @param dir (string) - The directory to search.
# @param extension (string) - The filename extension to look for.
# @param function_name (string) - The name of the function to call.
# @param ... (any) - Optional arguments to pass to the function after the file name.
function forEachFileWithExtension {
	dir=$1
	shift
	extension=$1
	shift
	function_name=$1
	shift

	pushd "$dir" >>/dev/null
	find -s . -type f -name "*.$extension" -print0 | while read -d $'\0' file
	do
		path=$(stripPath "$file")
		$function_name "$path" "$@"
	done
	popd >>/dev/null
}
