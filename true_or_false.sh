#!/user/bin/env bash

print_menu() {
    echo '0. Exit'
    echo '1. Play a game'
    echo '2. Display scores'
    echo '3. Reset scores'
}

echo 'Welcome to the True or False Game!'

while true; do
    print_menu
    echo 'Enter an option:'
    read -r option
    
    case "$option" in
        "0")
            echo 'See you later!'
            break;;
        "1")
            echo 'Playing game';;
        "2")
            echo 'Displaying scores';;
        "3")
            echo 'Resetting scores';;
        *)
            echo 'Invalid option!';;
    esac
    echo -e "\n"
done
