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

function btp_rogue_initialize()
    btp_frame_debug("Rogue INIT");

    SlashCmdList["ROGUEH"] = rogue_heal;
    SLASH_DRUIDH1 = "/rh";
    SlashCmdList["ROGUED"] = rogue_dps;
    SLASH_DRUIDD1 = "/rd";
end

function rogue_heal()
    btp_frame_debug("Rogue Heal");
end

function rogue_dps()
    btp_frame_debug("Rogue Heal");
end
