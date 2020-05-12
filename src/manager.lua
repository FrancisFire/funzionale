local gameManagerExport = {}

function scheduleNextMoves(managerTable, nextLevelManager)
    for k, f in pairs(managerTable) do
        nextLevelManager = f(nextLevelManager)
    end
    return nextLevelManager
end

function compareCellValues(managerTable)
    local results =
        map(
        function(funToExec)
            return {funResult = funToExec(), fun = funToExec}
        end,
        managerTable
    )

    local winningResults =
        map(
        function(singleTable)
            return singleTable.funResult
        end,
        filter(
            function(singleTable)
                return singleTable.funResult.win
            end,
            results
        )
    )

    managerTable =
        map(
        function(singleTable)
            return singleTable.fun
        end,
        filter(
            function(singleTable)
                return not singleTable.funResult.lose and not singleTable.funResult.win
            end,
            results
        )
    )

    if (#winningResults == 0) then
        return nil, managerTable
    end
    return calcOptimalResult(winningResults), managerTable
end

function map(f, collection)
    local result = {}
    for k, v in pairs(collection) do
        table.insert(result, f(v))
    end
    return result
end

function filter(f, collection)
    local result = {}
    for _, v in pairs(collection) do
        if (f(v)) then
            table.insert(result, v)
        end
    end
    return result
end

function calcOptimalResult(resTable)
    local function func(tmpTable, minimum)
        if (tmpTable == nil) then
            return minimum
        end
        local localTable = deepCopyResultTable(tmpTable)
        local head = table.remove(localTable, 1)

        if (minimum == nil) then
            return func(localTable, head)
        else
            if ((head.steps < minimum.steps) or (head.steps == minimum.steps and head.life < minimum.life)) then
                return func(localTable, head)
            else
                return func(localTable, minimum)
            end
        end
    end

    return func(resTable, nil)
end

function deepCopyResultTable(resultsTable)
    local newResultsTable = {}
    for k, singleResultTable in pairs(resultsTable) do
        local newSingleResultTable = {}
        for i, value in pairs(singleResultTable) do
            newSingleResultTable[i] = value
        end
        newResultsTable[k] = newSingleResultTable
    end
end

function gameManagerExport.executeMoves(managerTable)
    local res, managerTable = compareCellValues(managerTable) --cicla i valori delle caselle dello scheduler e fa i confronti, non ancora funzionale
    if (res) then
        return res
    end

    if (#managerTable == 0) then --non ancora funzionale
        return nil
    end

    local nextLevelManager = gameManagerExport.getNewManagerTable()
    nextLevelManager = scheduleNextMoves(managerTable, nextLevelManager) --popolo lo scheduler del livello successivo

    return gameManagerExport.executeMoves(nextLevelManager)
end

function gameManagerExport.addFunction(managerTable, functionToAdd)
    local newManagerTable = {}
    if (#managerTable ~= 0) then
        for k, v in pairs(managerTable) do
            newManagerTable[k] = v
        end
    end
    table.insert(newManagerTable, functionToAdd)
    return newManagerTable
end

function gameManagerExport.getNewManagerTable()
    return {}
end

return gameManagerExport
