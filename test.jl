using Git

# https://stackoverflow.com/a/56248596/1601695
dyldenv = [
    "DYLD_PRINT_LIBRARIES=1",
    "DYLD_PRINT_LIBRARIES_POST_LAUNCH=1",
   "DYLD_PRINT_RPATHS=1"
]

@info "Running git submodule"
try
  run(`$(git()) submodule add foo bar`)
catch e
  @error "Expected fail" exception = (e, catch_backtrace())
end

@info "Running git version, for libs"
gitcmd = git()
Cmd(`$(gitcmd.exec[1]) version`, env=vcat(gitcmd.env, dyldenv)) |> run

@info "Run git submodule, but print libs"
run(Cmd(`$(gitcmd) submodule add foo bar`, env=vcat(gitcmd.env, dyldenv)))
