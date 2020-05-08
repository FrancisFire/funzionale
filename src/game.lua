utils = require "utils"
inputoutput = require "inputoutput"

function move(maze, row, column, steps, life)
    local newSteps = steps + 1
    local result = applyCellEffect(maze, row, column, life)
    local newLife = result.life
    if (result.lose) then
        return {maze = maze, steps = newSteps, life = newLife, win = false}
    elseif (result.win) then
        return {maze = maze, steps = newSteps, life = newLife, win = true}
    else
        local tracedMaze = traceMaze(maze, row, column)
        local results = {}
        for k, newDir in pairs(utils.Directions) do
            local x, y = newDir(row, column)

            local subRes = move(tracedMaze, x, y, newSteps, newLife)
            if (subRes.win) then
                -- [[ print("Percorso vincente: " .. " Passi: " .. subRes.steps .. " Vita: " .. subRes.life)]]

                table.insert(results, subRes)
            end
        end
        local result = calcOptimalResult(results)
        if (result == nil) then
            return {maze = maze, steps = newSteps, life = newLife, win = false}
        else
            return result
        end
    end
end

function calcOptimalResult(resTable)
    local function func(tmpTable, minimum)
        if (#tmpTable == 0) then
            return minimum
        end
        local head = table.remove(tmpTable, 1)
        if (minimum == nil) then
            return func(tmpTable, head)
        else
            if ((head.steps < minimum.steps) or (head.steps == minimum.steps and head.life < minimum.life)) then
                return func(tmpTable, head)
            else
                return func(tmpTable, minimum)
            end
        end
    end
    return func(resTable, nil)
end

function traceMaze(maze, row, column)
    local cloneMaze = utils.cloneMaze(maze)
    cloneMaze[row][column] = "x"
    return cloneMaze
end

function applyCellEffect(maze, row, column, life)
    local cellValue = maze[row][column]
    local lifeFunctions = {
        ["0"] = function(life)
            return life
        end,
        ["1"] = function(life)
            return life + 1
        end,
        ["2"] = function(life)
            return life + 2
        end,
        ["3"] = function(life)
            return life + 3
        end,
        ["4"] = function(life)
            return life + 4
        end,
        ["5"] = function(life)
            return life - 1
        end,
        ["6"] = function(life)
            return life - 2
        end,
        ["7"] = function(life)
            return life - 3
        end,
        ["8"] = function(life)
            return life - 4
        end,
        ["9"] = function(life)
            return life * 2
        end,
        ["f"] = function(life)
            return life // 2
        end,
        ["u"] = function(life)
            return life
        end,
        ["i"] = function(life)
            return life
        end,
        ["m"] = function(life)
            return 0
        end,
        ["p"] = function(life)
            return 0
        end,
        ["x"] = function(life)
            return 0
        end
    }
    --[[ print(
        "Riga " ..
            row ..
                " Colonna " ..
                    column ..
                        " Vita " ..
                            life ..
                                " Cella " ..
                                    cellValue ..
                                        " Nuova vita " ..
                                            lifeFunctions[cellValue](life) ..
                                                " Vinto " ..
                                                    (cellValue == "u" and "true" or "false") ..
                                                        " Perso " ..
                                                            (lifeFunctions[cellValue](life) <= 0 and "true" or "false")
    )]]
    return {life = lifeFunctions[cellValue](life), lose = lifeFunctions[cellValue](life) <= 0, win = cellValue == "u"}
end

function startUp(fileName)
    local game = inputoutput.readFile(fileName)
    local start = utils.getStart(game.maze)
    print("Avvio")
    print("Vita di partenza " .. game.life)
    utils.printMaze(game.maze)
    local result = move(game.maze, start.row, start.column, 0, game.life)
    local gameResult = {life = result.life, maze = result.maze}
    print("Risultato finale")
    print("Vita finale " .. gameResult.life)
    utils.printMaze(gameResult.maze)
    inputoutput.writeFile(gameResult, start.row, start.column)
end

startUp("input.txt")
