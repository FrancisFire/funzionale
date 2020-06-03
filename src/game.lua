local gameExport = {}
local Utils = require "utils"

function gameExport.DFSGame(maze, row, column, steps, life)
    local newSteps = steps + 1
    local result = maze:getCellEffect(row, column, life)
    local newLife = result.life
    if (result.lose or result.win) then
        return {maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose}
    end
    local tracedMaze = maze:addTrace(row, column)
    local winningResults = {}
    for k, newDirection in ipairs(gameExport.Directions) do
        local newRow, newColumn = newDirection(row, column)
        local nextResults = gameExport.DFSGame(tracedMaze, newRow, newColumn, newSteps, newLife)
        if (nextResults.win) then
            table.insert(winningResults, nextResults)
        end
    end
    if (next(winningResults) == nil) then
        return {maze = maze, steps = steps, life = life, win = false, lose = true}
    end -- non sono presenti vincitori tra i vicini
    return gameExport.calcOptimalResult(winningResults) -- sono presenti vincitori, viene ritornato il migliore
end

function gameExport.BFSGame(maze, row, column, steps, life)
    return coroutine.wrap(
        function()
            local newSteps = steps + 1
            local result = maze:getCellEffect(row, column, life)
            local newLife = result.life
            if (result.lose) then
                return {maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose}
            end
            coroutine.yield({maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose}) -- ritorna l'analisi della casella

            local tracedMaze = maze:addTrace(row, column)
            for k, newDirection in pairs(gameExport.Directions) do
                local newRow, newColumn = newDirection(row, column)
                local futureParams = tracedMaze:getCellEffect(newRow, newColumn, newLife)
                coroutine.yield(
                    {
                        willLose = futureParams.lose,
                        newMaze = tracedMaze,
                        newRow = newRow,
                        newColumn = newColumn,
                        newSteps = newSteps,
                        newLife = newLife
                    }
                ) --calcolo dei parametri per le mosse successive
            end
        end
    )
end

function gameExport.calcOptimalResult(resultsTable)
    local function compare(firstResult, secondResult)
        return (firstResult == nil) and secondResult or
            ((secondResult == nil) and firstResult or
                (((firstResult.steps < secondResult.steps) or
                    (firstResult.steps == secondResult.steps and firstResult.life < secondResult.life)) and
                    firstResult or
                    secondResult))
    end

    return Utils.reduce(compare, resultsTable)
end

gameExport.Directions = {
    function(row, column)
        return row, column + 1 -- Nord
    end,
    function(row, column)
        return row, column - 1 -- Sud
    end,
    function(row, column)
        return row + 1, column -- Est
    end,
    function(row, column)
        return row - 1, column -- Ovest
    end
}

function printMove(row, column, life, cellValue, newLife, win, lost)
    print(
        "Riga " ..
            row ..
                " Colonna " ..
                    column ..
                        " Vita " ..
                            life ..
                                " Cella " ..
                                    cellValue .. " Nuova vita " .. newLife .. " Vinto " .. win .. " Perso " .. lost
    )
end

function gameExport.printStep(label, life, maze)
    print("-------------------------")
    print(label)
    print("Vita " .. life)
    print(maze)
    print("-------------------------")
end

return gameExport
