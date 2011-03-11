-- btp_priest.lua
--
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

PRIEST_DEF_TRINKET = "Insignia of the Horde";
-- Moved a lot of stuff to btp_priest_old.lua
function btp_priest_initialize()
    btp_frame_debug("Priest INIT");

    SlashCmdList["PRIESTA"] = PriestAssist;
    SLASH_PRIESTA1 = "/pa";
    SlashCmdList["PRIESTB"] = PriestBuff;
    SLASH_PRIESTB1 = "/pb";
    SlashCmdList["PRIESTH"] = PriestHeal;
    SLASH_PRIESTH1 = "/ph";
    SlashCmdList["PRIESTP"] = PriestPrimary;
    SLASH_PRIESTP1 = "/pp";
    SlashCmdList["PRIESTD"] = PriestDest;
    SLASH_PRIESTD1 = "/pd";
    SlashCmdList["PRIESTJ"] = PriestJeff;
    SLASH_PRIESTJ1 = "/pj";
    SlashCmdList["PRIESTY"] = PriestPrayer;
    SLASH_PRIESTY1 = "/py";
    SlashCmdList["PRIESTV"] = PriestVulner;
    SLASH_PRIESTV1 = "/pv";
    SlashCmdList["PRIESTS"] = PriestShield;
    SLASH_PRIESTS1 = "/ps";

    SlashCmdList["NEWPRIESTHEAL"] = btp_priest_heal;
    SLASH_NEWPRIESTHEAL1 = "/newpriestheal";

    SlashCmdList["PRIESTDPS"] = btp_priest_dps_new;
    SLASH_PRIESTDPS1 = "/pdps";

    SlashCmdList["PRIESTDPSPVP"] = btp_priest_dps_pvp;
    SLASH_PRIESTDPSPVP1 = "/pdps_pvp";

    SlashCmdList["PRIESTDPSPVE"] = btp_priest_dps_pve;
    SLASH_PRIESTDPSPVE1 = "/pdps_pve";

    SlashCmdList["DPSMODE"] = btp_dps_mode_toggle;
    SLASH_DPSMODE1 = "/dps";


end

function btp_dps_mode_toggle()
    if(DPS_MODE_ON == nil or DPS_MODE_ON == false) then
        DPS_MODE_ON = true;
        btp_frame_debug("DPS_MODE = ON");
    else
        DPS_MODE_ON = false;
        btp_frame_debug("DPS_MODE = OFF");
    end
end


