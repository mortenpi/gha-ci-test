gitlibs = "/Users/runner/.julia/artifacts/fc4adbf1d7551761c1693502d0b221eb0f780b59/lib"

dylibs = [
    "/Users/runner/.julia/artifacts/397fee52d94fc3404c3e466a6a8277ad9fdde715/lib/libgettextlib-0.21.dylib",
    "/Applications/Julia-1.7.app/Contents/Resources/julia/lib/julia/libpcre2-8.0.dylib",
    "/Applications/Julia-1.7.app/Contents/Resources/julia/lib/julia/libz.1.dylib",
    "/Users/runner/.julia/artifacts/571cdee3242d2dddfc82ce9b2b9a25ba523c78e9/lib/libiconv.2.dylib",
    "/Users/runner/.julia/artifacts/397fee52d94fc3404c3e466a6a8277ad9fdde715/lib/libintl.8.dylib",
    "/Users/runner/.julia/artifacts/ff3a519cd5338603e027bb508416673c2c28e6b9/lib/libxml2.2.dylib",
]

chmod(dirname(gitlibs), 0o777)
mkpath(gitlibs)
for dylib in dylibs
    @info "Copying:" dylib gitlibs
    cp(dylib, gitlibs)
end
