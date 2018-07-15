@echo off
hugo

if %time:~0,1% == " " set time=0%time%

git add .
git commit -m "[%date% %time%] Auto Commit"
git push origin master

cd public

git add .
git commit -m "[%date% %time%] Auto Commit"
git push origin master

cd ..
