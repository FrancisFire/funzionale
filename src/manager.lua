local gameManagerExport = {}
local Game = require "game"
local Utils = require "utils"

function getResultFunctionTable(functionTable)
    local results =
        Utils.map(
        function(funToExec)
            return {result = funToExec(), fun = funToExec}
        end,
        functionTable
    )
    return results
end

function getWinningResults(resultsWithFunctions)
    local winningResultsWithFunctions =
        Utils.filter(
        function(singleResultWithFunction)
            return singleResultWithFunction.result.win
        end,
        resultsWithFunctions
    )

    local winningResults =
        Utils.map(
        function(singleTable)
            return singleTable.result
        end,
        winningResultsWithFunctions
    )
    return winningResults
end

function getToContinueFunctions(resultFunctionTable)
    --  print("Funzioni prima del Utils.filter " .. #resultFunctionTable)
    local toContinueResultsWithFunctions = -- potrebbe essere vuota
        Utils.filter(
        function(singleResultWithFunction)
            return (not singleResultWithFunction.result.win)
        end,
        resultFunctionTable
    )
    --  print("Funzioni dopo il Utils.filter " .. #toContinueResultsWithFunctions)

    local toContinueFunctions =
        Utils.map(
        function(singleTable)
            return singleTable.fun
        end,
        toContinueResultsWithFunctions
    )
    return toContinueFunctions
end

function compareCellValues(managerTable)
    local resultsWithFunctions = getResultFunctionTable(managerTable)
    local winningResults = getWinningResults(resultsWithFunctions)
    local toContinueFunctions = getToContinueFunctions(resultsWithFunctions)

    return winningResults, toContinueFunctions
end

function scheduleNextMoves(functionsTable)
    --   print("Funzioni prima dello schedule " .. #functionsTable)

    local nextLevelManager = gameManagerExport.getNewManagerTable()
    for _, moveFunction in pairs(functionsTable) do --interagisco con ogni funzione che può continuare il gioco
        for i = 1, 4 do
            local nextMoveParams = moveFunction() --richiamo 4 volte le coroutine che mi danno i parametri per la prossima mossa

            if (not nextMoveParams.willLose) then
                local nextMoveFunction =
                    Game.BFSGame(
                    nextMoveParams.newMaze,
                    nextMoveParams.newRow,
                    nextMoveParams.newColumn,
                    nextMoveParams.newSteps,
                    nextMoveParams.newLife
                )
                nextLevelManager = gameManagerExport.addFunction(nextLevelManager, nextMoveFunction) --aggiungo al manager le funzioni che gestiscono le prossime mosse
            end
        end
    end
    --   print("Funzioni dopo lo schedule " .. #nextLevelManager)

    return nextLevelManager
end

function calcOptimalResult(resultsTable)
    local function func(tmpTable, minimum)
        if (next(tmpTable) == nil) then
            return minimum
        end
        local localTable = {}
        for _, v in pairs(tmpTable) do
            table.insert(localTable, v)
        end
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

    return func(resultsTable, nil)
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

function gameManagerExport.executeMoves(managerTable, index)
    -- print("Esecuzione di livello " .. index)
    --  print("Celle da analizzare " .. #managerTable)
    local winningResults, toContinueFunctions = compareCellValues(managerTable) --cicla i valori delle caselle dello scheduler e fa i confronti, non ancora funzionale

    if next(winningResults) ~= nil then --ci sono caselle vincenti
        --     print("Caselle vincenti " .. #winningResults)
        return calcOptimalResult(winningResults)
    end

    if next(toContinueFunctions) == nil then --non ci sono funzioni che possono proseguire a questo livello, hanno tutte perso o vinto
        return nil
    end

    -- non ci sono caselle vincenti a questo livello ma ci sono funzioni che possono proseguire
    local nextLevelManagerTable = scheduleNextMoves(toContinueFunctions) --ottengo il manager contenente le funzioni delle caselle successive
    return gameManagerExport.executeMoves(nextLevelManagerTable, index + 1)
end

function gameManagerExport.addFunction(functionsTable, functionToAdd)
    local newFunctionsTable = {}
    for _, fun in pairs(functionsTable) do
        table.insert(newFunctionsTable, fun)
    end

    table.insert(newFunctionsTable, functionToAdd)
    return newFunctionsTable
end

function gameManagerExport.getNewManagerTable()
    return {}
end

return gameManagerExport
