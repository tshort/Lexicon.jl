using Lexicon, Docile
using Base.Test

# some basic tests

results   = doctest(Lexicon)
formatted = stringmime("text/plain", results)

stringmime("text/plain", passed(results))
stringmime("text/plain", failed(results))
stringmime("text/plain", skipped(results))

results = @query ""
stringmime("text/plain", results)

results = @query @query
stringmime("text/plain", results)

results = @query doctest(Lexicon)
stringmime("text/plain", results)

results = @query Docile.Documentation
stringmime("text/plain", results)

dir = joinpath(tempdir(), randstring())
f = joinpath(dir, "index.html")
save(f, Lexicon; mathjax = true)
rm(dir, recursive = true)
