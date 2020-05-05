utils = require "utils"

function move(maze, row, column, steps, life)
    local newSteps = steps + 1 
    local result = applyCellEffect(localMaze, row, column, life)
    if(result.lose) then return {maze = maze, steps = newSteps, life = newLife, win = false} 
    elseif(result.win) then return {maze = maze, steps = newSteps, life = newLife, win = true} 
    else 
        local tracedMaze = tracedMaze(maze, row, column)
        
        results = {}
        for k,newDir in pairs(utils.Directions)do
            local x,y = newDir(row, column)
            
            local subRes = move(tracedMaze, x, y, steps, newLife)
            if(subRes.win) then table.insert(results, subRes) end
        end
        local result = calcOptimalResult(results)
        if(result == nil) then return {maze = maze, steps = newSteps, life = newLife, win = false}
        else return result
end

function calcOptimalResult(resTable)
    
    local func = function (tmpTable, minimum)
        if(#tmpTable == 0) then return minimum end
        local head = table.remove(tmpTable, 1)
        if(minimum == nil) then return func(tmpTable, head)
        else if((head.steps < minimum.steps) or (head.steps == minimum.steps and head.life < minimum.life)) then return func(tmpTable, head)
    end
    return func(resTable, nil) end
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
    return {life = lifeFunctions[cellValue](life), lose = lifeFunctions[cellValue](life) <= 0, win = cellValue == "u"}
end
