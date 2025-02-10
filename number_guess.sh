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
