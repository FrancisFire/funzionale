local Utils = {}

Utils.Directions = {}

function Utils.Directions.up(row, column)
    return row, column + 1
end

function Utils.Directions.down(row, column)
    return row, column - 1
end
function Utils.Directions.left(row, column)
    return row - 1, column
end

function Utils.Directions.right(row, column)
    return row + 1, column
end

function Utils.getGoals(maze)
    local goals = {}
    for r = 1, #maze do
        for c = 1, #maze[r] do
            if maze[r][c] == "u" then
                table.insert(goals, {row = r, column = c})
            end
        end
    end
    return goals
end

function Utils.getStart(maze)
    for r = 1, #maze do
        for c = 1, #maze[r] do
            if maze[r][c] == "i" then
                return {row = r, column = c}
            end
        end
    end
end

function Utils.cloneMaze(maze)
    local clone = {}
    for r, column in pairs(maze) do
        for c, cell in pairs(column) do
            clone[r][c] = cell
        end
    end
    return clone
end

return Utils
