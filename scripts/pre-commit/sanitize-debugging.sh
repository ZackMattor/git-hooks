grep_search="binding.pry\\|console.log\\|debugger"

for FILE in `git diff --cached --name-only --diff-filter=ACM` ; do
  grep -q $grep_search $FILE

  if [[ $? -eq 0 ]] ; then
    exit_status=1

    echo "  In File: '"$FILE"'"
    arr=($(grep -n $grep_search $FILE |cut -f1 -d:))
    
    grep -on $grep_search $FILE
    
    delete_string=""
    for i in ${arr[@]}
    do
      delete_string="${delete_string}${i}d;"
    done

    if [[ ${#arr[@]} -gt 0 ]] ; then
      exec < /dev/tty
      while true; do
        read -p "Do you want me to remove these(y/n)?" yn
        case $yn in
            [Yy]* ) sed $delete_string $FILE > SED_TEMP_FILE.tmp;
                    mv SED_TEMP_FILE.tmp $FILE;
                    staging_modified=1
                    break;;

            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
      done
    fi
  fi
done

if [[ $staging_modified -eq 1 ]] ; then
  exit_status=0
  git add .
  #git commit -m "Auto remove of debug files"
fi
