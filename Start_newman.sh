#!/bin/bash

fileName=$(date +%F_%H-%M-%S)

newman run 'Postman_Project_Book_Store_v2.postman_collection.json' -e 'Environment for BookStore.postman_environment.json' > ${fileName}.log

echo "Результаты запуска коллекции Book_Store_v2 сохранены в ${fileName}.log"
