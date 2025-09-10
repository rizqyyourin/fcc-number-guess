cat > number_guess.sh <<'EOF'
#!/bin/bash
# number_guess.sh — freeCodeCamp Number Guessing Game

PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

# 1) Username
echo "Enter your username:"
read USERNAME

# 2) Cek user
USER_ID="$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")"

if [[ -z $USER_ID ]]; then
  # user baru (diamkan stdout+stderr agar output bersih)
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');" >/dev/null 2>&1
  USER_ID="$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # user lama: tampilkan statistik
  GAMES_PLAYED="$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")"
  BEST_GAME="$($PSQL "SELECT COALESCE(MIN(guesses), 0) FROM games WHERE user_id=$USER_ID;")"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# 3) Secret number 1..1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# 4) Main loop
echo "Guess the secret number between 1 and 1000:"
GUESSES=0

while true
do
  read GUESS

  # validasi integer
  if ! [[ $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESSES=$(( GUESSES + 1 ))

  if (( GUESS == SECRET_NUMBER )); then
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    # simpan game (diamkan stdout+stderr)
    $PSQL "INSERT INTO games(user_id, guesses, secret_number) VALUES($USER_ID, $GUESSES, $SECRET_NUMBER);" >/dev/null 2>&1
    break
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done
EOF

chmod +x number_guess.sh
