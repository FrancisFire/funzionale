local Inputoutput = require "inputoutput"
local Game = require "game"
local Manager = require "managerobject"

function startUp(fileName)
    local gameSet = Inputoutput.readFile(fileName)
    local start = gameSet.maze:getStart()
    local reducedMaze = gameSet.maze:deadEndReduce()
    Game.printStep("Avvio", gameSet.life, reducedMaze)

    local rootManager = Manager.new()
    local rootMoveFunction = Game.BFSGame(reducedMaze, start.row, start.column, 0, gameSet.life)

    rootManager = rootManager:addFunction(rootMoveFunction)
    local result = rootManager:executeMoves(1)

    if (result ~= nil) then
        do
            local gameResult = {life = result.life, maze = result.maze}
            Game.printStep("Risultato finale", gameResult.life, (gameSet.maze + gameResult.maze))

            Inputoutput.writeFile(gameResult.life, (gameSet.maze + gameResult.maze), start.row, start.column)
        end
    else
        do
            Game.printStep("Soluzione non presente", gameSet.life, gameSet.maze)
            Inputoutput.writeFile(gameSet.life, gameSet.maze, start.row, start.column)
        end
    end
end

startUp("mazes/input.txt")
