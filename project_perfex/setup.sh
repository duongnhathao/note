while getopts p:g:e: flag; do
  case "${flag}" in
  p) path_install=${OPTARG} ;;
  g) git=${OPTARG} ;;
  e) extend_modules=${OPTARG} ;;
  *) ;;
  esac
done

if [ -z "$path_install" ]; then
  echo "path to install project"
  read -r path_install
fi

while [ -z "$git" ]; do
  echo "git link"
  read -r git
done
arr["git"]="$git"
arr["path_name"]="$path_install"
git clone "$git $path_install" || (
  sleep 5
  exit 1
)

if [ -z "$extend_modules" ]; then
  echo "Insert extends modules ? Enter for skip | name dir for accept - using file extend_modules.txt for define"
  read -r extend_modules
  if [ -z "$extend_modules" ]; then
    echo "skip insert extend_modules"
  else
    mkdir -p "$path_install/modules"
    cd "$path_install/modules" || (echo "find not found path install" && exit 1)
    while read -r line; do git clone "$line"; done <extend_modules.txt
  fi
fi
echo "${arr[*]}"
read -r -p "Press enter to exit"
