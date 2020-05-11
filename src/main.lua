utils = require "utils"
inputoutput = require "inputoutput"
game = require "game"

function startUp(fileName)
    local gameSet = inputoutput.readFile(fileName)
    local start = utils.getStart(gameSet.maze)
    print("Avvio")
    print("Vita di partenza " .. gameSet.life)
    utils.printMaze(gameSet.maze)
    local result = game.move(gameSet.maze, start.row, start.column, 0, gameSet.life)
    local gameResult = {life = result.life, maze = result.maze}
    print("Risultato finale")
    print("Vita finale " .. gameResult.life)
    utils.printMaze(gameResult.maze)
    inputoutput.writeFile(gameResult, start.row, start.column)
end

startUp("input.txt")
