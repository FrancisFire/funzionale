local Game = require "game"
local Utils = require "utils"

local Manager = {}

function Manager.new()
    return setmetatable({}, Manager)
end

Manager.__index = Manager

Manager.executeMoves = function(self, index)
    -- print("Esecuzione di livello " .. index)
    --  print("Celle da analizzare " .. #managerTable)
    local winningResults, toContinueFunctions = self:compareCellValues() --cicla i valori delle caselle dello scheduler e fa i confronti, non ancora funzionale

    if next(winningResults) ~= nil then --ci sono caselle vincenti
        --     print("Caselle vincenti " .. #winningResults)
        return Game.calcOptimalResult(winningResults)
    end

    if next(toContinueFunctions) == nil then --non ci sono funzioni che possono proseguire a questo livello, hanno tutte perso o vinto
        return nil
    end

    -- non ci sono caselle vincenti a questo livello ma ci sono funzioni che possono proseguire
    local newManager = scheduleNextMoves(toContinueFunctions) --ottengo il manager contenente le funzioni delle caselle successive
    return newManager:executeMoves(index + 1)
end

Manager.addFunction = function(self, functionToAdd)
    local newManager = Manager.new()
    for _, fun in pairs(self) do
        table.insert(newManager, fun)
    end

    table.insert(newManager, functionToAdd)
    return newManager
end

Manager.getResultFunctionTable = function(self)
    local results =
        Utils.map(
        function(funToExec)
            return {result = funToExec(), fun = funToExec}
        end,
        self
    )
    return results
end

Manager.compareCellValues = function(manager)
    local resultsWithFunctions = manager:getResultFunctionTable()
    local winningResults = getWinningResults(resultsWithFunctions)
    local toContinueFunctions = getToContinueFunctions(resultsWithFunctions)

    return winningResults, toContinueFunctions
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

function scheduleNextMoves(toContinueFunctions)
    --   print("Funzioni prima dello schedule " .. #functionsTable)

    local nextLevelManager = Manager.new()
    for _, moveFunction in pairs(toContinueFunctions) do --interagisco con ogni funzione che può continuare il gioco
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
                nextLevelManager = nextLevelManager:addFunction(nextMoveFunction) --aggiungo al manager le funzioni che gestiscono le prossime mosse
            end
        end
    end
    --   print("Funzioni dopo lo schedule " .. #nextLevelManager)

    return nextLevelManager
end

return Manager
