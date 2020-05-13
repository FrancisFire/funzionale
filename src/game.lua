local gameExport = {}

function gameExport.getMoveFunction(maze, row, column, steps, life)
    return coroutine.wrap(
        function()
            local newSteps = steps + 1
            local result = getCellEffect(maze, row, column, life)
            local newLife = result.life

            coroutine.yield({maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose}) -- ritorna l'analisi della casella

            local tracedMaze = traceMaze(maze, row, column)
            for k, newDirection in pairs(Directions) do
                local newRow, newColumn = newDirection(row, column)
                coroutine.yield(
                    {
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

function traceMaze(maze, row, column)
    local cloneMaze = cloneMaze(maze)
    cloneMaze[row][column] = "x"
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
        ["x"] = function(life)
            return 0
        end
    }
    local newLife = lifeFunctions[cellValue](life)
    --[[printMove(
        row,
        column,
        life,
        cellValue,
        newLife,
        (cellValue == "u" and "true" or "false"),
        (newLife <= 0 and "true" or "false")
    )]]
    return {
        life = newLife,
        lose = newLife <= 0,
        win = (cellValue == "u")
    }
end

Directions = {
    ["N"] = function(row, column)
        return row, column + 1
    end,
    ["S"] = function(row, column)
        return row, column - 1
    end,
    ["E"] = function(row, column)
        return row + 1, column
    end,
    ["W"] = function(row, column)
        return row - 1, column
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

function cloneMaze(maze)
    local clone = {}
    for r, column in ipairs(maze) do
        clone[r] = {}
        for c, cell in ipairs(column) do
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

return gameExport
