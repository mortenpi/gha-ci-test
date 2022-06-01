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
            println(io, "echo [stdout] RUNNING: $file >&1")
            println(io, "echo [stderr] RUNNING: $file >&2")
            println(io, "echo [\$(date +'%Y-%m-%dT%H:%M:%S%z')] RUNNING: $file >> ~/git-sh-call-log")
            println(io, "echo DYLD_LIBRARY_PATH=\${DYLD_LIBRARY_PATH:-(undefined)}")
            println(io, "echo SIPHACK_DYLD_LIBRARY_PATH=\${SIPHACK_DYLD_LIBRARY_PATH:-(undefined)}")
            println(io, "echo DYLD_FALLBACK_LIBRARY_PATH=\${DYLD_FALLBACK_LIBRARY_PATH:-(undefined)}")
            println(io, "echo SIPHACK_DYLD_FALLBACK_LIBRARY_PATH=\${SIPHACK_DYLD_FALLBACK_LIBRARY_PATH:-(undefined)}")
            print(io, """
            if [ \${SIPHACK_DYLD_LIBRARY_PATH+x} ]; then
              echo "Overriding DYLD_LIBRARY_PATH"
              export DYLD_LIBRARY_PATH=\$SIPHACK_DYLD_LIBRARY_PATH
            fi
            """)
            print(io, """
            if [ \${SIPHACK_DYLD_FALLBACK_LIBRARY_PATH+x} ]; then
              echo "Overriding DYLD_FALLBACK_LIBRARY_PATH"
              export DYLD_FALLBACK_LIBRARY_PATH=\$SIPHACK_DYLD_FALLBACK_LIBRARY_PATH
            fi
            """)
            println(io, "export DYLD_PRINT_LIBRARIES=1")
            println(io, "export DYLD_PRINT_LIBRARIES_POST_LAUNCH=1")
            println(io, "export DYLD_PRINT_RPATHS=1")
            for line in lines[2:end]
                println(io, line)
            end
        end
        chmod(path, stat(origfile).mode)
    end
end
