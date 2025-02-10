#!/bin/bash

# Connect to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read username

# Generate a random number between 1 and 1000
secret_number=$(( RANDOM % 1000 + 1 ))

# Escape single quotes in the username for SQL queries
escaped_username=$(echo "$username" | sed "s/'/''/g")

# Check if the user exists in the database
user_exists=$($PSQL "SELECT username FROM users WHERE username='$escaped_username'")

if [[ -z $user_exists ]]; then
  # If the user doesn't exist, insert them into the database
  insert_result=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$escaped_username', 0, NULL)")
  echo "Welcome, $username! It looks like this is your first time here."
else
  # If the user exists, retrieve their game statistics
  games_played=$($PSQL "SELECT games_played FROM users WHERE username='$escaped_username'")
  best_game=$($PSQL "SELECT best_game FROM users WHERE users.username='$escaped_username'")
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."  
fi


# Start the guessing game
number_of_guesses=0
echo "Guess the secret number between 1 and 1000:"

while true; do
  read guess

  # Validate the input is an integer
  if [[ ! $guess =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  # Increment the number of guesses
  ((number_of_guesses++))

  # Check if the guess is correct
  if (( guess < secret_number )); then
    echo "It's higher than that, guess again:"
  elif (( guess > secret_number )); then
    echo "It's lower than that, guess again:"
  else
    # Correct guess
    echo "You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"

    # Update the user's game statistics
    update_query="UPDATE users SET games_played = games_played + 1, best_game = LEAST(COALESCE(best_game, $number_of_guesses), $number_of_guesses) WHERE username = '$escaped_username';"
    result=$($PSQL "$update_query")
    break
  fi
done