@echo off
hugo

git add .
git commit -m "[%date%|%time%] Auto Commit"
git push origin master

cd public

git add .
git commit -m "[%date%|%time%] Auto Commit"
git push origin master

cd ..
