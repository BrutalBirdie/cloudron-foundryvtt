#!/bin/bash

mkdir -p /app/data

echo '=> Lets roll some dice!'

node main.js --dataPath=/app/data
