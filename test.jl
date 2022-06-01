using Git

function findvar(vs, name)
    r = Regex("\\s*$(name)\\s*=\\s*(.+)")
    idx = findfirst(contains(r), vs)
    idx === nothing && return nothing
    m = match(r, vs[idx])
    return m[1]
end

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
    @error "run failed" exception = (e, catch_backtrace())
end

@info "Running git version, for libs"
gitcmd = git()
try
    Cmd(`$(gitcmd.exec[1]) version`, env=vcat(gitcmd.env, dyldenv)) |> run
catch e
    @error "run failed" exception = (e, catch_backtrace())
end

@info "Run git submodule, but print libs"
try
    run(Cmd(`$(gitcmd) submodule add foo bar`, env=vcat(gitcmd.env, dyldenv)))
catch e
    @error "run failed" exception = (e, catch_backtrace())
end

@info "Run git submodule with SIPHACK"
DYLD_FALLBACK_LIBRARY_PATH = findvar(gitcmd.env, "DYLD_FALLBACK_LIBRARY_PATH")
println("DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH")
run(
    Cmd(`$(gitcmd) submodule add foo bar`,
    env = vcat(gitcmd.env, dyldenv, ["SIPHACK_DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH"]),
))
