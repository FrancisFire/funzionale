local gameExport = {}
local Utils = require "utils"

function gameExport.DFSGame(maze, row, column, steps, life)
    local newSteps = steps + 1
    local result = getCellEffect(maze, row, column, life)
    local newLife = result.life
    if (result.lose or result.win) then
        return {maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose}
    end
    local tracedMaze = traceMaze(maze, row, column)
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
    return calcOptimalResult(winningResults) -- sono presenti vincitori, viene ritornato il migliore
end

function gameExport.BFSGame(maze, row, column, steps, life)
    return coroutine.wrap(
        function()
            local newSteps = steps + 1
            local result = getCellEffect(maze, row, column, life)
            local newLife = result.life
            if (result.lose) then
                return {maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose}
            end
            coroutine.yield({maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose}) -- ritorna l'analisi della casella

            local tracedMaze = traceMaze(maze, row, column)
            for k, newDirection in pairs(gameExport.Directions) do
                local newRow, newColumn = newDirection(row, column)
                local futureParams = getCellEffect(tracedMaze, newRow, newColumn, newLife)
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

function calcOptimalResult(resultsTable)
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

function traceMaze(maze, row, column)
    local cloneMaze = gameExport.cloneMaze(maze)
    cloneMaze[row][column] = "*"
    return cloneMaze
end

function getCellEffect(maze, row, column, life)
    local cellValue = maze[row][column]
    local lifeFunctions = {
        ["0"] = function(life)
            return life
        end,
        ["1"] = function(life)
            return life + 1
        end,
        ["2"] = function(life)
            return life + 2
        end,
        ["3"] = function(life)
            return life + 3
        end,
        ["4"] = function(life)
            return life + 4
        end,
        ["5"] = function(life)
            return life - 1
        end,
        ["6"] = function(life)
            return life - 2
        end,
        ["7"] = function(life)
            return life - 3
        end,
        ["8"] = function(life)
            return life - 4
        end,
        ["9"] = function(life)
            return life * 2
        end,
        ["f"] = function(life)
            return life // 2
        end,
        ["u"] = function(life)
            return life
        end,
        ["i"] = function(life)
            return life
        end,
        ["m"] = function(life)
            return 0
        end,
        ["p"] = function(life)
            return 0
        end,
        ["*"] = function(life)
            return 0
        end
    }
    local newLife = lifeFunctions[cellValue](life)
    return {
        life = newLife,
        lose = newLife <= 0,
        win = (cellValue == "u")
    }
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

function getGoals(maze)
    local goals = {}
    for r, column in ipairs(maze) do
        for c, cell in ipairs(column) do
            if cell == "u" then
                table.insert(goals, {row = r, column = c})
            end
        end
    end
    return goals
end

function gameExport.getStart(maze)
    for r, column in ipairs(maze) do
        for c, cell in ipairs(column) do
            if cell == "i" then
                return {row = r, column = c}
            end
        end
    end
end

function gameExport.cloneMaze(maze)
    local clone = {}
    for r, column in pairs(maze) do
        clone[r] = {}
        for c, cell in pairs(column) do
            clone[r][c] = cell
        end
    end
    return clone
end

function gameExport.printMaze(maze)
    local row = ""
    for r, column in ipairs(maze) do
        for c, cell in ipairs(column) do
            row = row .. cell
        end
        print(row)
        row = ""
    end
end

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
    gameExport.printMaze(maze)
    print("-------------------------")
end

function gameExport.getSolutionMaze(originalMaze, tracedMaze)
    local localMaze = gameExport.cloneMaze(originalMaze)
    local start = gameExport.getStart(localMaze)

    for r, column in pairs(tracedMaze) do
        for c, cell in pairs(column) do
            if (cell == "*") then
                localMaze[r][c] = "*"
            end
        end
    end

    localMaze[start.row][start.column] = "i"
    return localMaze
end

return gameExport
