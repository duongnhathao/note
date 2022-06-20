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

echo "cloning project"
{
  if [ -z "$path_install" ]; then
    git clone "$git" .
  else
    git clone "$git" "$path_install"
  fi
  #  clear && echo "clone success"
} || {
  echo "clone failed"
  sleep 2
  exit 1
}

if [ -z "$extend_modules" ]; then
  status_modules_clone=()
  echo "Insert extends modules ? Enter for skip | any key for accept - using file extend_modules.txt for define"
  read -r extend_modules
  if [ -z "$extend_modules" ]; then
    echo "skip insert extend_modules"
  else
    dir_modules="$path_install/modules"
    if [ -d "$dir_modules" ]; then
      array_git=()

      echo "'$dir_modules' found and now copying files, please wait ..."
      while read -r line; do array_git+=("$line"); done <extend_modules.txt
      cd "$dir_modules" || (echo "not found" && exit 1)
      for value in "${array_git[@]}"; do
        git clone "$value"
      done
    else
      echo "Warning: '$dir_modules' NOT found."
    fi
  fi
fi
{
  cd "$path_install\application" && composer install
  cd "$path_install\application\config" && cp app-config.php.dist app-config.php
} || {
  echo "not found module to run composer"
}

echo "${arr[*]}"
echo "${status_modules_clone[*]}"
read -r -p "Press enter to exit"
