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

WARRIOR_DEF_TRINKET = "Insignia of the Horde";
WARRIOR_THRESH=.45;

function btp_warrior_initialize()
    btp_frame_debug("warrior INIT");

    SlashCmdList["WARRIORH"] = warrior_heal;
    SLASH_WARRIORH1 = "/warriorheal";
    SlashCmdList["WARRIORR"] = warrior_roach;
    SLASH_WARRIORR1 = "/warriorroach";
    SlashCmdList["WARRIORD"] = warrior_dps;
    SLASH_WARRIORD1 = "/warriordps";
end

function warrior_heal()
    if (current_cb ~= nil and current_cb()) then
        return true;
    end

    -- Trinkets();
    ProphetKeyBindings();

    for bag=0,4 do
      for slot=1,C_Container.GetContainerNumSlots(bag) do
        if (C_Container.GetContainerItemLink(bag,slot)) then
          if (string.find(C_Container.GetContainerItemLink(bag,slot), "Bandage")) then
              start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot);
              if (duration - (GetTime() - start) <= 0) then
                  hasBandage = true;
                  bandageBag = bag;
                  bandageSlot = slot;
              end
              break;
          end
        end
      end
    end

    --
    -- Bandage Debuff check
    --
    hasBandageDebuff, myBandageDebuff,
    numBandageDebuff = btp_check_debuff("Recently Bandaged", "player");

    if (SelfHeal(WARRIOR_THRESH, 0)) then
        --
        -- doing a self heal here (heathstones, potions, etc)
        --
        return true;
    elseif (hasBandage and not hasBandageDebuff and
            UnitHealth("player")/UnitHealthMax("player") < 1) then
            lastBandage = GetTime();
            FuckBlizzardTargetUnitContainer("player");
            FuckBlizUseContainerItem(bandageBag, bandageSlot);
            return true;
    end
end

function warrior_roach()
    if (current_cb ~= nil and current_cb()) then
        return true;
    end

    -- Trinkets();
    ProphetKeyBindings();

    -- Hamstring
    hasHamstring, myHamstring, numHamstring, expHamstring = btp_check_debuff(
        "Hamstring",
        "target"
    );

    playerHealthRatio =  UnitHealth("player")/UnitHealthMax("player");

    if (SelfHeal(WARRIOR_THRESH, 0)) then
        --
        -- doing a self heal here (heathstones, potions, etc)
        --
        return true;
    elseif (not hasHamstring and btp_cast_spell("Hamstring")) then
        return true;
    end
end

function warrior_dps()
    if (current_cb ~= nil and current_cb()) then
        return true;
    end

    -- Trinkets();
    ProphetKeyBindings();

    --
    -- buffs
    --

    -- Battle Shout
    hasShout, myShout, numShout, expShout = btp_check_buff(
        "Battle Shout",
        "player"
    );

    --
    -- debuffs
    --

    -- Rend
    hasRend, myRend, numRend, expRend = btp_check_debuff(
        "Rend",
        "target"
    );

    -- Thunder Clap
    hasClap, myClap, numClap, expClap = btp_check_debuff(
        "Thunder Clap",
        "target"
    );

    -- Hamstring
    hasHamstring, myHamstring, numHamstring, expHamstring = btp_check_debuff(
        "Hamstring",
        "target"
    );

    playerHealthRatio =  UnitHealth("player")/UnitHealthMax("player");
    targetHealthRatio =  UnitHealth("target")/UnitHealthMax("target");

    rage = UnitPower("player", T_RAGE);

    if ((btp_is_casting("target") or btp_is_channeling("target"))) then
        btp_frame_debug("CASTING");
    end

    --
    -- instant actions (as if you could macro them together)
    --
    if (UnitAffectingCombat("player") and rage < 50 and
        playerHealthRatio > .50 and btp_cast_spell_alt("Bloodrage")) then
    end

    if (SelfHeal(WARRIOR_THRESH, 0)) then
        --
        -- doing a self heal here (heathstones, potions, etc)
        --
        return true;
    elseif ((btp_is_casting("target") or btp_is_channeling("target")) and
            btp_check_dist("target", 3) and btp_cast_spell("Shield Bash")) then
        return true;
    elseif (targetHealthRatio < .50 and not hasHamstring and
            btp_check_dist("target", 3) and btp_cast_spell("Hamstring")) then
        return true;
    elseif (UnitAffectingCombat("player") and rage < 50 and
            playerHealthRatio > .50 and btp_cast_spell_alt("Bloodrage")) then
        return true;
    elseif (not myShout and btp_cast_spell("Battle Shout")) then
        return true;
    elseif (not myClap and btp_check_dist("target", 3) and
            btp_cast_spell("Thunder Clap")) then
        return true;
    elseif (not myRend and btp_check_dist("target", 3) and
            btp_cast_spell("Rend")) then
        return true;
    elseif (rage > 70 and btp_check_dist("target", 3) and
            btp_cast_spell("Heroic Strike")) then
        return true;
    elseif (not UnitAffectingCombat("player") and btp_cast_spell("Charge")) then
        return true;
    end

    return true;
end