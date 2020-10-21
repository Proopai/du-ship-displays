-- validate inputs
local slots = _G.agController.slots
local class = slots.antigrav.getElementClass()
assert(class == "AntiGravityGeneratorUnit", "Antigrav slot is of type: " .. class)
class = slots.screen.getElementClass()
assert(class == "ScreenUnit", "Screen slot is of type: " .. class)
class = slots.core.getElementClass()
assert(class == "CoreUnitDynamic", "Core slot is of type: " .. class)

slots.screen.activate()

local core = _G.agController.slots.core
local antigrav = _G.agController.slots.antigrav

function _G.agController:updateState()
    self.verticalVelocity = core.getWorldVelocity()[3]
    self.currentAltitude = core.getAltitude()
    self.agState = antigrav.getState() == 1
    local data = antigrav.getData()
    self.baseAltitude = antigrav.getBaseAltitude()
    self.agField = tonumber(string.match(data, "\"antiGravityField\":([%d.-]+)"))
    self.agPower = tonumber(string.match(data, "\"antiGPower\":([%d.-]+)"))

    -- signal draw of screen with updated state
    self.needRefresh = true
end

function _G.agController:setBaseAltitude(target)
    self.slots.antigrav.setBaseAltitude(target)

    self:updateState()
end

function _G.agController:setAgState(newState)
    local state
    if newState then
        self.slots.antigrav.activate()
    else
        self.slots.antigrav.deactivate()
    end

    self:updateState()
end

-- verify AG is powered enough to function
local startupState = _G.agController.slots.antigrav.getState()
_G.agController.slots.antigrav.activate()
_G.agController:updateState()
assert(_G.agController.agField > 0.5,
    "Anti-Gravity Generator not linked to sufficient pulsors, field: " .. _G.agController.agField)
if startupState == 0 then
    _G.agController.slots.antigrav.deactivate()
    _G.agController:updateState()
end

-- hide widgets
unit.hide()
if _G.agController.hideAntiGravityWidget then
    _G.agController.slots.antigrav.hide()
end

-- init screen
_G.agScreen:init(_G.agController)

-- schedule updating
unit.setTimer("update", 1 / _G.UPDATE_FREQUENCY)