function PriestBuff()
    noFort = true;
    noInnerFire = true;
    noShadowProtection = true;
    noDivineSpirit = true;
    noTouchOfWeakness = true;
    nextPlayer = "player";
    hasFortitude = false;
    hasShadowProtect = false;
    hasInnerFire = false;
    hasDivineSpirit = false;
    hasTouchOfWeakness = false;
    hasPrayerFort = false;
    hasPrayerSpirit = false;
    hasPrayerShadowProtect = false;
    hasCandle = false;
    goodToBuff = true;

    Trinkets();
    ProphetKeyBindings();

    local i = 1
    while true do
       local spellName, spellRank = GetSpellBookItemName(i, BOOKTYPE_SPELL);
       if not spellName then
          do break end
       end

        if(not btp_priest_is_innerwill() and not btp_priest_is_innerfire()) then
            if(btp_cast_spell("Inner Fire")) then 
           	    hasInnerFire = true;
		    return true; 
	    end
       end

       if (strfind(spellName, "Shadow Protection")) then
           hasShadowProtect = true;
       end

       if (strfind(spellName, "Power Word: Fortitude")) then
           hasFortitude = true;
       end

       if (strfind(spellName, "Divine Spirit")) then
           hasDivineSpirit = true;
       end

       if (not UnitAffectingCombat("player") and
           strfind(spellName, "Touch of Weakness")) then
           hasTouchOfWeakness = true;
       end

       if (strfind(spellName, "Prayer of Fortitude")) then
           start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL);
           if (duration - (GetTime() - start) <= 0) then
              hasPrayerFort = true;
           end
       end

       if (strfind(spellName, "Prayer of Spirit")) then
           start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL);
           if (duration - (GetTime() - start) <= 0) then
              hasPrayerSpirit = true;
           end
       end

       if (strfind(spellName, "Prayer of Shadow Protection")) then
           start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL);
           if (duration - (GetTime() - start) <= 0) then
              hasPrayerShadowProtect = true;
           end
       end

       i = i + 1
    end

    for bag=0,4 do
      for slot=1,GetContainerNumSlots(bag) do
        if (GetContainerItemLink(bag,slot)) then
          if (string.find(GetContainerItemLink(bag,slot), "Candle")) then
              hasCandle = true;
              break;
          end
        end
      end
    end

    if (GetNumPartyMembers() ~= 0) then
        for i = 1, GetNumPartyMembers() do
            nextPlayer = "party" .. i;
            if (UnitHealth(nextPlayer) < 4 or
                not btp_check_dist(nextPlayer,1)) then
                goodToBuff = false;
                break;
            end                
        end
    end
      
    if (GetNumRaidMembers() ~= 0) then
        for i = 1, GetNumRaidMembers() do
            nextPlayer = "raid" .. i;
            if (UnitHealth(nextPlayer) < 4 or
                not btp_check_dist(nextPlayer,1)) then
                -- btp_frame_debug("false ".. UnitHealth(nextPlayer) .. " " ..
                --                 nextPlayer .. " " .. GetNumRaidMembers());
                goodToBuff = false;
                break;
            end                
        end
    end
                
    if (not GetNumPartyMembers() and not GetNumRaidMembers()) then
        goodToBuff = false;
    end

    for i = 0, 256 do
        buffName, buffRank, buffTexture,
        buffApplications, buffDuration, buffTime = UnitBuff("player", i);

        if (buffTexture and strfind(buffTexture, "Fortitude")) then
            noFort = false;
        end

        if (buffTexture and (strfind(buffTexture, "AntiShadow") or
            strfind(buffTexture, "ShadowProtection"))) then
            noShadowProtection = false;
        end

        if (buffTexture and strfind(buffTexture, "InnerFire")) then
            noInnerFire = false;
        end

        if (buffTexture and strfind(buffTexture, "Spirit")) then
            noDivineSpirit = false;
        end

        if (buffTexture and strfind(buffTexture, "DeadofNight")) then
            noTouchOfWeakness = false;
        end
    end

    if (hasCandle and hasPrayerFort and noFort and goodToBuff and
        not pvpBot) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Prayer of Fortitude");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (hasFortitude and noFort) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Power Word: Fortitude");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (hasCandle and hasPrayerSpirit and noDivineSpirit and goodToBuff and
        not pvpBot) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Prayer of Spirit");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (hasDivineSpirit and noDivineSpirit) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Divine Spirit");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (hasCandle and hasPrayerShadowProtect and noShadowProtection and
        goodToBuff and not pvpBot) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Prayer of Shadow Protection");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (hasShadowProtect and noShadowProtection) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Shadow Protection");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (hasInnerFire and noInnerFire) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Inner Fire");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (hasTouchOfWeakness and noTouchOfWeakness) then
        FuckBlizzardTargetUnit("player");
        FuckBlizzardByName("Touch of Weakness");
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    for i = 1, GetNumPartyMembers() do
        nextPlayer = "party" .. i;
        noFort = true;
        noInnerFire = true;
        noShadowProtection = true;
        noDivineSpirit = true;

        if (UnitHealth(nextPlayer) >= 5 and
            btp_check_dist(nextPlayer,1)) then
            for i = 0, 256 do
                buffName, buffRank, buffTexture,
                buffApplications, buffDuration,
                buffTime = UnitBuff(nextPlayer, i);

                if (buffTexture and strfind(buffTexture, "Fortitude")) then
                    noFort = false;
                end

                if (buffTexture and (strfind(buffTexture, "AntiShadow") or
                    strfind(buffTexture, "ShadowProtection"))) then
                    noShadowProtection = false;
                end

                if (buffTexture and strfind(buffTexture, "Spirit")) then
                    noDivineSpirit = false;
                end
            end

            if (hasCandle and hasPrayerFort and noFort and goodToBuff and
                not pvpBot) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Prayer of Fortitude");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasFortitude and noFort) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Power Word: Fortitude");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasCandle and hasPrayerSpirit and noDivineSpirit and
                goodToBuff and not pvpBot) then
                FuckBlizzardTargetUnit("player");
                FuckBlizzardByName("Prayer of Spirit");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasDivineSpirit and noDivineSpirit) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Divine Spirit");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasCandle and hasPrayerShadowProtect and noShadowProtection and
                goodToBuff and not pvpBot) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Prayer of Shadow Protection");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasShadowProtect and noShadowProtection) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Shadow Protection");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end
        end
    end

    for i = 1, GetNumRaidMembers() do
        nextPlayer = "raid" .. i;
        noFort = true;
        noInnerFire = true;
        noShadowProtection = true;
        noDivineSpirit = true;

        if (UnitHealth(nextPlayer) >= 5 and
            btp_check_dist(nextPlayer,1)) then

            for i = 0, 256 do
                buffName, buffRank, buffTexture,
                buffApplications, buffDuration,
                buffTime = UnitBuff(nextPlayer, i);

                if (buffTexture and strfind(buffTexture, "Fortitude")) then
                    noFort = false;
                end

                if (buffTexture and (strfind(buffTexture, "AntiShadow") or
                    strfind(buffTexture, "ShadowProtection"))) then
                    noShadowProtection = false;
                end

                if (buffTexture and strfind(buffTexture, "Spirit")) then
                    noDivineSpirit = false;
                end
            end

            if (hasCandle and hasPrayerFort and noFort and goodToBuff and
                not pvpBot) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Prayer of Fortitude");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasFortitude and noFort) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Power Word: Fortitude");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasCandle and hasPrayerSpirit and goodToBuff and
                noDivineSpirit and
                goodToBuff and not pvpBot) then
                FuckBlizzardTargetUnit("player");
                FuckBlizzardByName("Prayer of Spirit");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasDivineSpirit and noDivineSpirit) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Divine Spirit");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasCandle and hasPrayerShadowProtect and goodToBuff and
                noShadowProtection) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Prayer of Shadow Protection");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (hasShadowProtect and noShadowProtection) then
                FuckBlizzardTargetUnit(nextPlayer);
                FuckBlizzardByName("Shadow Protection");
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end
        end
    end
end

-- JML START
-- 
--
--
--
--

BTP_PRIEST_THRESH_CRIT=.35
BTP_PRIEST_THRESH_LARGE=.65
BTP_PRIEST_THRESH_MEDIUM=.89
BTP_PRIEST_THRESH_SMALL=.96
BTP_PRIEST_THRESH_MANA=.15

function btp_priest_dps_pve(unit)
    if(not unit or unit == nil or unit == "") then  unit = "target"; end
    if (btp_priest_dps_new(unit)) then return true; end
    if (_btp_priest_dps_pve(unit)) then return true; end
    return false;
end

function btp_priest_dps_pvp(unit)
    if(not unit or unit == nil or unit == "") then  unit = "target"; end
    if (btp_priest_dps_new(unit)) then return true; end
    if (_btp_priest_dps_pvp(unit)) then return true; end
    return false;
end

