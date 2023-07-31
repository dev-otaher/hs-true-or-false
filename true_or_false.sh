#!/user/bin/env bash

credentials_filename=ID_card.txt
echo 'Welcome to the True or False Game!'
curl --silent --output "$credentials_filename" http://127.0.0.1:8000/download/file.txt

username=$(cut -d '"' -f 4 "$credentials_filename")
password=$(cut -d '"' -f 8 "$credentials_filename")
cookie_filename=cookie.txt
curl --silent --output "$cookie_filename" --user "$username":"$password" http://127.0.0.1:8000/login

printf 'Login message: %s' "$(cat "$cookie_filename")"