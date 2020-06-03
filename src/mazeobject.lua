local Game = require "game"

local Maze = {}

function Maze.new()
    return setmetatable({}, Maze)
end

Maze.__index = Maze

Maze.__tostring = function(self)
    local mazeToString = ""
    local row = ""
    for r, column in ipairs(self) do
        for c, cell in ipairs(column) do
            row = row .. cell
        end
        mazeToString = mazeToString .. row .. "\n"
        row = ""
    end
    return mazeToString
end

Maze.clone = function(self)
    local clone = Maze.new()
    for r, column in pairs(self) do
        clone[r] = {}
        for c, cell in pairs(column) do
            clone[r][c] = cell
        end
    end
    return clone
end

Maze.getStart = function(self)
    for r, column in ipairs(self) do
        for c, cell in ipairs(column) do
            if cell == "i" then
                return {row = r, column = c}
            end
        end
    end
end

Maze.getGoals = function(self)
    local goals = {}
    for r, column in ipairs(self) do
        for c, cell in ipairs(column) do
            if cell == "u" then
                table.insert(goals, {row = r, column = c})
            end
        end
    end
    return goals
end

Maze.__add = function(firstMaze, secondMaze)
    local localMaze = firstMaze:clone()
    local start = localMaze:getStart()

    for r, column in pairs(secondMaze) do
        for c, cell in pairs(column) do
            if (cell == "*") then
                localMaze[r][c] = "*"
            end
        end
    end

    localMaze[start.row][start.column] = "i"
    return localMaze
end

Maze.getCellEffect = function(self, row, column, life)
    local cellValue = self[row][column]
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

Maze.addTrace = function(self, row, column)
    local cloneMaze = self:clone()
    cloneMaze[row][column] = "*"
    return cloneMaze
end

Maze.deadEndReduce = function(self)
    local localMaze = self:clone()

    for r = 2, #localMaze - 1 do
        for c = 2, #localMaze[r] - 1 do
            local cell = localMaze[r][c]
            if (cell == "p") then
                localMaze[r][c] = "m"
            end
        end
    end

    for r = 2, #localMaze - 1 do
        for c = 2, #localMaze[r] - 1 do
            local cell = localMaze[r][c]
            if (cell ~= "m") then
                localMaze = reduce(localMaze, r, c)
            end
        end
    end
    return localMaze
end

function reduce(maze, r, c)
    local localMaze = maze:clone()

    if (not admissible(localMaze[r][c])) then
        return localMaze
    end
    -- print(maze)
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

return Maze
