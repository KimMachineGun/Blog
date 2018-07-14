@echo off
hugo

git add .
git commit -m "[%date%|%time%] Auto Commit"
git push

cd public

git add .
git commit -m "[%date%|%time%] Auto Commit"
git push

cd ..
