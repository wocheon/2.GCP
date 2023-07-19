#!/bin/bash
time=$(date '+%Y%m%d%H%M')
branch=$(git branch | gawk '{print $2}')
remote=$( git remote -v | grep push | gawk '{print $1}' )

git add .

if [ $? -eq 0 ]; then
	echo -e "\E[42;37m'ADD : OKE[0m"
else 
	echo -e "\E[41;37mADD : FAIL\E[0m"
	exit
fi

git commit -m "$time"

if [ $? -eq 0 ]; then
	echo -e "\E[42;37m'COMMIT : OKE[0m"
else 
	echo -e "\E[41;37mCOMMIT : FAIL\E[0m"
	exit
fi

git push $remote $branch --force


if [ $? -eq 0 ]; then
	echo -e "\E[42;37m'PUSH : OKE[0m"
else 
	echo -e "\E[41;37mPUSH : FAIL\E[0m"
	exit
fi
