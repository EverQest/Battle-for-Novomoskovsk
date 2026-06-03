--[[
    modifier_world_peace
    ~~~~~~~~~~~~~~~~~~~~~
    Applied to heroes standing inside the World Peace center zone.
    The BKB avatar glow signals that they cannot be damaged here.
    Applied and refreshed every second by EventWorldPeace:Think().
]]

modifier_world_peace = class({})

function modifier_world_peace:IsHidden()   return false end
function modifier_world_peace:IsDebuff()   return false end
function modifier_world_peace:IsPurgable() return false end

