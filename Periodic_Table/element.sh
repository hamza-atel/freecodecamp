#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ $1 ]]; then
  if [[ $1 =~ ^[0-9]+$ ]]; then
    ELEMENT=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements join properties using (atomic_number) join types using (type_id) where atomic_number = $1;")

    elif [[ ${#1} -eq 2 || ${#1} -eq 1 ]]; then
    ELEMENT=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements join properties using (atomic_number) join types using (type_id) where symbol like '$1';")

    else
    ELEMENT=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements join properties using (atomic_number) join types using (type_id) where name like '$1';")

  fi

  if [[ -z $ELEMENT ]]; then
    echo -e "I could not find that element in the database."

    else
      IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MPC BPC <<< $ELEMENT
      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius."
  fi

  else
  echo -e "Please provide an element as an argument."
fi
