require('link_elements')
require('list')
require('time_util')

--[[

Link ligts as follows:
Unit 1: Hours 0-5
Unit 2: Hours 6-11
Unit 3: Minute 0-8
Unit 4: Minute 9-17
Unit 5: Minute 18-26
Unit 6: Minute 27-35
Unit 7: Minute 36-44
Unit 8: Minute 45-53
Unit 9: Minute 54-59

Link lights, in ascending order, starting at minute 0 (i.e. top of the hour), before the databank, which goes into the last slot.
Do not rename slots.

]]--

local unitNumber = 1 --export: Set to the unit number correpsonding to the lights the device is connected to.

local timeMode = 0 -- Operational timeMode. 0 for hours, 1 for minutes, 2 for seconds
local lowerSpan = 0 -- The lower hour/minute/second to work with, inclusive, 12h format, start at 0.
local upperSpan = 0 -- The upper hour/minute/second to work with, inclusive, 12h format, start at 0. Must be within 9 from lowerSpan (only nine slots to work with)

local baseTime = 0 -- The time used as the base. Read from the databank.
local displayMode = 1 -- Display mode, 0 for single light, 1 for fill, read from the databank

local HOURS = 0
local MINUTES = 1
local SECONDS = 2
local DISPLAY_MODE_SINGLE = 0
local DISPLAY_MODE_FILL = 1

local lightQueue = List.new()

local offR, offG, offB
local onR, onG, onB
local secOffR, secOffG, secOffB

script = {}

function setupDevice()
    if unitNumber == 1 then
        timeMode = HOURS
        lowerSpan = 0
        upperSpan = 5
    elseif unitNumber == 2 then
        timeMode = HOURS
        lowerSpan = 6
        upperSpan = 11
    elseif unitNumber == 3 then
        timeMode = MINUTES
        lowerSpan = 0
        upperSpan = 8
    elseif unitNumber == 4 then
        timeMode = MINUTES
        lowerSpan = 9
        upperSpan = 17
    elseif unitNumber == 5 then
        timeMode = MINUTES
        lowerSpan = 18
        upperSpan = 26
    elseif unitNumber == 6 then
        timeMode = MINUTES
        lowerSpan = 27
        upperSpan = 35
    elseif unitNumber == 7 then
        timeMode = MINUTES
        lowerSpan = 36
        upperSpan = 44
    elseif unitNumber == 8 then
        timeMode = MINUTES
        lowerSpan = 45
        upperSpan = 53
    elseif unitNumber == 9 then
        timeMode = MINUTES
        lowerSpan = 54
        upperSpan = 59
    else
        system.print("Invalid unitNumber")
        unit.exit()
    end

    displayMode = linkedDatabank[1].getIntValue("displaymode")
end

function parseColors()
    
    local pattern = "(%d+)%s+(%d+)%s+(%d+)"
    
    local offColor = linkedDatabank[1].getStringValue("offcolor")
    local r, g, b = string.match(offColor, pattern)
    offR = tonumber(r)
    offG = tonumber(g)
    offB = tonumber(b)
    
    local onColor = linkedDatabank[1].getStringValue("oncolor")
    local r, g, b = string.match(onColor, pattern)
    onR = tonumber(r)
    onG = tonumber(g)
    onB = tonumber(b)
    
    local secondaryFillColor = linkedDatabank[1].getStringValue("secondaryfillcolor")
    local r, g, b = string.match(secondaryFillColor, pattern)
    secOffR = tonumber(r)
    secOffG = tonumber(g)
    secOffB = tonumber(b)
end

function script.onStart()
    unit.hide()
    linkElements()
    setupDevice()
    parseColors()
    turnOffAllLights()
    baseTime = linkedDatabank[1].getIntValue("base")
    unit.setTimer("second", 1)
end

function script.onStop()
    turnOffAllLights()
end

function script.onTick(event)
    if event == "second" then
        local now = TimeUtil.getTime(linkedDatabank[1].getIntValue("elapsed") + baseTime)
        -- Put a command to update the time at the end of the frame for synched updates.        
        List.pushright(lightQueue, now)
    end
end

function script.onUpdate()
    if not List.isempty(lightQueue) then
        local now = List.popleft(lightQueue)

        local lightToTurnOn
        local currentTimePoint

        if timeMode == HOURS then
            if now.hour >= 12 then -- Must adjust to 12 hour, analog clock
                now.hour = now.hour - 12
            end

            lightToTurnOn = now.hour - lowerSpan
            currentTimePoint = now.hour
        elseif timeMode == MINUTES then
            lightToTurnOn = now.minute - lowerSpan
            currentTimePoint = now.minute
        elseif timeMode == SECONDS then
            lightToTurnOn = now.second - lowerSpan
            currentTimePoint = now.second
        end

        lightToTurnOn = lightToTurnOn + 1 -- Since slots are 1-indexed

        if displayMode == DISPLAY_MODE_SINGLE then
            display_single(currentTimePoint, lightToTurnOn)
        elseif displayMode == DISPLAY_MODE_FILL then
            display_fill(currentTimePoint, lightToTurnOn)
        end
    end
end

function withinRange(currentTimePoint)
    return currentTimePoint >= lowerSpan and currentTimePoint <= upperSpan
end

function hasReachedSection(currentTimePoint)
    return currentTimePoint >= lowerSpan
end

function display_single(currentTimePoint, lightToTurnOn)
    for k, v in ipairs(linkedLight) do
        if k == lightToTurnOn and withinRange(currentTimePoint) then
            turnOnLight(v, onR, onG, onB)
        else
            turnOffLight(v)
        end                    
    end
end

function display_fill(currentTimePoint, lightToTurnOn)
    if hasReachedSection(currentTimePoint) then
        for k, v in ipairs(linkedLight) do        
            if k == lightToTurnOn then
                turnOnLight(v, onR, onG, onB)
            elseif k < lightToTurnOn then                
                turnOnLight(v, secOffR, secOffG, secOffB)
            else
                turnOffLight(v)
            end        
        end
    else
        turnOffAllLights()
    end
end

function validate()
    if timeMode ~= HOURS and timeMode ~= MINUTES and timeMode ~= SECONDS then
        system.print("Invalid mode")
        unit.exit()
    end
end

function turnOffLight(light)
    light.setRGBColor(offR, offG, offB)
    light.deactivate()
end

function turnOnLight(light, r, g, b)
    light.setRGBColor(r, g, b)
    light.activate()
end

function turnOffAllLights()
    for k, v in ipairs(linkedLight) do
        turnOffLight(v)
    end
end

validate()

script.onStart()