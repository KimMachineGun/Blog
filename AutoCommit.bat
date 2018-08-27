@echo off

cd public

git rm . -r

cd ..

hugo

if "%time:~0,1%" == " " (
    set timeF=0%time:~1%
) else (
    set timeF=%time%
)

cd public

git add .
git commit -m "[%date% %timeF%] Auto Commit"
git push origin master

cd ..

git add .
git commit -m "[%date% %timeF%] Auto Commit"
git push origin master