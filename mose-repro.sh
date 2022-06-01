#!/bin/sh

# From: https://github.com/JuliaVersionControl/Git.jl/issues/40#issuecomment-951344254

set -euf -o pipefail

export DYLD_FALLBACK_LIBRARY_PATH="$(julia --project -e 'using Git_jll; print(Git_jll.LIBPATH[])')"
GIT_DIR="$(julia --project -e 'using Git_jll; print(Git_jll.artifact_dir)')"
GIT="${GIT_DIR}/bin/git"
export GIT_EXEC_PATH="${GIT_DIR}/libexec/git-core"
export GIT_TEMPLATE_DIR="${GIT_DIR}/share/git-core/templates"
export GIT_SSL_CAINFO="$(julia --project -e 'print(dirname(Sys.BINDIR))')/share/julia/cert.pem"

echo DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH
echo GIT_DIR=$GIT_DIR
echo GIT=$GIT
echo GIT_EXEC_PATH=$GIT_EXEC_PATH
echo GIT_TEMPLATE_DIR=$GIT_TEMPLATE_DIR
echo GIT_SSL_CAINFO=$GIT_SSL_CAINFO

dir1=$(mktemp -d)
url1="file://${dir1}"
dir2=$(mktemp -d)
"${GIT}" -C "${dir1}" -c "user.name=a" -c "user.email=b@c" init --bare
"${GIT}" -C "${dir2}" -c "user.name=a" -c "user.email=b@c" init
echo "test" > "${dir2}/README"
"${GIT}" -C "${dir2}" -c "user.name=a" -c "user.email=b@c" add --all
"${GIT}" -C "${dir2}" -c "user.name=a" -c "user.email=b@c" commit -qm test
"${GIT}" -C "${dir2}" -c "user.name=a" -c "user.email=b@c" remote add origin "${url1}"
"${GIT}" -C "${dir2}" -c "user.name=a" -c "user.email=b@c" push --set-upstream origin master
