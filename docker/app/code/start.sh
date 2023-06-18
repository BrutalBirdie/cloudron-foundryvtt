#!/bin/bash

mkdir -p /app/data

echo '=> Lets roll some dice!'

node resources/app/main.js --dataPath=/app/data
