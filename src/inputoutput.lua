local IOExport = {}

function IOExport.readFile(filename)
    local game = {}

    local row = 0
    game.maze = {}
    for line in io.lines(filename, "l") do
        line = string.gsub(line, "\r", "")
        local column = 1
        if (row == 0) then
            game.life = tonumber(line)
        else
            game.maze[row] = {}
            for c in string.gmatch(line, ".") do
                game.maze[row][column] = verifyCell(c)

                column = column + 1
            end
        end
        row = row + 1
    end

    return game
end

function IOExport.writeFile(life, maze, rowStart, columnStart)
    local file = io.open("output.txt", "w")
    file:write(life .. "\r")
    local row = ""
    for r, column in pairs(maze) do
        for c, cell in pairs(column) do
            row = row .. cell
        end
        file:write(row .. "\r")
        row = ""
    end
    file.close()
end

function verifyCell(cellValue)
    local acceptedCellValues = {
        ["0"] = true,
        ["1"] = true,
        ["2"] = true,
        ["3"] = true,
        ["4"] = true,
        ["5"] = true,
        ["6"] = true,
        ["7"] = true,
        ["8"] = true,
        ["9"] = true,
        ["f"] = true,
        ["u"] = true,
        ["i"] = true,
        ["m"] = true,
        ["p"] = true
    }
    return (acceptedCellValues[cellValue]) and cellValue or "m"
end

return IOExport
