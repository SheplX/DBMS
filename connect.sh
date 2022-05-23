                        ###################################     FUNCTIONS     ########################################
  #### CREATE TABLE
  function createTB {
  echo -e "Table Name: \c"
  read tableName
  if [[ -f $tableName ]]; then
    echo "table already existed ,choose another name"
    connect
  fi
  echo -e "Number of Columns: \c"
  read colsNum    #columns nums
  counter=1       #iteration nums
  sep="|"         #seprator
  rSep="\n"       #seprator lines
  pKey=""         #primary key
  metaData="Field"$sep"Type"$sep"key"  #metadata header
  while [ $counter -le $colsNum ]
  do
    echo -e "Name of Column No.$counter: \c"
    read colName
    echo -e "Type of Column $colName: " #columns type
    select var in "int" "str"
    do
      case $var in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;
      esac
    done
    if [[ $pKey == "" ]]; then
      echo -e "Do You Want To Make a PrimaryKey ? " #define a pk
      select var in "yes" "no"
      do
        case $var in
          yes ) pKey="PK";
          metaData+=$rSep$colName$sep$colType$sep$pKey;
          break;;
          no )
          metaData+=$rSep$colName$sep$colType$sep""
          break;;
          * ) echo "Wrong Choice" ;;
        esac
      done
    else
      metaData+=$rSep$colName$sep$colType$sep"" #metadata store
    fi
    if [[ $counter == $colsNum ]]; then 
      temp=$temp$colName    #no separation at the end of the last column
    else
      temp=$temp$colName$sep  #metadata store for each column in this var
    fi
    ((counter++))
  done
  touch .$tableName  #make a file for the metadata
  echo -e $metaData  >> .$tableName
  touch $tableName
  echo -e $temp >> $tableName #make a file for the table
  if [[ $? == 0 ]] #To make sure that the file is created
  then
    echo "Table Created Successfully"
    connect
  else
    echo "Error Creating Table $tableName"
    connect
  fi
   }
  #### SELECT DATABASE
  function selectDB {
  echo -e "Avaliable Databases: \c"
  ls ./Databases
  echo -e "Enter Database Name: \c"
  read dbName
  cd ./Databases/$dbName 2>>./.error.log
  if [[ $? == 0 && $dbName != "" ]]; then
   echo "Database $dbName was Successfully Selected"
  else
   echo "Database $dbName wasn't found"
   ./main.sh
   fi
 }
