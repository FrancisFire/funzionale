utils = require "utils"

local IO = {}
function IO.readFile(filename)
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
                game.maze[row][column] = c

                column = column + 1
            end
        end
        row = row + 1
    end

    return game
end

function IO.writeFile(game)
    local file = io.open("output.txt", "w")
    file:write(game.life .. "\r")
    local row = ""
    for r = 1, #game.maze do
        for c = 1, #game.maze[r] do
            row = row .. game.maze[r][c]
        end
        file:write(row .. "\r")
        row = ""
    end
    file.close()
end

IO.writeFile(IO.readFile("input.txt"))

return IO
