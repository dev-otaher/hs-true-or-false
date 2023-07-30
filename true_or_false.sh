#!/user/bin/env bash

filename=ID_card.txt
echo 'Welcome to the True or False Game!'
curl --silent --output "$filename" http://127.0.0.1:8000/download/file.txt
cat "$filename"