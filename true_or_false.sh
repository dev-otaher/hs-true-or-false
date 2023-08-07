#!/user/bin/env bash

responses=("Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!")
credentials_endpoint=http://127.0.0.1:8000/download/file.txt
login_endpoint=http://127.0.0.1:8000/login
game_endpoint=http://127.0.0.1:8000/game
credentials_filename=ID_card.txt
cookie_filename=cookie.txt
login_cookie_name=login-cookie
scores_filename=scores.txt

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

save_scores() {
    date=$(date +%Y-%m-%d)
    printf "User: %s, Score: %s, Date: %s\n" "$1" "$2" "$date" >> "$scores_filename"
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
            save_scores "$name" "$points"
            break
        fi
    done
}

is_file_exists() {
    if [ -f "$1" ]; then
        echo 1
    else
        echo 0
    fi
}

is_score_file_exists() {
    if [ "$(is_file_exists "$scores_filename")" -eq 1 ]; then
        echo 1
    else
        echo 0
    fi
}

display_scores() {
    if [ "$(is_score_file_exists)" -eq 1 ]; then
        echo 'Player scores'
        cat "$scores_filename"
    else
        echo 'File not found or no scores in it!'
    fi
}


reset_scores() {
    if [ "$(is_score_file_exists)" -eq 1 ]; then
        rm "$scores_filename"
        echo 'File deleted successfully!'
    else
        echo 'File not found or no scores in it!'
    fi
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
            display_scores;;
        "3")
            reset_scores;;
        *)
            echo 'Invalid option!';;
    esac
    echo -e "\n"
done
