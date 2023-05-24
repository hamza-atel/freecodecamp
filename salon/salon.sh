MAIN_MENU

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\nWelcome to the salon, what would you like?\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "select * from services;")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]; then
    MAIN_MENU "Invalid input, please try again."
  fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE;
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_ID ]]; then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    echo -e "\nWhen would you like the appointment?"
    read SERVICE_TIME
    INSERT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
    INSERT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME');")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    exit

  else
    echo "When would you like the appointment?"
    read SERVICE_TIME
    INSERT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME');")
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    exit
  fi
}

MAIN_MENU
