local Inputoutput = require "inputoutput"
local Game = require "game"
local MazeReducer = require "mazereduction"

function startUp(fileName)
    local gameSet = Inputoutput.readFile(fileName)
    local start = Game.getStart(gameSet.maze)
    local reducedMaze = MazeReducer.deadEndReduce(gameSet.maze)
    Game.printStep("Avvio", gameSet.life, gameSet.maze)

    local result = Game.DFSGame(reducedMaze, start.row, start.column, 0, gameSet.life)

    Game.printStep("Risultato finale", result.life, Game.getSolutionMaze(gameSet.maze, result.maze))
    Inputoutput.writeFile(result.life, Game.getSolutionMaze(gameSet.maze, result.maze), start.row, start.column)
end

startUp("mazes/grosso.txt")
