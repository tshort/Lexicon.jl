## Extending docs format support ––––––––––––––––––––––––––––––––––––––––––––––––––––––––

parsedocs(ds::Docs{:md}) = Markdown.parse(data(ds))

## Common –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

@doc md"""
Write the documentation stored in `modulename` to the specified `file`
in the format guessed from the file's extension.

If MathJax support is required then the optional keyword argument
`mathjax::Bool` may be given. MathJax uses `\(...\)` for in-line maths
and `\[...\]` or `$$...$$` for display equations.

Currently supported formats: `HTML`.

**Example:**

The documentation for this package was created in the following manner.
All commands are run from the top-level folder in the package.

```julia
save("doc/site/master/index.html", Lexicon)

```

From the command line, or using `run`, push the `doc/site` directory
to the `gh-pages` branch on the package repository after pushing the
changes to the `master` branch.

```
git add .
git commit -m "documentation changes"
git push origin master
git subtree push --prefix doc/site origin gh-pages

```

If this is the first push to the branch then the site may take some time
to become available. Subsequent updates should appear immediately. Only
the contents of the `doc/site` folder will be pushed to the branch.

The documentation will be available from
`https://USER_NAME.github.io/PACKAGE_NAME/FILE_PATH.html`.

""" ->
function save(file::String, modulename::Module; mathjax = false)
    mime = MIME("text/$(strip(last(splitext(file)), '.'))")
    save(file, mime, documentation(modulename); mathjax = mathjax)
end

const CATEGORY_ORDER = [:module, :function, :method, :type, :macro, :global]

# Dispatch container for metadata display.
type Meta{keyword}
    content
end

# Cleanup object signatures. Remove method location links.
writeobj(any)       = string(any)
writeobj(m::Method) = first(split(string(m), " at "))

function addentry!{category}(index, obj, entry::Entry{category})
    section, pair = get!(index, category, (String, Any)[]), (writeobj(obj), obj)
    insert!(section, searchsortedlast(section, pair, by = x -> first(x)) + 1, pair)
end

# from base/methodshow.jl
function url(m::Meta{:source})
    line, file = m.content
    try
        d = dirname(file)
        u = Pkg.Git.readchomp(`config remote.origin.url`, dir=d)
        u = match(Pkg.Git.GITHUB_REGEX,u).captures[1]
        root = cd(d) do # dir=d confuses --show-toplevel, apparently
            Pkg.Git.readchomp(`rev-parse --show-toplevel`)
        end
        if beginswith(file, root)
            commit = Pkg.Git.readchomp(`rev-parse HEAD`, dir=d)
            return "https://github.com/$u/tree/$commit/"*file[length(root)+2:end]*"#L$line"
        else
            return Base.fileurl(file)
        end
    catch
        return Base.fileurl(file)
    end
end

## Format-specific rendering ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

include("render/plain.jl")
include("render/html.jl")
