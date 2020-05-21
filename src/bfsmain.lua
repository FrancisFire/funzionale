local Inputoutput = require "inputoutput"
local Game = require "game"
local Manager = require "manager"
local MazeReducer = require "mazereduction"
function startUp(fileName)
    local gameSet = Inputoutput.readFile(fileName)
    local start = Game.getStart(gameSet.maze)
    local reducedMaze = MazeReducer.deadEndReduce(gameSet.maze)
    Game.printStep("Avvio", gameSet.life, reducedMaze)

    local rootManagerTable = Manager.getNewManagerTable()
    local rootMoveFunction = Game.BFSGame(reducedMaze, start.row, start.column, 0, gameSet.life)

    rootManagerTable = Manager.addFunction(rootManagerTable, rootMoveFunction)
    local result = Manager.executeMoves(rootManagerTable, 1)

    if (result ~= nil) then
        do
            local gameResult = {life = result.life, maze = result.maze}
            Game.printStep("Risultato finale", gameResult.life, Game.getSolutionMaze(gameSet.maze, gameResult.maze))

            Inputoutput.writeFile(
                gameResult.life,
                Game.getSolutionMaze(gameSet.maze, gameResult.maze),
                start.row,
                start.column
            )
        end
    else
        do
            Game.printStep("Soluzione non presente", gameSet.life, gameSet.maze)
            Inputoutput.writeFile(gameSet.life, gameSet.maze, start.row, start.column)
        end
    end
end

startUp("mazes/progetto.txt")
