# Documentation Requirements

## Attributes
Each function must have at least two documented attributes: 'type' and 'signature'. Each function can also have additional semi-optional (required in some circumstances) and optional attributes. The only semi-optional attribute as of now is `return`, which is documented here.

- The 'type' attribute states one or more ways in which the function was designed to be run. The following are the standard types:
  - `direct`: Directly run the function to fulfil its purpose.
  - `capture`: Run the function in a subshell and capture its output with "$(func)" (with quotes).

- The 'signature' attribute states the required and optional arguments the function takes.

- The 'return' attribute states what values the function will return.
  - Functions are assumed to return 0 if none of the requirements to return enything else are satisfied, so '0' doesn't need to be in the list of return values.
  - All return values other than 0 should be documented.
  - If the function never returns 0, then this should be stated.
  - If the function only ever returns 0, then this attribute is not needed.

## Return values
Functions should return values in different ranges depending on the circumstances. The ranges are defined as follows (the return value of functions should satisfy the following criteria, where 'r' represents the return value):

- r <= -64:
  - Currently not used.
- -64 < r < 0:
  - This range is for fatal errors.
  - Fatal errors are errors which either cannot, or should not, be recovered from. The case of 'should not be recovered from' includes cases of obvious developer error (eg. incorrect arguments to functions) - it's best to let them know now rather than later!
  - The function should return `-1` if (and only if) it receives incorrect arguments.
- r == 0:
  - Zero should be returned if the function generally succeeded in its objective, even if it didn't go perfectly (eg. had to resort to non-ideal methods).
- 0 < r < 64:
  - This range is for recoverable errors.
  - Recoverable errors are errors which are somewhat likely to be encountered and can be either safely ignored, or easily handled.
- r >= 64
  - This range is for 'errors' that are not fatal, or even need to be recovered from - these are more informational return values (eg. forbidden from completing the function's objective due to user settings).

