local gameExport = {}
local Manager = require "manager"

function gameExport.move(maze, row, column, steps, life)
    return coroutine.wrap(
        function()
            --print("Prima parte")
            local newSteps = steps + 1
            local result = getCellEffect(maze, row, column, life)
            local newLife = result.life
            local nextLevelManager =
                coroutine.yield({maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose})
            -- print("Seconda parte")
            local tracedMaze = traceMaze(maze, row, column)
            for k, newDir in pairs(Directions) do
                local x, y = newDir(row, column)
                nextLevelManager =
                    Manager.addFunction(nextLevelManager, gameExport.move(tracedMaze, x, y, newSteps, newLife)) --aggiunge nuove direazioni
            end
            --print("Fine move")
            return nextLevelManager
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
    --
    --[[printMove(
        row,
        column,
        life,
        cellValue,
        lifeFunctions[cellValue](life),
        (cellValue == "u" and "true" or "false"),
        (lifeFunctions[cellValue](life) <= 0 and "true" or "false")
    )]] return {
        life = lifeFunctions[cellValue](life),
        lose = lifeFunctions[cellValue](life) <= 0,
        win = cellValue == "u"
    }
end

Directions = {
    function(row, column)
        return row, column + 1
    end,
    function(row, column)
        return row, column - 1
    end,
    function(row, column)
        return row + 1, column
    end,
    function(row, column)
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

return gameExport
