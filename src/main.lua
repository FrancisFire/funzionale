local Inputoutput = require "inputoutput"
local Game = require "game"
local Manager = require "manager"

function startUp(fileName)
    local gameSet = Inputoutput.readFile(fileName)
    local start = Game.getStart(gameSet.maze)
    Game.printStep("Avvio", gameSet.life, gameSet.maze)

    local rootManagerTable = Manager.getNewManagerTable()
    local rootMoveFunction = Game.getMoveFunction(gameSet.maze, start.row, start.column, 0, gameSet.life)

    rootManagerTable = Manager.addFunction(rootManagerTable, rootMoveFunction)
    local result = Manager.executeMoves(rootManagerTable, 1)

    if (result ~= nil) then
        do
            local gameResult = {life = result.life, maze = result.maze}
            Game.printStep("Risultato finale", gameResult.life, gameResult.maze)
            Inputoutput.writeFile(gameResult.life, gameResult.maze, start.row, start.column)
        end
    else
        do
            Game.printStep("Soluzione non presente", gameSet.life, gameSet.maze)
            Inputoutput.writeFile(gameSet.life, gameSet.maze, start.row, start.column)
        end
    end
end

startUp("input.txt")
