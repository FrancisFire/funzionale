local Inputoutput = require "inputoutput"
local Game = require "game"

function startUp(fileName)
    local gameSet = Inputoutput.readFile(fileName)
    local start = gameSet.maze:getStart()
    local reducedMaze = gameSet.maze:deadEndReduce()

    Game.printStep("Avvio", gameSet.life, gameSet.maze)

    local result = Game.DFSGame(reducedMaze, start.row, start.column, 0, gameSet.life)

    Game.printStep("Risultato finale", result.life, (gameSet.maze + result.maze))
    Inputoutput.writeFile(result.life, (gameSet.maze + result.maze), start.row, start.column)
end

startUp("mazes/grosso.txt")
