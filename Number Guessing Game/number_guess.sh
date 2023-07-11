#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Prompt user to enter username
echo -e "Enter your username:"
read USERNAME

# Check if username exists
USER_IN_DB=$($PSQL "select * from users where username like '$USERNAME';")

# If username does not exist, display the following message
if [[ -z $USER_IN_DB ]]; then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  
# If username exists, display the following message and retrieve data from db
else
  IFS='|' read USER_ID USERNAME_DB GAMES_PLAYED BEST_GAME <<< $USER_IN_DB
  echo -e "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi

# Prompt the user to guess a number
echo -e "Guess the secret number between 1 and 1000:"
read INPUT_NUMBER
COUNTER=1

while true; do
  # Check if the input is an integer
  if [[ $INPUT_NUMBER =~ ^[0-9]+$ ]]; then
    if [[ $INPUT_NUMBER -gt $SECRET_NUMBER ]]; then
      echo -e "It's lower than that, guess again:"
      ((COUNTER++))
      read INPUT_NUMBER

    elif [[ $INPUT_NUMBER -lt $SECRET_NUMBER ]]; then
      echo -e "It's higher than that, guess again:"
      ((COUNTER++))
      read INPUT_NUMBER

    else
      echo -e "You guessed it in $COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
      break

    fi

  else
    echo -e "That is not an integer, guess again:"
    read INPUT_NUMBER

  fi

done

# If username does not exist add to db
if [[ -z $USER_IN_DB ]]; then
  INSERT=$($PSQL "insert into users (username, games_played, best_game) values ('$USERNAME', 1, $COUNTER);")

# If username exists update values in db
else
  ((GAMES_PLAYED++))
  INSERT=$($PSQL "update users set games_played = $GAMES_PLAYED where user_id = $USER_ID;")

  if [[ $BEST_GAME -gt $COUNTER ]]; then
    INSERT=$($PSQL "update users set best_game = $COUNTER where user_id = $USER_ID;")
    echo -e "$USER_ID $USERNAME_DB $GAMES_PLAYED $BEST_GAME $COUNTER"
  fi

fi
