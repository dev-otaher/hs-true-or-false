#!/user/bin/env bash

responses=("Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!")
credentials_endpoint=http://127.0.0.1:8000/download/file.txt
login_endpoint=http://127.0.0.1:8000/login
game_endpoint=http://127.0.0.1:8000/game
credentials_filename=ID_card.txt
cookie_filename=cookie.txt
login_cookie_name=login-cookie

print_menu() {
    echo '0. Exit'
    echo '1. Play a game'
    echo '2. Display scores'
    echo '3. Reset scores'
}

get_credentials() {
    curl -s -o "$credentials_filename" "$credentials_endpoint"
}

get_login_cookie() {
    curl -s -o "$cookie_filename" -c "$login_cookie_name" -u "$1":"$2" "$login_endpoint" > /dev/null
}

login() {
    get_credentials
    username=$(cut -d '"' -f 4 "$credentials_filename")
    password=$(cut -d '"' -f 8 "$credentials_filename")
    get_login_cookie "$username" "$password"
}

get_question_and_answer() {
    curl -b "$login_cookie_name" "$game_endpoint"
}

play_game() {
    echo 'What is your name?'
    read -r name
    echo ''

    local correct_answers=0
    local points=0
    while true; do
        response="$(get_question_and_answer)"
        question=$(cut -d '"' -f 4 - <<< "$response")
        answer=$(cut -d '"' -f 8 - <<< "$response")
        echo "$question"
        echo 'True or False?'
        read -r user_answer
        if [ "$user_answer" == "$answer" ]; then
            ((correct_answers++))
            ((points=points + 10))
            idx=$((RANDOM % 5))
            echo -e "${responses[$idx]}\n"
        else
            echo 'Wrong answer, sorry!'
            printf "%s you have %s correct answer(s).\n" "$name" "$correct_answers"
            printf "Your score is %s points." "$points"
            break
        fi
    done
}

echo 'Welcome to the True or False Game!'
login
while true; do
    print_menu
    echo 'Enter an option:'
    read -r option
    case "$option" in
        "0")
            echo 'See you later!'
            break;;
        "1")
            play_game;;
        "2")
            echo 'Displaying scores';;
        "3")
            echo 'Resetting scores';;
        *)
            echo 'Invalid option!';;
    esac
    echo -e "\n"
done
