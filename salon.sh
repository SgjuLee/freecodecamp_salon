#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# $($PSQL"")

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi 


  SERVICE_LIST=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  SERVICE_MENU
}

SERVICE_MENU() {

  read SERVICE_ID_SELECTED
  # If you pick a service that doesn't exist, you should be shown the same list of services again
  SERVICE_NAME=$($PSQL"SELECT name from services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  # If service id exist
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL"SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # If customer are new
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Get the customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Add to database
      ADD_CUSTOMER=$($PSQL"INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # Get the customer id
    CUSTOMER_ID=$($PSQL"SELECT customer_id from customers WHERE phone = '$CUSTOMER_PHONE'")
    # Ask for service time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    ADD_APPOINTMENT=$($PSQL"INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  fi

  # Ending message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


MAIN_MENU