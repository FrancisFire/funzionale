local utilsExport = {}

function utilsExport.map(f, collection)
    local result = {}
    for k, v in pairs(collection) do
        table.insert(result, f(v))
    end
    return result
end

function utilsExport.filter(f, collection)
    local result = {}
    for _, v in pairs(collection) do
        if (f(v)) then
            table.insert(result, v)
        end
    end
    return result
end

function utilsExport.reduce(f, collection)
    local r = nil
    for _, v in pairs(collection) do
        r = f(r, v)
    end
    return r
end

return utilsExport
