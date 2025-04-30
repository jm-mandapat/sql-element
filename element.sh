#!/bin/bash
#  Script to query elements from a database

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align -t -c"

QUERY_ELEMENT()
{
  if [[ -z "$1" || -z "$2" ]]
  then
    echo "Invalid call to QUERY_ELEMENT()"
    return 2
  else
    # create filter
    if [[ $1 == "atomic_number" ]]
    then
      QUERY_FILTER="e.$1 = $2"
    else
      QUERY_FILTER="e.$1 = '$2'"
    fi

    # query element
    ELEMENT_DATA=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p USING(atomic_number) JOIN types t USING(type_id) WHERE $QUERY_FILTER")
    if [[ -z $ELEMENT_DATA ]]
    then
      # search not found
      return 1
    else
      # search found
      IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$ELEMENT_DATA"
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      return 0
    fi
  fi
}

ELEMENT()
{
  if [[ -z $1 ]]
  then
    # if no argument
    echo "Please provide an element as an argument."
  else
    # if number argument
    if [[ $1 =~ ^[1-9][0-9]*$ ]]
    then
      QUERY_ELEMENT "atomic_number" $1

      # if search not found
      if [[ $? == 1 ]]
      then
        echo "I could not find that element in the database."
      fi
    else
      # query as symbol
      QUERY_ELEMENT "symbol" $1

      # if search not found
      if [[ $? == 1 ]]
      then
        # query as name
        QUERY_ELEMENT "name" $1

        # if search not found
        if [[ $? == 1 ]]
        then
          echo "I could not find that element in the database."
        fi
      fi
    fi
  fi
}

ELEMENT $1
