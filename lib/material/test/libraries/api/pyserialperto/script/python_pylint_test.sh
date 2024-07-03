python -m pylint \
    --method-rgx "^([a-z][a-z0-9_]{0,28}[a-z]|__[a-z][a-z0-9_]{0,26}[a-z]|__[a-z][a-z0-9_]{0,24}[a-z]__)$" \
    --class-rgx "^([A-Z][a-zA-Z0-9]{2,30}|__[A-Z][a-zA-Z0-9]{2,28})$" \
    --ignore-patterns "test_" \
    --fail-under=9  \
    src/*.py
