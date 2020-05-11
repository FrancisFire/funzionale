local Utils = {}

Utils.Directions = {
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

function Utils.getGoals(maze)
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

function Utils.getStart(maze)
    for r, column in ipairs(maze) do
        for c, cell in ipairs(column) do
            if cell == "i" then
                return {row = r, column = c}
            end
        end
    end
end

function Utils.cloneMaze(maze)
    local clone = {}
    for r, column in ipairs(maze) do
        clone[r] = {}
        for c, cell in ipairs(column) do
            clone[r][c] = cell
        end
    end
    return clone
end

function Utils.printMaze(maze)
    local row = ""
    for r, column in ipairs(maze) do
        for c, cell in ipairs(column) do
            row = row .. cell
        end
        print(row)
        row = ""
    end
end

function Utils.printMove(row, column, life, cellValue, newLife, win, lost)
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

return Utils
