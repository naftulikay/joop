export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

test -e "$PYENV_ROOT/completions/pyenv.bash" && \
  source "$PYENV_ROOT/completions/pyenv.bash"

if which pyenv >/dev/null 2>&1 ; then
  eval "$(pyenv init -)"
fi
