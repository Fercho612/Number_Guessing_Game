#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

SELECT_USER=$($PSQL "SELECT user_id, username FROM users WHERE username='$USERNAME';")
IFS='|' read -r USER_ID USERNAME_DATA <<< "$SELECT_USER"

if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(tries) FROM games WHERE user_id=$USER_ID;")
  echo "Welcome back, $USERNAME_DATA! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RANDOM_NUMBER=$((RANDOM % 1000 + 1))
TRIES=1

echo "Guess the secret number between 1 and 1000:"
read USER_INPUT
while [[ ! $USER_INPUT =~ [0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read USER_INPUT
done

while [[ $USER_INPUT != $RANDOM_NUMBER ]] 
do
  if [[ $USER_INPUT > $RANDOM_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else 
    echo "It's higher than that, guess again:"
  fi
  
  TRIES=$(( TRIES + 1 ))
  
  read USER_INPUT
  while [[ ! $USER_INPUT =~ [0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_INPUT
  done

done

echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"


SELECT_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, tries) VALUES($SELECT_USER_ID, $TRIES);")