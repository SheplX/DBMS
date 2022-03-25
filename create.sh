  echo -e "Enter Database Name: \c"
  read choice
  mkdir -p ./Databases/$choice
  if [[ $? == 0 ]]
  then
    echo "Database Created Successfully"
  else
    echo "Error Creating Database $dbName"
  fi
  ./main.sh