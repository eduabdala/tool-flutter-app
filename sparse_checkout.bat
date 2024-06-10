@echo off
setlocal

set REPO_URL=
set CLONE_DIR=./
set SPARSE_PATH=./

git clone --no-checkout %REPO_URL%%CLONE_DIR%

cd %CLONE_DIR%

git sparse-checkout init --cone 
git sparse-checkout set %SPARSE_PATH%

git checkout main

echo Sparse checkout concluído.

endlocal
pause