function btp_priest_dps_new(unit)
    ProphetKeyBindings();

    if(not unit or unit == nil or unit == "") then  unit = "target"; end

    -- check our health
    local in_combat = UnitAffectingCombat("player");
    local cur_health = UnitHealth("player");
    local cur_health_max = UnitHealthMax("player");
    local cur_class = UnitClass("player");
    local my_health = (cur_health/cur_health_max)*100;

    local unit_health = (UnitHealth(unit)/UnitHealthMax(unit))*100;

    -- free action if need be
    if (btp_free_action()) then
        return true;
    end

    -- remove any curse from ourselves
    if ((((GetTime() - lastDecurse) >= 8) or blockOnDecurse) and
        BTP_Decursive()) then                                   
         lastDecurse = GetTime();
         return true;            
     end

    -- check if our target is casting a spell
    local spell_cast, _, _, _, _, endTime = UnitCastingInfo("target")
    if(spell_cast ~= nil) then
        if(btp_cast_spell_on_target("Silence", unit)) then return true; end
        if(btp_cast_spell_on_target("Psychic Horror", unit)) then return true; end
    end
    
    -- remove any buffs we dont want our target to have
    if (btp_priest_dispell_buffs(unit)) then return true; end

    -- if we have a fast mindblast use it AKA 3 mindspikes making Mind Blast instant
    if (btp_priest_is_my_mindspike(unit)) then
        if(btp_cast_spell_on_target("Mind Blast", unit)) then return true end;
    end

    -- if our target is low on health then cast shadow word death
    if (unit_health < 25 and my_health > 2) then
        if(btp_cast_spell_on_target("Shadow Word: Death", unit)) then return true; end
        if (not btp_priest_is_my_dp(unit)) then
    	    if(btp_cast_spell_on_target("Devouring Plague", unit)) then return true end
        end
        -- if they are close to death try and finish the job
        if (unit_health < 8) then
    	    if(btp_cast_spell_on_target("Devouring Plague", unit)) then return true end
        end
    end
    
    -- go into shadowform if not in it
    if(not btp_priest_is_shadowform()) then
        if(btp_cast_spell("Shadowform")) then return true; end
    end
    
    -- use pain suppression first
    if(my_health < 65) then
        if(btp_cast_spell("Pain Suppression")) then return true; end
    end

    -- keep our buffs up if not in combat
    if(not in_combat) then
        if(not btp_priest_is_fortitude("player")) then
            if(btp_cast_spell_on_target("Power Word: Fortitude", "player")) then return true; end
        end

        if(not btp_priest_is_divinespirit("player")) then
            if(btp_cast_spell("Divine Spirit")) then return true; end
        end

        if(not btp_priest_is_innerwill() and not btp_priest_is_innerfire()) then
            if(btp_cast_spell("Inner Fire")) then return true; end
        end

        if(not btp_priest_is_shadowprotection()) then
            if(btp_cast_spell("Shadow Protection")) then return true; end
        end

        if(not btp_priest_is_touchofweakness()) then
            if(btp_cast_spell("Touch of Weakness")) then return true; end
        end

        if(not btp_priest_is_my_vampiricembrace()) then
            if(btp_cast_spell_on_target("Vampiric Embrace", unit)) then 
                return true 
            end;
        end

        if(not btp_priest_is_innerfire() and not btp_priest_is_innerwill()) then
            if(btp_cast_spell_on_target("Inner Will", unit)) then 
                return true 
            end;
        end
    end
    
    -- Always shield ourself
    if (not btp_priest_is_pws())  then
        if(btp_cast_spell("Power Word: Shield")) then return true; end
    end
	btp_frame_debug("hummm");


    -- check if our health is low if so heal ourself
    if(my_health < 90) then
        if(btp_priest_is_sol()) then 
            if(btp_cast_spell("Flash Heal")) then return true; end;
        end
    end

    -- critical heals require instant relief
    if(my_health < 15 and not btp_priest_is_shadowform()) then
        if(btp_cast_spell("Desperate Prayer")) then return true; end
        if(btp_cast_spell("Prayer of Mending")) then return true; end
        if(btp_cast_spell("Circle of Healing")) then return true; end
        if(btp_cast_spell("Flash Heal")) then return true; end
    end

    if (my_health < 5) then
        if(btp_cast_spell("Psychic Screamr")) then return true; end
        if(btp_cast_spell_on_target("Dispersion", "player")) then return true; end
        if(not btp_priest_is_shadowform() and btp_cast_spell("Flash Heal")) then return true; end
    end

    -- put up renew if we get low on health
    if(my_health < 90) then
        if(not btp_priest_is_shadowform() and not btp_priest_is_renew()) then
            if(btp_cast_spell("Renew")) then return true; end
        end
    end

    if(my_health < 60) then
        if(not btp_priest_is_shadowform()) then
            if(btp_cast_spell("Flash Heal")) then return true; end
        end
    end

    -- check if we should cast shadowFiend bring it out for pvp right away
    if(in_combat and 
      ((UnitIsPlayer(unit) and UnitMana("player")/UnitManaMax("player") < .92) or
       (UnitMana("player")/UnitManaMax("player") < .30))) then
        if(btp_cast_spell_on_target("Shadowfiend", unit)) then return true; end
    end

    -- always keep fearward up since it cost next to no mana
    if(not btp_priest_is_fearward()) then
        if(btp_cast_spell_on_target("Fear Ward", unit)) then return true; end
    end

    if(btp_cast_spell_on_target("Power Infusion", unit)) then return true end;

    return false;
end

function _btp_priest_dps_pvp(unit)
    -- if we are moving then put up some dot to trip orbs
    if (btp_is_moving()) then
        -- keep up dp
        if (not btp_priest_is_my_dp()) then
    	    if(btp_cast_spell_on_target("Devouring Plague", unit)) then return true end
        end

        -- check if our target does not yet have SWP on 
        if (not btp_priest_is_my_swp(unit)) then
            if(btp_cast_spell_on_target("Shadow Word: Pain", unit)) then return true end;
        end

    end

    if(not btp_priest_is_shadowform()) then
        if(btp_cast_spell_on_target("Penance", unit)) then return true end;
        if(btp_cast_spell_on_target("Holy Fire", unit)) then return true end;
        if(btp_cast_spell_on_target("Smite", unit)) then return true end;
    else
        if (btp_priest_is_my_mindspike(unit)) then
            if(btp_cast_spell_on_target("Mind Blast", unit)) then return true end;
        end
        if(btp_cast_spell_on_target("Mind Spike", unit)) then return true end;
    end
    return false;
end

function btp_priest_dispell_buffs(unit)
    if (not unit) then unit="target"; end

    -- return if the target is friendly
    if (not UnitIsEnemy("player", unit)) then return false; end
    -- return if it is an npc
    if (not UnitIsPlayer(unit)) then return false; end

    while (buffTexture) do
        buffName, buffRank, buffTexture, buffApplications,
        buffType, buffDuration, buffTime, buffMine,
        buffStealable = UnitBuff(unit, i);

	if (buffTexture and buffTime and (
	    strfind(buffTexture, "PowerWordShield") or
	    strfind(buffTexture, "AntiShadow") or
	    strfind(buffTexture, "PrayerofShadowProtection") or
	    strfind(buffTexture, "Ice_Lament") or
	    strfind(buffTexture, "FrostArmor02")
	   )) then
            if (btp_cast_spell_on_target("Dispel Magic", debuffPlayer)) then return true; end
        end
    end
    return false;
end

