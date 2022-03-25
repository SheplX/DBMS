ls ./Databases
echo -e "Enter Database Name: \c"
  read choice
  rm -r ./Databases/$choice 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo "Database Dropped Successfully"
  else
    echo "Database Not found"
  fi
  ./main.sh