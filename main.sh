#!/bin/bash
  echo "+------------------------------+"
  echo "|--- DBMS BY NOURAN & SHEPL ---|"
  echo "|------------------------------|"
  echo "| 1. Create Database           |"
  echo "| 2. List Database             |"
  echo "| 3. Conncet to Database       |"
  echo "| 4. Drop Database             |"
  echo "| 5. Exit                      |"
  echo "+------------------------------+"
  echo -e "Enter Choice: \c"
  read REPLY
case $REPLY in
1 ) ./create.sh
;;
2 ) ls ./Databases ; ./main.sh
;;
3 ) ./connect.sh
;;
4 ) ./drop.sh
;;
5 ) exit
;;
* ) echo "invalid choice, pick again please" ; ./main.sh
;;
esac