function _btp_priest_dps_pve(unit)

    -- cast vamperic touch first if we are not moving
    if(not btp_is_moving()) then
    	-- if we have 3 shadow orbs use them
        if(btp_priest_is_shadoworbs()) then 
            if(btp_cast_spell_on_target("Mind Blast", unit)) then return true end;
        end   
        if (not btp_priest_is_my_vampirictouch(unit)) then
            if(btp_cast_spell_on_target("Vampiric Touch", unit)) then return true end;
        end
    end


    -- keep up dp
    if (not btp_priest_is_my_dp()) then
    	if(btp_cast_spell_on_target("Devouring Plague", unit)) then return true end
    end

    -- check if our target does not yet have SWP on 
    if (not btp_priest_is_my_swp(unit)) then
        if(btp_cast_spell_on_target("Shadow Word: Pain", unit)) then return true end;
    end

    -- cast vamperic touch if it's not up
    if(not btp_priest_is_my_vampirictouch(unit)) then
        if(btp_cast_spell_on_target("Vampiric Touch", unit)) then return true end;
    end

    if (not btp_is_moving()) then
        if(not btp_priest_is_shadowform()) then
            if(btp_cast_spell_on_target("Penance", unit)) then return true end;
            if(btp_cast_spell_on_target("Holy Fire", unit)) then return true end;
            if(btp_cast_spell_on_target("Smite", unit)) then return true end;
        else
            if(btp_cast_spell_on_target("Mind Blast", unit)) then return true end;
            if(btp_cast_spell_on_target("Mind Flay", unit)) then return true end;
        end
    end
    --
    -- Try to drain mana if we can
        -- if(UnitMana(unit) > 110) then
    --     if(btp_cast_spell_on_target("Mana Burn", unit)) then return true end;
    -- end

    return false;
end



function btp_priest_dps(unit)
    if(not unit) then  unit = "target"; end

    -- if our target is low on health then cast shadow word death
    if(unit and (UnitHealth(unit) < 2000) and (UnitHealth("player") > 1000)) then
        if(btp_cast_spell_on_target("Shadow Word: Death", unit)) then 
            return true; 
        end
    end

    -- check if we should cast shadowFiend
        if(UnitMana("player")/UnitManaMax("player") < .5) then
        if(btp_cast_spell_on_target("Shadowfiend", unit)) then return true; end
    end

    has_swp, my_swp, num_swp = btp_check_debuff("ShadowWordPain", unit);
    if(not my_swp and (UnitHealth(unit) > 2000)) then
        if(btp_cast_spell_on_target("Shadow Word: Pain", unit)) then 
            return true 
        end;
    end
    if(btp_cast_spell_on_target("Devouring Plague", unit)) then return true end
    -- if(btp_cast_spell_on_target("Mind Blast", unit)) then return true end;
    -- if(btp_cast_spell_on_target("Smite", unit)) then return true end;
    return false;
end

function btp_priest_heal()
    --
    -- Put any callback code here.
    --

    --
    -- Run Trinket code.
    --
    Trinkets();

    if(pvpBot) then
        return btp_priest_heal_pvp_quick();
    end

    if(btp_priest_heal_std()) then
        return true;
    -- else
        --return btp_priest_resurrection();
    end
    return false;
end

function btp_priest_resurrection()

    for i = 0, GetNumPartyMembers() do
        res_name = "party" .. i;
        if (UnitHealth(res_name) < 2 and UnitHealth("player") >= 2 and
            btp_check_dist(res_name,1)) then
            resurrectionName = res_name;
        end
    end

    for i = 1, GetNumRaidMembers() do
        res_name = "raid" .. i;
        if (UnitHealth(res_name) < 2 and UnitHealth("player") >= 2 and
            btp_check_dist(res_name,1)) then
            resurrectionName = res_name;
        end
    end

    if (not UnitAffectingCombat("player") and
        res_name ~= "none" and res_name ~= nil and
        UnitMana("player")/UnitManaMax("player") > PR_MANA) then
    if(btp_cast_spell_on_target("Resurrection", res_name)) then 
        return true; 
    end
    end

    return false;
end

-- i am hoping to speed up the heal function bye doing this.
function btp_priest_heal_pvp_quick()
BTP_PRIEST_THRESH_CRIT=.35
BTP_PRIEST_THRESH_LARGE=.49
BTP_PRIEST_THRESH_MEDIUM=.78
BTP_PRIEST_THRESH_SMALL=.85
BTP_PRIEST_THRESH_MANA=.15

    -- init
    ProphetKeyBindings();

    -- Check the player
    local cur_health = UnitHealth("player");
    local cur_health_max = UnitHealthMax("player");
    local cur_class = UnitClass("player");

    -- get our health status this is one pass
    -- local lowest_target = btp_health_status(.99);
    local lowest_percent, lowest_health, lowest_target = btp_health_status_quick();

    if(not lowest_percent or not lowest_health or not lowest_target 
       or lowest_target == false or lowest_target == nil) then
--         btp_frame_debug("nothing to heal 2");
        stopMoving = false;
        return false;
    end
    -- local lowest_health = UnitHealth(lowest_target);
    -- local lowest_health_max = UnitHealthMax(lowest_target);
    -- local lowest_percent = (lowest_health / lowest_health_max);
    -- local lowest_percent, lowest_health, lowest_target = btp_health_status_quick();

    -- no one is hurt
    if(not lowest_percent or lowest_percent == false) then
        stopMoving = false;
        return false;
    end
    
    -- blast out heals if we are in spirit form
    -- if(btp_priest_is_spirit()) then
    --     if(btp_priest_heal_crit(lowest_percent, lowest_health, lowest_target)) then return true; end;
    --     if(btp_priest_heal_large(lowest_percent, lowest_health, lowest_target)) then return true; end;
    --     if(btp_priest_heal_medium(lowest_percent, lowest_health, lowest_target)) then return true; end;
    --     if(btp_priest_heal_small(lowest_percent, lowest_health, lowest_target)) then return true; end;
    -- end

    -- check if we need to stop or start moving
    if(lowest_percent < BTP_PRIEST_THRESH_LARGE) then
        -- we only want to stop when we are close to the action
        -- or when we are so low on health that we need a larger heal
        if(btp_check_dist(lowest_target, 2)) then
            -- stop moving
            -- btp_frame_debug("STOP Moving");
            stopMoving = true;
            FuckBlizzardMove("TURNLEFT");
        end
    elseif(stopMoving) then
        if((lowest_percent >= BTP_PRIEST_THRESH_MEDIUM)) then
             -- btp_frame_debug("START Moving");
            stopMoving = false;
        end
    end

    -- heal our self first
    if(btp_priest_heal_self(lowest_percent, lowest_health, lowest_target)) then return true; end

    -- no one is hurt
    if(not lowest_percent or lowest_percent == false) then
        stopMoving = false;
        return false;
    end

    -- decurse if needed
    if ((((GetTime() - lastDecurse) >= 5) or blockOnDecurse) and
        BTP_Decursive()) then                                   
        lastDecurse = GetTime();
        return true;            
    end

    -- do our heals
    if(btp_priest_heal_crit(lowest_percent, lowest_health, lowest_target)) then return true; end;
    if(btp_priest_heal_large(lowest_percent, lowest_health, lowest_target)) then return true; end;
    if(btp_priest_heal_medium(lowest_percent, lowest_health, lowest_target)) then return true; end;
    if(btp_priest_heal_small(lowest_percent, lowest_health, lowest_target)) then return true; end;

    if(BTP_Decursive()) then
        return true;
    end
    return false;
