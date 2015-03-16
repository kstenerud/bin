# Copy this to the top of scripts that use utils.sh (uncomment the last line)
# -- Find util.sh ------------------------------------------------------------
set -e -u
SCRIPTNAME="$0"
if [ ! -e "$SCRIPTNAME" ]; then
  case "$SCRIPTNAME" in
    (*/*) exit 1;;
    (*) SCRIPTNAME="$(command -v -- "$SCRIPTNAME")" || exit;;
  esac
fi
SCRIPTPATH="$(cd -P -- "$(dirname -- "$SCRIPTNAME")" && pwd -P)" || exit
# source "$SCRIPTPATH/util.sh"
# ----------------------------------------------------------------------------


function echoAndRun {
	echo "$@"
	"$@"
}

function echoAndRunQuiet {
	echo "$@"
	"$@" >>/dev/null
}

# Get the absolute path. Converts home dir and relative references.
function getAbsolutePath {
	original="${1%/}"
	stripped="${original#"~/"}"
	if [[ "$stripped" != "$original" ]]; then
		echo "$HOME/$stripped"
		exit
	fi
	stripped="${original#/}"
	if [[ "$stripped" == "$original" ]]; then
		stripped="${stripped#./}"
		echo "$PWD/$stripped"
		exit
	fi
	echo "$original"
}

# Strip leading "./" and trailing "/", if any
function stripPath {
	path="${1##./}"
	echo "${path%/}"
}

function removeExtension {
	echo "${1%.*}"
}

function getExtension {
	echo "${1##*.}"
}

function addPath {
	base_path="${1%/}"
	added_path="${2##./}"
	echo "$base_path/$added_path"
}

function makeParentDirs {
	mkdir -p "$(dirname "$1")"
}

# Make a temporary directory. You are responsible for deleting it later.
function makeTempDir {
	echo $(mktemp -d 2>/dev/null || mktemp -d -t 'bash_tmp')
}

# Call a function for each file in the specified directory and subdirs.
# The function will be called with the first parameter being the path of the file
# relative to the searched directory.
# @param dir (string) - The directory to search.
# @param function_name (string) - The name of the function to call.
# @param ... (any) - Optional arguments to pass to the function after the file name.
function forEachFile {
	dir="$1"
	shift
	function_name="$1"
	shift

	pushd "$dir" >>/dev/null
	find . -type f -print | sort | while read file
	do
		path="$(stripPath "$file")"
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
	dir="$1"
	shift
	extension="$1"
	shift
	function_name="$1"
	shift

	pushd "$dir" >>/dev/null
	find . -type f -name "*.$extension" -print | sort | while read file
	do
		path="$(stripPath "$file")"
		$function_name "$path" "$@"
	done
	popd >>/dev/null
}

# Convert a single file. INTERNAL FUNCTION.
# @param rel_path (string) - The source path relative to the current dir.
# @param dst_dir (string) - The destination directory.
# @param extension (string) - The extension to give the destination file.
# @param conversion_function (string) - Name of the function that will do the conversion.
function convertOneFile {
	rel_path="$1"
	shift
	dst_dir="$1"
	shift
	extension="$1"
	shift
	conversion_function="$1"
	shift

	src_path="$(getAbsolutePath "$rel_path")"
	dst_path="$(addPath "$dst_dir" "$(removeExtension "$rel_path")").$extension"

	if [ ! -f "$dst_path" ]; then
		makeParentDirs "$dst_path"
		$conversion_function "$src_path" "$dst_path" $@
	fi
}

# Convert all files in the source directory, creating a parallel structure in the destination.
# @param src_dir (string) - The directory to convert from.
# @param dst_dir (string) - The directory to store the converted files in.
# @param dst_extension (string) - The extension to give the converted files.
# @param conversion_function (string) - Name of the function that will do the conversion.
# @param ... (any) - Any other params to pass to the conversion function.
function convertFiles {
	src_dir="$1"
	shift
	dst_dir="$(getAbsolutePath "$1")"
	shift
	dst_extesion="$1"
	shift
	conversion_function="$1"
	shift

	forEachFile "$src_dir" convertOneFile "$dst_dir" "$dst_extesion" "$conversion_function" $@
}

# Convert all files in the source directory with the specified extension,
# creating a parallel structure in the destination.
# @param src_dir (string) - The directory to convert from.
# @param dst_dir (string) - The directory to store the converted files in.
# @param src_extension (string) - The extension to search for in the source files.
# @param dst_extension (string) - The extension to give the converted files.
# @param conversion_function (string) - Name of the function that will do the conversion.
# @param ... (any) - Any other params to pass to the conversion function.
function convertFilesWithExtension {
	src_dir="$1"
	shift
	dst_dir="$(getAbsolutePath "$1")"
	shift
	src_extension="$1"
	shift
	dst_extesion="$1"
	shift
	conversion_function="$1"
	shift

	forEachFileWithExtension "$src_dir" "$src_extension" convertOneFile "$dst_dir" "$dst_extesion" "$conversion_function" $@
}
