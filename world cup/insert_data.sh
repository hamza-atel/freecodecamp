#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "truncate teams, games;"

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]; then
  : '
    WINNER_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")

    if [[ -z $WINNER_TEAM_ID ]]; then
      INSERT_NAME_RESULT=$($PSQL "insert into teams(name) values('$WINNER');")
      if [[ $INSERT_NAME_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted team $WINNER into the table."
      fi
      WINNER_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    fi
   
    if [[ -z $OPPONENT_TEAM_ID ]]; then
      INSERT_NAME_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT');")
      if [[ $INSERT_NAME_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted team $OPPONENT into the table."
      fi
      OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    fi

    INSERT_GAMES_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]; then
      echo "Inserted into games table."
    fi
   '
    
    #The above code was taking more than 20 seconds to execute, found the following in the forums.
    $PSQL "INSERT INTO teams(name) VALUES ('$WINNER') ON CONFLICT (name) DO NOTHING; INSERT INTO teams(name) VALUES ('$OPPONENT') ON CONFLICT (name) DO NOTHING; INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name = '$WINNER'), (SELECT team_id FROM teams WHERE name = '$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS);"


  fi

done
