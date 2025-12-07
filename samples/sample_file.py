# TODO: basic todo
## TODO   with spaces
### TODO:: multiple colons
#   TODO:::    spaced + colons
#todo lower-case
#   todo :: messy formatting

# Normal code
def add(a, b):
    return a + b  # TODO inline todo

## TODO: check edge cases
def divide(a, b):
    if b == 0:
        raise ValueError("nope")  # TODO::: handle more gracefully
    return a / b

### TODO: multiline example start
"""
Some docstring
TODO: this one is inside a docstring
TODO:::
"""
### TODO end multiline

class Example:
    pass  # TODO  finish this class

# Extra weird cases
#### TODO   :
#####   TODO::::
#   ###    TODO:: weird prefix