end


function btp_priest_heal_crit(cur_percent, cur_health, cur_player)
    -- bang out any critical heals
    if(cur_percent > BTP_PRIEST_THRESH_CRIT) then return false; end
    -- btp_frame_debug("NEED CRIT " .. cur_player .. " " ..  UnitName(cur_player));

    if(btp_priest_is_sol()) then 
        if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
    end

    if(UnitAffectingCombat(cur_player)) then
        if(btp_cast_spell_on_target("Guardian Spirit", cur_player)) then return true; end

        if(not btp_priest_is_pws(cur_player)) then
            if(btp_cast_spell_on_target("Power Word: Shield", cur_player)) then return true; end
        end

        if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end

        if(not btp_priest_is_pom(cur_player)) then
            if(btp_cast_spell_on_target("Prayer of Mending", cur_player)) then return true; end
        end

        if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
    else
        if(not btp_priest_is_renew(cur_player)) then
            if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
        end
        if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
    end
    return false;
end


function btp_priest_heal_large(cur_percent, cur_health, cur_player)
    -- check everyone else for a large heal
    if(cur_percent > BTP_PRIEST_THRESH_LARGE) then return false; end

    -- btp_frame_debug("NEED LARGE " .. cur_player .. " " ..  UnitName(cur_player));

    if(btp_priest_is_sol()) then 
        if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
    end

    if(UnitAffectingCombat(cur_player)) then
        if(not btp_priest_is_pom(cur_player)) then
            if(btp_cast_spell_on_target("Prayer of Mending", cur_player)) then return true; end
        end

        if(not btp_priest_is_pws(cur_player)) then
            if(btp_cast_spell_on_target("Power Word: Shield", cur_player)) then return true; end
        end

        if(stopMoving) then
            if(btp_cast_spell_on_target("Greater Heal", cur_player)) then return true; end
        else
            if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
        end
    else
        if(stopMoving) then
            if(btp_cast_spell_on_target("Greater Heal", cur_player)) then return true; end
        else
            if(not btp_priest_is_renew(cur_player)) then
                if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
            end
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
        end
    end
    return false;
end

function btp_priest_heal_medium(cur_percent, cur_health, cur_player)
    -- Check for medium heals
    if(cur_percent > BTP_PRIEST_THRESH_MEDIUM) then return false; end

    -- btp_frame_debug("NEED MEDIUM " .. cur_player .. " " .. UnitName(cur_player));

    if(btp_priest_is_sol()) then 
        if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
    end
    if(UnitAffectingCombat(cur_player)) then

        if(not btp_priest_is_renew(cur_player)) then
            if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
        end

        if(not btp_priest_is_pws(cur_player)) then
            if(btp_cast_spell_on_target("Power Word: Shield", cur_player)) then return true; end
        end

        if(not btp_priest_is_pom(cur_player)) then
            if(btp_cast_spell_on_target("Prayer of Mending", cur_player)) then return true; end
        end

        if(stopMoving) then
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
        else
            if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
        end
    else
        if(not btp_priest_is_renew(cur_player)) then
            if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
        end
        if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
    end

    return false;
end

function btp_priest_heal_small(cur_percent, cur_health, cur_player)
    -- Check for small heals last
    if(cur_percent > BTP_PRIEST_THRESH_SMALL) then return false; end
    -- btp_frame_debug("NEED SMALL " .. cur_player .. " " .. UnitName(cur_player));
    if(not btp_priest_is_renew(cur_player)) then
        if(btp_cast_spell_on_target("Chakra", "player")) then return true; end
        if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
    end
    if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
end

-- heal ourself
function btp_priest_heal_self(cur_percent, cur_health, cur_player)
    -- Check the player
    local my_health = UnitHealth("player");
    local my_health_max = UnitHealthMax("player");
    local my_class = UnitClass("player");
    local my_percent = my_health/my_health_max;

    -- use any items since they should not trigger cooldown
    if(SelfHeal(BTP_PRIEST_THRESH_CRIT, BTP_PRIEST_THRESH_MANA)) then
        return true;
    end

    -- crit heal ourself
    if(my_percent <= BTP_PRIEST_THRESH_CRIT and my_health > 2) then
        if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end;
        end
        if(btp_cast_spell_on_target("Desperate Prayer", "player")) then return true; end

        if(not btp_priest_is_pws()) then
            if(btp_cast_spell_on_target("Power Word: Shield", "player")) then return true; end
        end

        if( not btp_priest_is_pom()) then
            if(btp_cast_spell_on_target("Prayer of Mending", "player")) then return true; end
        end
        if(stopMoving) then
            if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end
        end
        if(btp_cast_spell_on_target("Circle of Healing", "player")) then return true; end
        if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end
    end

    if(my_percent <= BTP_PRIEST_THRESH_MEDIUM and my_health > 2) then
        if(cur_player ~= nil and stopMoving and UnitName(cur_player) ~= UnitName("player")) then
            if(btp_cast_spell_on_target("Binding Heal", cur_player)) then return true; end;
        end
        -- no one else is hurt so target ourself
        if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end;
        end

        if(UnitAffectingCombat("player")) then
            if(not btp_priest_is_pom()) then
                if(btp_cast_spell_on_target("Prayer of Mending", "player")) then return true; end
            end
            if(btp_cast_spell("Psychic Scream")) then return true; end

            if(not btp_priest_is_pws()) then
                if(btp_cast_spell_on_target("Power Word: Shield", "player")) then return true; end
            end

        	if(btp_cast_spell_on_target("Chakra", "player")) then return true; end
            if(not btp_priest_is_renew()) then
                if(btp_cast_spell_on_target("Renew", "player")) then return true; end
            end

            if(stopMoving) then
                if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end
            else
                if(btp_cast_spell_on_target("Circle of Healing", "player")) then return true; end
                if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end
            end
        else
            if(stopMoving) then
                if(btp_cast_spell_on_target("Greater Heal", "player")) then return true; end
            else
        		if(btp_cast_spell_on_target("Chakra", "player")) then return true; end
                if(not btp_priest_is_renew()) then
                    if(btp_cast_spell_on_target("Renew", "player")) then return true; end
                end
                if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end
            end
        end
    end
    return false;
