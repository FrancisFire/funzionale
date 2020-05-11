local utils = require "utils"
local inputoutput = require "inputoutput"
local gameExport = {}

function gameExport.move(maze, row, column, steps, life)
    local newSteps = steps + 1
    local result = applyCellEffect(maze, row, column, life)
    local newLife = result.life
    local nextLevelScheduler = coroutine.yield( {maze = maze, steps = newSteps, life = newLife, win = result.win, lose = result.lose} ) 
    
    local tracedMaze = traceMaze(maze, row, column)
    for k, newDir in pairs(utils.Directions) do
        local x, y = newDir(row, column)
        nextLevelScheduler:addFunction(coroutine.create(gameExport.move(tracedMaze, x, y, newSteps, newLife, nextLevelScheduler))) --aggiunge nuove direazioni
    end
    return
end

function gameExport.calcOptimalResult(resTable)
    local function func(tmpTable, minimum)
        if (#tmpTable == 0) then
            return minimum
        end
        local head = table.remove(tmpTable, 1)
        if (minimum == nil) then
            return func(tmpTable, head)
        else
            if ((head.steps < minimum.steps) or (head.steps == minimum.steps and head.life < minimum.life)) then
                return func(tmpTable, head)
            else
                return func(tmpTable, minimum)
            end
        end
    end
    return func(resTable, nil)
end

function traceMaze(maze, row, column)
    local cloneMaze = utils.cloneMaze(maze)
    cloneMaze[row][column] = "x"
    return cloneMaze
end

function applyCellEffect(maze, row, column, life)
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
    --[[utils.printMove(
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

return gameExport
