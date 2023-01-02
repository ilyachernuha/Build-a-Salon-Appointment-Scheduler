#! /bin/bash
# Salon Appointment Scheduler

PSQL="psql --username=freecodecamp --dbname=salon -X -t -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~"

SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n Please choose service:\n"
  echo "$($PSQL "SELECT * FROM services ORDER BY service_id")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
  then
    SERVICES
  else
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    echo -e "\nPlease insert service time:"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
    then
      SERVICE_NAME=$(echo $($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") | sed 's/^ *$//')
      CUSTOMER_NAME=$(echo $($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID") | sed 's/^ *$//')
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      SERVICES
    fi
  fi
}

SERVICES