end

function btp_priest_heal_pvp()
BTP_PRIEST_THRESH_CRIT=.35
BTP_PRIEST_THRESH_LARGE=.49
BTP_PRIEST_THRESH_MEDIUM=.78
BTP_PRIEST_THRESH_SMALL=.85
BTP_PRIEST_THRESH_MANA=.15

    -- init
    ProphetKeyBindings();

    -- Check the player
    local cur_health = UnitHealth("player");
    local cur_health_max = UnitHealthMax("player");
    local cur_class = UnitClass("player");
    

    -- check if we are in spirit form if so spam out heals
    if(btp_priest_is_spirit()) then
        cur_player, party_cnt, raid_cnt, cur_party = btp_health_status(BTP_PRIEST_THRESH_LARGE);
        if(cur_player ~= false) then
            if(btp_cast_spell_on_target("Greater Heal", cur_player)) then return true; end
        end

        cur_player, party_cnt, raid_cnt, cur_party = btp_health_status(BTP_PRIEST_THRESH_MEDIUM);
        if(cur_player ~= false) then
            if(UnitAffectingCombat("player") and not btp_priest_is_pom()) then
                if(btp_cast_spell_on_target("Prayer of Mending", cur_player)) then return true; end
            end
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
        end

        cur_player, party_cnt, raid_cnt, cur_party = btp_health_status((BTP_PRIEST_THRESH_SMALL + .04));
        if(cur_player ~= false) then

            if(cur_party >= 2) then
                if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
            end

            if(not btp_priest_is_renew()) then
                if(btp_cast_spell_on_target("Renew", "player")) then return true; end
            end

            if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
        end
    end

    if ((((GetTime() - lastDecurse) >= 5) or blockOnDecurse) and
        BTP_Decursive()) then                                   
        lastDecurse = GetTime();
        return true;            
    end

    if(SelfHeal(BTP_PRIEST_THRESH_CRIT, BTP_PRIEST_THRESH_MANA)) then
        return true;
    end

    -- if we are getting hurt and in pvp mode
    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_SMALL and
       cur_health >= 5) then
        if(UnitAffectingCombat("player")) then
            if(btp_cast_spell("Psychic Scream")) then return true; end
            if(UnitAffectingCombat("player") and not btp_priest_is_pom()) then
                if(btp_cast_spell_on_target("Prayer of Mending", "player")) then return true; end
            end
            if(not btp_priest_is_pws()) then
                if(btp_cast_spell_on_target("Power Word: Shield", "player")) then return true; end
            end
        end
    end
    
    -- if we are about to die
    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_CRIT and
       cur_health >= 5) then
        if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end;
        end
        if(btp_cast_spell_on_target("Desperate Prayer", "player")) then return true; end

        if(not btp_priest_is_pws()) then
            if(btp_cast_spell_on_target("Power Word: Shield", "player")) then return true; end
        end

        if( not btp_priest_is_pom()) then
            if(btp_cast_spell_on_target("Prayer of Mending", "player")) then return true; end
        end
        if(stopMoving) then
            if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end
        end
        if(btp_cast_spell_on_target("Circle of Healing", "player")) then return true; end
    end

    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_MEDIUM and
       cur_health >= 5) then
        if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end;
        end
        if(UnitAffectingCombat("player") and not btp_priest_is_pom()) then
            if(btp_cast_spell_on_target("Prayer of Mending", "player")) then return true; end
        end
        if(not btp_priest_is_pws()) then
            if(btp_cast_spell_on_target("Power Word: Shield", "player")) then return true; end
        end
        if(not btp_priest_is_renew()) then
            if(btp_cast_spell_on_target("Renew", "player")) then return true; end
        end
        -- may want to remove this but should make her last longer in pvp
        if(btp_cast_spell_on_target("Circle of Healing", "player")) then return true; end
    end

    -- bang out any critical heals
    cur_player = btp_health_status(BTP_PRIEST_THRESH_CRIT);
    if(cur_player ~= false) then

           if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
        end

        if(UnitAffectingCombat(cur_player)) then
            if(btp_cast_spell_on_target("Guardian Spirit", cur_player)) then return true; end

            if(btp_priest_is_pws()) then
                if(btp_cast_spell_on_target("Power Word: Shield", "player")) then return true; end
            end

            if(not btp_priest_is_pom()) then
                if(btp_cast_spell_on_target("Prayer of Mending", cur_player)) then return true; end
            end

            if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
        else

            if(not btp_priest_is_renew(cur_player)) then
                if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
            end
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
        end
    end


    -- check if we need to stop or start moving
    cur_player = btp_health_status(.78);
    if((cur_health/cur_health_max <= .45 or
        cur_player ~= false)) then
        -- we only want to stop when we are close to the action
        -- or when we are so low on health that we need a larger heal
        if(btp_check_dist(cur_player, 2) or
            (cur_health/cur_health_max <= .45)) then
            -- stop moving
            -- btp_frame_debug("STOP Moving");
            --
            -- XXX for not disable
            stopMoving = true;
            FuckBlizzardMove("TURNLEFT");
        end
    elseif(stopMoving) then
        cur_player = btp_health_status(BTP_PRIEST_THRESH_LARGE);
        if((cur_health/cur_health_max >= BTP_PRIEST_THRESH_LARGE) and
            not cur_player) then
            -- btp_frame_debug("START Moving");
            stopMoving = false;
        end
    end


    -- cast our larger heals on our self if need be
    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_LARGE and
       cur_health >= 5) then
           -- if someone else is also hurt might as well use binding heal
        cur_player = btp_health_status(BTP_PRIEST_THRESH_MEDIUM);
        if(cur_player ~= false and stopMoving) then
            if(btp_cast_spell_on_target("Binding Heal", cur_player)) then return true; end;
        end
        -- no one else is hurt so target ourself
           if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end;
        end

        if(UnitAffectingCombat("player")) then
            if(not btp_priest_is_pom()) then
                if(btp_cast_spell_on_target("Prayer of Mending", "player")) then return true; end
            end

            if(not btp_priest_is_renew(cur_player)) then
                if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
            end

            if(not btp_priest_is_pws()) then
                if(btp_cast_spell_on_target("Power Word: Shield", "player")) then return true; end
            end

            if(stopMoving) then
                if(btp_cast_spell_on_target("Greater Heal", "player")) then return true; end
            else
                if(btp_cast_spell_on_target("Circle of Healing", "player")) then return true; end
            end
        else
            if(stopMoving) then
                if(btp_cast_spell_on_target("Greater Heal", "player")) then return true; end
            else
                if(not btp_priest_is_renew(cur_player)) then
                    if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
                end
                if(btp_cast_spell_on_target("Flash Heal", "player")) then return true; end
            end
        end
    end


    -- check everyone else for a large heal
    cur_player = btp_health_status(BTP_PRIEST_THRESH_LARGE);
    if(cur_player ~= false) then
           if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
        end

        if(UnitAffectingCombat(cur_player)) then
            if(not btp_priest_is_pom(cur_player)) then
                if(btp_cast_spell_on_target("Prayer of Mending", cur_player)) then return true; end
            end

            if(not btp_priest_is_pws()) then
                if(btp_cast_spell_on_target("Power Word: Shield", cur_player)) then return true; end
            end

            if(stopMoving) then
                if(btp_cast_spell_on_target("Greater Heal", cur_player)) then return true; end
            else
                if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
            end

        else
            if(stopMoving) then
                if(btp_cast_spell_on_target("Greater Heal", cur_player)) then return true; end
            else
                if(not btp_priest_is_renew(cur_player)) then
                    if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
                end
                if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
            end
        end

    end

    -- Check for medium heals
    cur_player, party_cnt, raid_cnt, cur_party = btp_health_status(BTP_PRIEST_THRESH_MEDIUM);
    if(cur_player ~= false) then

           if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
        end

        if(UnitAffectingCombat(cur_player)) then
            if(not btp_priest_is_pom(cur_player)) then
                if(btp_cast_spell_on_target("Prayer of Mending", cur_player)) then return true; end
            end
 
            if(not btp_priest_is_renew(cur_player)) then
                if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
            end

            if(not btp_priest_is_pws()) then
                if(btp_cast_spell_on_target("Power Word: Shield", cur_player)) then return true; end
            end

            if(stopMoving) then
                if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
            else
                if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
            end


        else
            if(not btp_priest_is_renew(cur_player)) then
                if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
            end

            if(stopMoving) then
                if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end
            end
        end

    end

    -- Check for small heals last
    -- XXX will want to change this
    cur_player = btp_health_status(BTP_PRIEST_THRESH_SMALL);
    if(cur_player ~= false) then
           if(btp_priest_is_sol()) then 
            if(btp_cast_spell_on_target("Flash Heal", cur_player)) then return true; end;
        end
        if(not btp_priest_is_renew(cur_player)) then
            if(btp_cast_spell_on_target("Renew", cur_player)) then return true; end
        end
    end

    if(BTP_Decursive()) then
        return true;
    end
    return false;
