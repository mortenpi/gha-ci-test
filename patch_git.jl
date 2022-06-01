git_install_dir = joinpath(isempty(ARGS) ? joinpath(@__DIR__, "git") : ARGS[1], "libexec")
isdir(git_install_dir) || error("Not a directory: $(git_install_dir)")
for (root, dirs, files) in walkdir(git_install_dir)
    for file in files
        endswith(file, ".orig") && continue
        path = joinpath(root, file)
        isfile(path) || @warn "Non-file: $path"
        islink(path) && continue
        Sys.isexecutable(path) || continue

        line = readline(path)
        startswith(line, "#!") || continue
        if line != "#!/bin/sh"
            @warn "Not a shell script" path line
            continue
        end
        @info "Patching ($line): $path"
        origfile = "$path.orig"
        isfile(origfile) || mv(path, origfile)
        lines = readlines(origfile)
        open(path, "w") do io
            println(io, lines[1])
            println(io, "echo RUNNING: $file >&1")
            println(io, "echo RUNNING: $file >&2")
            println(io, "echo DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH")
            println(io, "export DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH_SIPHACK")
            println(io, "echo DYLD_FALLBACK_LIBRARY_PATH=\$DYLD_FALLBACK_LIBRARY_PATH")
            println(io, "export DYLD_FALLBACK_LIBRARY_PATH=\$DYLD_FALLBACK_LIBRARY_PATH_SIPHACK")
            for line in lines[2:end]
                println(io, line)
            end
        end
        chmod(path, stat(origfile).mode)
    end
end
