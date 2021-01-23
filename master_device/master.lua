require('link_elements')
require('time_util')

local onColor = "128 0 0" --export: The color, in RGB, used when the light is on, defaults to 128 0 0. Reset clock to apply.
local offColor = "128 128 0" --export: The color, in RGB, used when the light is off. Reset clock to apply.
local secondaryFillColor = "0 64 0" --export: the color, in RGB, used as the secondary color when in filling display mode.
local displayMode = 1 --export: Display mode, 0 for single light, 1 for fill. Reset clock to apply.
local shutdownDistance = 100 --export: The distance at which to shutdown the clock to prevent hard-off if the player moves to far away. Can't be much larger than 100m as elements seem to load out at that point.

script = {}


local SETUP_SWITCH = 1
local SLAVE_SWITCH = 2
local HOLD_SWITCH = 3

function script.onStart()
    unit.hide()
    linkElements()

    if linkedSwitch[SETUP_SWITCH].getState() == 1 then
        system.print("Setting base time to current time.")
        linkedDatabank[1].setIntValue("base", math.ceil(TimeUtil.getClientTime()))
        linkedSwitch[SETUP_SWITCH].deactivate()
        linkedIndustry[1].hardStop(1)
        linkedIndustry[1].startAndMaintain(1)

        linkedDatabank[1].setStringValue("offcolor", offColor)
        linkedDatabank[1].setStringValue("oncolor", onColor)
        linkedDatabank[1].setStringValue("secondaryfillcolor", secondaryFillColor)
        linkedDatabank[1].setIntValue("displaymode", displayMode)
    end

    -- Turn on hold circuit
    linkedSwitch[HOLD_SWITCH].activate()

    -- Turn on slave devices
    linkedSwitch[SLAVE_SWITCH].activate()

    unit.setTimer("second", 1)
end

function isPlayerWithinRange()
    local dist = vec3(unit.getMasterPlayerRelativePosition()):len()
    return dist < shutdownDistance
end

function script.onStop()
    -- Turn off slave devices
    linkedSwitch[SLAVE_SWITCH].deactivate()
    -- Turn off hold circuit
    linkedSwitch[HOLD_SWITCH].deactivate()
    -- Do not turn off the industy unit.
end


function script.onTick(event)
    if isPlayerWithinRange() then
        if event == "second" then
            local uptime = linkedIndustry[1].getUptime()
            if uptime ~= nil then
                local elapsed = math.floor(uptime)
                linkedDatabank[1].setIntValue("elapsed", elapsed)
            else
                -- We end up here when moving to far from the core/industy unit.
                unit.exit()
            end
        end
    else
        -- Player has moved away, shutdown to prevent hard-stop later which leaves the clock in a frozen state.
        unit.exit()
    end
end


script.onStart()