end


function btp_priest_heal_std()
    -- init
    ProphetKeyBindings();

    -- Check the player
    local cur_health = UnitHealth("player");
    local cur_health_max = UnitHealthMax("player");
    local cur_class = UnitClass("player");

    -- check if we are in spirit form if so spam out heals
    if(btp_priest_is_spirit()) then
        cur_player = btp_health_status(BTP_PRIEST_THRESH_SMALL);
        FuckBlizzardTargetUnit(cur_player);
        if(cur_player ~= false) then
            if(UnitAffectingCombat("player") and not btp_priest_is_pom()) then
                if(btp_cast_spell("Prayer of Mending")) then return true; end
            end
            if(btp_cast_spell("Circle of Healing")) then return true; end
            if(btp_cast_spell("Prayer of Healing")) then return true; end
            if(btp_cast_spell("Flash Heal")) then return true; end
        end

    end

    if ((((GetTime() - lastDecurse) >= 5) or blockOnDecurse) and
        BTP_Decursive()) then                                   
        lastDecurse = GetTime();
        return true;            
    end

    if(SelfHeal(BTP_PRIEST_THRESH_CRIT, BTP_PRIEST_THRESH_MANA)) then
        return true;
    end

    -- if we are getting hurt and in pvp mode
    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_SMALL and
       cur_health >= 5) then
        if(UnitAffectingCombat("player")) then
               if(pvpBot) then
                if(btp_cast_spell("Psychic Scream")) then return true; end
            else
                if(btp_cast_spell("Fade")) then return true; end
            end
        end
    end

    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_CRIT and
       cur_health >= 5) then
        FuckBlizzardTargetUnit("player");
        if(not btp_priest_is_pws()) then
            if(btp_cast_spell("Power Word: Shield")) then return true; end
        end
        if(btp_cast_spell("Circle of Healing")) then 
            return true; 
        end
        if(btp_cast_spell("Flash Heal")) then 
            return true; 
        end
    end

    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_MEDIUM and
       cur_health >= 5) then
        FuckBlizzardTargetUnit("player");
        if(not btp_priest_is_renew()) then
            if(btp_cast_spell("Renew")) then return true; end
        end
    end

    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_LARGE and
       cur_health >= 5) then
        cur_player = btp_health_status(BTP_PRIEST_THRESH_MEDIUM);
        if(cur_player ~= false) then
            FuckBlizzardTargetUnit(cur_player);
            if(btp_cast_spell("Binding Heal")) then return true; end;
        end
        FuckBlizzardTargetUnit("player");
        if(pvpBot) then
            if(btp_cast_spell("Flash Heal")) then return true; end
        else
            if(btp_cast_spell("Greater Heal")) then return true; end
        end
    end

    -- Check for critical heals and use a fast heal
    cur_player = btp_health_status(BTP_PRIEST_THRESH_CRIT);
    if(cur_health/cur_health_max <= BTP_PRIEST_THRESH_CRIT and
       cur_health >= 5) then
        FuckBlizzardTargetUnit(cur_player);
        if(not btp_priest_is_pws(cur_player)) then
            if(btp_cast_spell("Power Word: Shield")) then return true; end
        end
        if(btp_cast_spell("Circle of Healing")) then 
            return true; 
        end
        if(btp_cast_spell("Flash Heal")) then 
            return true; 
        end
    end

    -- Check for large heals
    cur_player = btp_health_status(BTP_PRIEST_THRESH_LARGE);
    if(cur_player ~= false) then
        FuckBlizzardTargetUnit(cur_player);
        if(pvpBot) then
            if(btp_cast_spell("Flash Heal")) then return true; end
        else
            if(btp_cast_spell("Greater Heal")) then return true; end
        end
    end

    
    -- Check for medium heals
    -- cur_player = btp_health_status(BTP_PRIEST_THRESH_MEDIUM);
    cur_player, party_cnt, raid_cnt, cur_party = btp_health_status(BTP_PRIEST_THRESH_MEDIUM);
    
    if(cur_player ~= false) then
        FuckBlizzardTargetUnit(cur_player);

        if(not btp_priest_is_renew(cur_player)) then
            if(btp_cast_spell("Renew")) then return true; end
        end

        if(UnitAffectingCombat(cur_player) and not btp_priest_is_pom(cur_player)) then
            if(btp_cast_spell("Prayer of Mending")) then return true; end
        end

        if(UnitAffectingCombat(cur_player)) then
            if(cur_party >= 2) then
                if(btp_cast_spell_on_target("Circle of Healing", cur_player)) then return true; end
            end

            if(btp_cast_spell("Flash Heal")) then 
                return true; 
            end
        end
    end

    -- Check for small heals last
    -- XXX will want to change this
    cur_player = btp_health_status(BTP_PRIEST_THRESH_SMALL);
    if(cur_player ~= false) then

        FuckBlizzardTargetUnit(cur_player);
        if(not btp_priest_is_renew(cur_player)) then
            if(btp_cast_spell("Renew")) then return true; end
        end
        if(UnitAffectingCombat(cur_player) and not btp_priest_is_pom(cur_player)) then
            if(btp_cast_spell("Prayer of Mending")) then return true; end
        end


    end

     if(BTP_Decursive()) then
         return true;
     end
    return false;
