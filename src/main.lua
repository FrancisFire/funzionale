local Inputoutput = require "inputoutput"
local Game = require "game"
local Manager = require "manager"

function startUp(fileName)
    local gameSet = Inputoutput.readFile(fileName)
    local start = Game.getStart(gameSet.maze)
    print("Avvio")
    print("Vita di partenza " .. gameSet.life)
    Game.printMaze(gameSet.maze)

    local gameManagerTable = Manager.getNewManagerTable()
    gameManagerTable =
        Manager.addFunction(gameManagerTable, Game.move(gameSet.maze, start.row, start.column, 0, gameSet.life))

    local result = Manager.executeMoves(gameManagerTable)
    if (result) then
        local gameResult = {life = result.life, maze = result.maze}
        print("Risultato finale")
        print("Vita finale " .. gameResult.life)
        Game.printMaze(gameResult.maze)
        Inputoutput.writeFile(gameResult, start.row, start.column)
    else
        print("Soluzione non presente")
        print("Vita finale " .. gameSet.life)
        Game.printMaze(gameSet.maze)
        Inputoutput.writeFile(gameSet, start.row, start.column)
    end
end

startUp("input.txt")
