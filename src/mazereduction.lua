local Inputoutput = require "inputoutput"
local Game = require "game"

local mazeReductionExport = {}

function mazeReductionExport.deadEndReduce(maze)
    local localMaze = Game.cloneMaze(maze)

    for r = 2, #localMaze - 1 do
        for c = 2, #localMaze[r] - 1 do
            local cell = localMaze[r][c]
            if (cell == "p") then
                localMaze[r][c] = "m"
            end
            --     print(r .. "" .. c)
        end
    end

    for r = 2, #localMaze - 1 do
        for c = 2, #localMaze[r] - 1 do
            local cell = localMaze[r][c]
            if (cell ~= "m") then
                localMaze = reduce(localMaze, r, c)
            -- print("---------------------")
            end
        end
    end
    return localMaze
end

function reduce(maze, r, c)
    local localMaze = Game.cloneMaze(maze)

    if (not admissible(localMaze[r][c])) then
        return localMaze
    end
    -- Game.printMaze(maze)
    -- print("---------------------")
    local next = nil
    for k, newDir in pairs(Game.Directions) do
        local x, y = newDir(r, c)
        -- print("r " .. r .. " c " .. c .. " x " .. x .. " y " .. y)
        local nextCell = localMaze[x][y]
        if (nextCell ~= "m") then
            if (next == nil) then
                -- print("free")
                next = newDir
            else
                next = nil
                --  print("break")
                break
            end
        end
    end
    if (next ~= nil) then
        localMaze[r][c] = "m"
        local x, y = next(r, c)
        return reduce(localMaze, x, y)
    end
    return localMaze
end

function admissible(cell)
    return cell ~= "m" and cell ~= "i" and cell ~= "u"
end

return mazeReductionExport