end


function btp_priest_is_pws(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_debuff("AshesToAshes", unit)) then return true; end
    if(btp_check_buff("PowerWordShield", unit)) then return true; end
    return false;
end

function btp_priest_is_sol(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("SurgeOfLight", unit)) then 
        return true; 
    end
    return false;
end


function btp_priest_is_serendipity(unit, num) 
    if(not unit) then  unit = "player"; end
    if(not num) then num = 2; end
    has_sdip, my_sdip, num_sdip = btp_check_buff("Serendipity", unit);
    if (has_sdip and num_sdip >= num) then return true; end
    return false;
end

function btp_priest_is_shadoworbs(unit, num) 
    if(not unit) then  unit = "player"; end
    if(not num) then num = 3; end
    has_orbs, my_orbs, num_orbs = btp_check_buff("shadoworbs", unit);
    if (has_orbs and num_orbs >= num) then return true; end
    return false;
end

function btp_priest_is_renew(unit)
    if(not unit) then  unit = "player"; end
    -- targets can have multiple renews so only return true
    -- if they have your renew on
    has_renew, my_renew, num_renew = btp_check_buff("Renew", unit);
    if(my_renew) then return true; end
    return false;
end

function btp_priest_is_spirit(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("GreaterHeal", unit)) then return true; end
    return false;
end

function btp_priest_is_pom(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("PrayerOfMending", unit)) then return true; end
    return false;
end

function btp_priest_is_shadowform(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("Shadowform", unit)) then return true; end
    return false;
end

function btp_priest_is_fearward(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("Excorcism", unit)) then return true; end
    return false;
end

function btp_priest_is_fortitude(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("WordFortitude", unit)) then return true; end
    if(btp_check_buff("PrayerOfFortitude", unit)) then return true; end
    return false;
end

function btp_priest_is_innerfire(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("InnerFire", unit)) then return true; end
    return false;
end

function btp_priest_is_divinespirit(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("DivineSpirit", unit)) then return true; end
    if(btp_check_buff("PrayerofSpirit", unit)) then return true; end
    return false;
end

function btp_priest_is_innerwill(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("innewill", unit)) then return true; end
    return false;
end

function btp_priest_is_shadowprotection(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("AntiShadow", unit)) then return true; end
    if(btp_check_buff("PrayerofShadowProtection", unit)) then return true; end
    return false;
end


function btp_priest_is_touchofweakness(unit)
    if(not unit) then  unit = "player"; end
    if(btp_check_buff("DeadofNight", unit)) then return true; end
    return false;
end

function btp_priest_is_my_vampiricembrace(unit)
    if(not unit) then  unit = "player"; end
    has_vemb, my_vemb, num_vemb = btp_check_buff("UnsummonBuilding", unit);
    if (my_vemb) then return true; end
    return false;
end

function btp_priest_is_my_vampirictouch(unit)
    if(not unit) then  unit = "player"; end
    has_vtouch, my_vtouch, num_vtouch = btp_check_debuff("Stoicism", unit);
    if(my_vtouch) then return true; end
    return false;
end;

function btp_priest_is_my_mindspike(unit, num)
    if(not unit) then  unit = "target"; end
    if(not num) then num = 3; end
    has_mspike, my_mspike, num_mspike = btp_check_debuff("mindspike", unit);
    if (my_mspike and num_mspike >= num) then return true; end
    return false;
end;

function btp_priest_is_my_swp(unit)
    if(not unit) then  unit = "target"; end
    has_swp, my_swp, num_swp = btp_check_debuff("ShadowWordPain", unit);
    return my_swp;
end

function btp_priest_is_my_dp(unit)
    if(not unit) then  unit = "target"; end
    has_swp, my_swp, num_swp = btp_check_debuff("DevouringPlague", unit);
    return my_swp;
end


