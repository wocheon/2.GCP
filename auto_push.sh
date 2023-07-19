#!/bin/bash

time=$(date '+%y%m%d%H%M')

git add .
git commit -m "$time"
git push origin main --force
