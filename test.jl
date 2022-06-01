using Git

# https://stackoverflow.com/a/56248596/1601695
dyldenv = [
    "DYLD_PRINT_LIBRARIES=1",
    "DYLD_PRINT_LIBRARIES_POST_LAUNCH=1",
   "DYLD_PRINT_RPATHS=1"
]

run(`$(git()) submodule add foo bar`)
