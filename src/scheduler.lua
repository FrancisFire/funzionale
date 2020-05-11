local schedulerExport = {}
local utils = require "utils"
local game = require "game"

schedulerExport.SchedulerObject = {
   new = function()
    return setmetatable({}, schedulerExport.SchedulerObject)
   end,
   addFunction = function(self, functionToAdd)
    table.insert( self, functionToAdd )
   end,
   compareCellValues = function(self)
    local indexToRemove = {}
    local winningResults = {}
    for k, nodeFunction in pairs(self) do
        local result = coroutine.resume(nodeFunction)
        if(result.lose) then table.insert( indexToRemove, k )
    end
    if(result.win) then table.insert(winningResults, result)
    end
end
    if(#winningResults == 0) then 
        for j, toRemove in pairs(indexToRemove) do
            table.remove( self, toRemove) --TODO replace table.remove
        end
        return nil 
    end
    
    return game.calcOptimalResult(winningResults)
end,
    scheduleNextMoves = function(self, nextLevelScheduler)
        for k, nodeFunction in pairs(self) do
            coroutine.resume(nodeFunction ,nextLevelScheduler)
        end
    end,

    executeMoves = function (self)
        local res = self:compareCellValues() --cicla i valori delle caselle dello scheduler e fa i confronti
        if(res) then return res end
    
        if(#self == 0) then return nil end
    
        local nextLevelScheduler = schedulerExport.SchedulerObject.new()
        self:scheduleNextMoves(nextLevelScheduler) --popolo lo scheduler del livello successivo
      
        return nextLevelScheduler:executeMoves(nextLevelScheduler)
    end

}

function schedulerExport.execute(maze, row, column, life)
    local rootScheduler = schedulerExport.SchedulerObject.new()
    rootScheduler:addFunction(coroutine.create(game.move, ))
    return rootScheduler:executeMoves()
end

function coroutineBuilder(params) return coroutine.wrap(function() print(params) end) end

return schedulerExport;