#### DROP A TABLE
 function dropTB {
  echo -e "Avaliable Tables: \c"
  ls .
  echo -e "Enter Table Name: \c"
  read tName
  rm $tName .$tName 2>>./.error.log
  if [[ $? == 0 ]]
  then
    echo "Table Dropped Successfully"
  else
    echo "Error Dropping Table $tName"
  fi
}
#### DELETE FROM TABLE
function deleteFromTB {
  echo -e "Avaliable Tables: \c"
  ls .
  echo -e "Enter Table Name: \c"
  read tableName
  printTable '|' "$(cat $tableName)"
  echo -e "Enter Condition Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    ls .
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tableName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      ls .
    else
      NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tableName 2>>./.error.log)
      sed -i ''$NR'd' $tableName 2>>./.error.log
      printTable '|' "$(cat $tableName)" 2>>./.error.log
      echo "Row Deleted Successfully"
    fi
  fi
}
#### INSERT TABLE
function insertTB {
  echo -e "Avaliable Tables: \c"
  ls .
  echo -e "Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table $tableName isn't existed ,choose another Table"
    connect
  fi
  colsNum=`awk 'END{print NR}' .$tableName` #LINES NUMBER 
  sep="|"     #serator 
  rSep="\n"   #rSerator
  for (( i = 2; i <= $colsNum; i++ )); do
    colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName) 
    colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
    printTable '|' "$(cat $tableName)"
    echo -e "$colName ($colType) = \c"
    read value
  # Validate Input
    if [[ $colType == "int" ]]; then
      while ! [[ $value =~ ^[0-9]*$ ]]; do
        echo -e "invalid valueType !!"
        echo -e "$colName ($colType) = \c"
        read value
      done
    fi
    if [[ $colKey == "PK" ]]; then
      while [[ true ]]; do
        if [[ $value =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
          echo -e "invalid input for Primary Key !!"
        else
          break;
        fi
        echo -e "$colName ($colType) = \c"
        read value
      done
    fi
    if [[ $i == $colsNum ]]; then  #inserting rows into database
      row=$row$value$rSep
    else
      row=$row$value$sep
    fi
  done #ending loop
  echo -e $row"\c" >> $tableName
  if [[ $? == 0 ]] # check on the process of entering rows
  then
    #column -t -s '|' ./$1/$tableName
    printTable '|' "$(cat $tableName)"
    echo "value Inserted Successfully"
  else
    echo "Error Inserting value into Table $tableName"
  fi
  row=""
  connect
}
#### DECORATING FUNCTION
function printTable()
{
    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                # Add Header Or Body

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}
function removeEmptyLines()
{
    local -r content="${1}"

    echo -e "${content}" | sed '/^\s*$/d'
}
function repeatString()
{
    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}
function isEmptyString()
{
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}
function trimString()
{
    local -r string="${1}"

    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}
#### UPDATE TABLE
function updateTB {
  echo -e "Avaliable Tables: \c"
  ls .
  echo -e "Enter Table Name: \c"
  read tableName
  printTable '|' "$(cat $tableName)"
  echo -e "Enter Condition Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    connect
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tableName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      connect
    else
        echo -e "Enter new Value to set: \c"
        read newValue
        NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$val'") print NR}' $tableName 2>>./.error.log)
        oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$fid') print $i}}}' $tableName 2>>./.error.log)
        echo $oldValue
        sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tableName 2>>./.error.log
        printTable '|' "$(cat $tableName)"   
        echo "Row Updated Successfully"
        connect
      fi
  fi
 }
 #### SELECT ALL
 function selectAll {
    echo -e "Avaliable Tables: \c"
    ls .
    echo -e "Plz Enter Table Name: \c"
    read tableName
    printTable '|' "$(cat $tableName)" 2>>./.error.log
    if [[ $? != 0 ]]
    then
      echo "Error To Show The Table: $tableName"
    fi
    connect
  }
  #### SELECT COLUMN
  function selectColumn {
    echo -e "Avaliable Tables: \c"
    ls .
    echo -e "Plz Enter Table Name: \c"
    read tableName
    printTable '|' "$(cat $tableName)" 2>>./.error.log
    echo -e "Plz Enter Column Name: \c"
    read columnName
    awk 'BEGIN{FS="|"}{print $'$columnName'}' $tableName
    # csvcut -t -c $columnName $tableName | csvlook # how to use ?
    connect
 }
  #### SELECT FROM TABLE
  function selectFromTB {
    echo "+------------------------------+"
    echo "| 1. All ?                     |"
    echo "| 2. Special Column ?          |"
    echo "| 3. Exit                      |"
    echo "+------------------------------+"
    echo -e "Enter Choice: \c"
    read REPLY
    case $REPLY in
    1 ) selectAll ; connect
    ;;
    2 ) selectColumn ; connect
    ;;
    3 ) exit
    ;;
    * ) echo "invalid choice, pick again please" ; connect ;
    esac
}
                      ###################################     MENU     ########################################
  function connect {
    echo "+------------------------------+"
    echo "| 1. Create Table              |"
    echo "| 2. List Tables               |"
    echo "| 3. Drop Table                |"
    echo "| 4. Insert Into Table         |"
    echo "| 5. Select From Table         |"
    echo "| 6. Delete From Table         |"
    echo "| 7. Update Table              |"
    echo "| 8. Back To Main Menu         |"
    echo "| 9. Exit                      |"
    echo "+------------------------------+"
    echo -e "Enter Choice: \c"
    read REPLY
    case $REPLY in
    1 ) createTB 
    ;;
    2 ) ls . ; connect
    ;;
    3 ) dropTB ; connect
    ;;
    4 ) insertTB ; connect
    ;;
    5 ) selectFromTB ; connect
    ;;
    6 ) deleteFromTB ; connect
    ;;
    7 ) updateTB ; connect
    ;;
    8 ) cd ../..
        ./main.sh
    ;;
    9 ) echo "Have A Nice Day ! "
        exit
    ;;
    * ) echo "invalid choice, pick again please" ; connect ;
    esac
 }
selectDB
connect
