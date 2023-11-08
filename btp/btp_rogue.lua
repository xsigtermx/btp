-- 
-- This file is part of BTP.
-- 
-- BTP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- BTP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with BTP.  If not, see <http://www.gnu.org/licenses/>.
-- 

ROGUE_DEF_TRINKET = "Insignia of the Horde";
ROGUE_THRESH=.45;

function btp_rogue_initialize()
    btp_frame_debug("Rogue INIT");

    SlashCmdList["ROGUEH"] = rogue_heal;
    SLASH_ROGUEH1 = "/rh";
    SlashCmdList["ROGUED"] = rogue_dps;
    SLASH_ROGUED1 = "/rd";
end

function rogue_heal()
    if (current_cb ~= nil and current_cb()) then
        return true;
    end

    -- Trinkets();
    ProphetKeyBindings();

    if (SelfHeal(ROGUE_THRESH, 0)) then
        --
        -- doing a self heal here (heathstones, potions, etc)
        --
        return true;
    end
end

function rogue_dps()
    if (current_cb ~= nil and current_cb()) then
        return true;
    end

    -- Trinkets();
    ProphetKeyBindings();

    --
    -- Slice and Dice
    --
    hasSlice, mySlice, numSlice, expSlice = btp_check_buff(
        "Slice and Dice",
        "player"
    );

    comboPoints = GetComboPoints("player", "target");
    playerHealthRatio =  UnitHealth("player")/UnitHealthMax("player");
    targetHealthRatio =  UnitHealth("target")/UnitHealthMax("target");

    if (SelfHeal(ROGUE_THRESH, 0)) then
        --
        -- doing a self heal here (heathstones, potions, etc)
        --
        return true;
    elseif (playerHealthRatio <= .75 and btp_cast_spell("Evasion")) then
        return true;
    elseif (playerHealthRatio > .80 and btp_cast_spell("Blood Fury")) then
        return true;
    elseif (playerHealthRatio < .70 and btp_cast_spell("Berserking")) then
        return true;
    elseif (IsStealthed() and btp_cast_spell("Backstab")) then
        return true;
    elseif (comboPoints > 4 and btp_cast_spell("Eviscerate")) then
        return true;
    elseif (comboPoints == 5 and targetHealthRatio < .30 and
            btp_cast_spell("Eviscerate")) then
        return true;
    elseif (comboPoints == 4 and targetHealthRatio < .25 and
            btp_cast_spell("Eviscerate")) then
        return true;
    elseif (comboPoints == 3 and targetHealthRatio < .20 and
            btp_cast_spell("Eviscerate")) then
        return true;
    elseif (comboPoints == 2 and targetHealthRatio < .15 and
            btp_cast_spell("Eviscerate")) then
        return true;
    elseif (comboPoints == 1 and targetHealthRatio < .10 and
            btp_cast_spell("Eviscerate")) then
        return true;
    elseif (comboPoints > 0 and not hasSlice and
            btp_cast_spell("Slice and Dice")) then
        return true;
    elseif (comboPoints < 5 and UnitPower("player", T_ENERGY) > 50 and
            btp_cast_spell("Sinister Strike")) then
        return true;
    end

    return true;
end
