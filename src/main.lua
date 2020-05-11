local Utils = require "utils"
local Inputoutput = require "inputoutput"
local Game = require "game"
local Scheduler = require "scheduler"

function startUp(fileName)
    local gameSet = Inputoutput.readFile(fileName)
    local start = Utils.getStart(gameSet.maze)
    print("Avvio")
    print("Vita di partenza " .. gameSet.life)
    Utils.printMaze(gameSet.maze)
    local result = Scheduler.execute(gameSet.maze, start.row, start.column, gameSet.life)
    local gameResult = {life = result.life, maze = result.maze}
    print("Risultato finale")
    print("Vita finale " .. gameResult.life)
    Utils.printMaze(gameResult.maze)
    Inputoutput.writeFile(gameResult, start.row, start.column)
end

startUp("input.txt")
