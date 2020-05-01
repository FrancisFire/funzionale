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
                print(r .. c)
            end
        end
    end
    return goals
end

return Utils
