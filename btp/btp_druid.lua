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
-- These are fairly well tested and should not need to be changed.
--
DR_THRESH = .45;
DR_SCALAR = .50;
DR_MANA = .3;

--
-- MAX_DRDEST is how many destruction spells you have to cycle through.
-- Again this count it from 0 - 3, which is a total of 4.  There may be
-- more to cycle through as bliz adds more spells.
--
MAX_DRDEST = 1;

--
-- This is the last trinket you expect to find in the chain of trinkets
-- that will cycle through the top slot with a call to the fun trink code.
-- That is, your top trinket slot is set up to change trinkets if you have
-- those trinkets in your bag, this value is the name of the last (base)
-- trinket that will be called.  So if you blow the cooldown on all your
-- other trinkets, this will be flipped into place until the cooldown is
-- ready.
--
DRUID_DEF_TRINKET = "Scarab of the Infinite Cycle";

--
-- YOU CAN STOP HERE!  THERE IS NOTHING LEFT FOR YOU TO CHANGE.
--
druidDestCount = 0;
memberIDDR = 1;
lastLBTarget = "player";

lastEntanglingRoots = 0;
lastNaturesGrasp = 0;
lastFaerieFire = 0;
lastTranquility = 0;

iTarget = UnitName("player");

function btp_druid_initialize()
    btp_frame_debug("Druid INIT");

    SlashCmdList["DRUIDB"] = druid_buff;
    SLASH_DRUIDB1 = "/db";
    SlashCmdList["DRUIDH"] = druid_heal;
    SLASH_DRUIDH1 = "/dh";
    SlashCmdList["DRUIDD"] = druid_dps;
    SLASH_DRUIDD1 = "/dd";
    SlashCmdList["DRUIDS"] = druid_solo;
    SLASH_DRUIDS1 = "/ds";

    cb_array["Regrowth"]           = btp_cb_druid_regrowth;
    cb_array["Healing Touch"]      = btp_cb_druid_healing_touch;
    cb_array["Nourish"]            = btp_cb_druid_nourish;
    cb_array["Tranquility"]        = btp_cb_druid_tranquility;
end

function druid_heal()
    castingBandage = false;
    hasBandage = false;
    bandageBag = 0;
    bandageSlot = 1;
    playerName = nil;

    if (current_cb ~= nil and current_cb()) then
        return true;
    end

    --
    -- We need to reset this here since a druid callback may have flipped it.
    -- Hmmm now that I think about this, this is hax!
    --
    stopMoving = false;

    --
    -- Innervate Buff Check
    --
    hasInnervate, myInnervate,
    numInnervate = btp_check_buff("Nature_Lightning", "player");

    --
    -- Innervate Buff Check
    --
    targetHasInnervate, targetMyInnervate,
    targetNumInnervate = btp_check_buff("Nature_Lightning",
                                        btp_name_to_unit(iTarget));

    --
    -- Clear Casting check
    --
    hasClearCasting, myClearCasting,
    numClearCasting = btp_check_buff("ManaBurn", "player");

    hasBandageBuff, myBandageBuff,
    numBandageBuff = btp_check_buff("Holy_Heal", bandageTarget);

    if (((GetTime() - lastBandage) <= 1) or myBandageBuff) then
        castingBandage = true;
    end

    if (castingBandage) then
        return true;
    end

    Trinkets();
    ProphetKeyBindings();

    for bag=0,4 do
      for slot=1,GetContainerNumSlots(bag) do
        if (GetContainerItemLink(bag,slot)) then
          if (string.find(GetContainerItemLink(bag,slot), "Bandage")) then
              start, duration, enable = GetContainerItemCooldown(bag, slot);
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

    if (SelfHeal((DR_THRESH + DR_SCALAR)/2, DR_MANA/3)) then
        --
        -- doing a self heal here (healthstones, potions, etc)
        --
        return true;
    elseif (not hasClearCasting and not targetHasInnervate and
            UnitAffectingCombat("player") and
            UnitMana(btp_name_to_unit(iTarget)) /
            UnitManaMax(btp_name_to_unit(iTarget)) <= DR_MANA/3 and
            btp_cast_spell_on_target("Innervate",
            btp_name_to_unit(iTarget))) then
        FuckBlizzardTargetUnit("playertarget");
        return true;
    elseif (UnitAffectingCombat("player") and
            UnitHealth("player")/UnitHealthMax("player") <=
           (DR_THRESH + DR_SCALAR) and UnitHealth("player") > 1 and
            btp_cast_spell("Barkskin")) then
        return true;
    elseif (UnitAffectingCombat("player") and
            not btp_check_buff("StoneClawTotem", "player") and
            UnitHealth("player")/UnitHealthMax("player") <=
           (DR_THRESH + DR_SCALAR) and UnitHealth("player") > 1 and
            btp_cast_spell("Nature's Grasp")) then
        return true;
    end

    if ((((GetTime() - lastDecurse) >= 5) or blockOnDecurse) and
        BTP_Decursive()) then
        lastDecurse = GetTime();
        return true;
    end

    if (not hasClearCasting and
        btp_cast_spell("Nature's Swiftness")) then
        return true;
    end

    --
    -- Check for large heals
    --
    playerName, partyHurtCount, raidHurtCount,
    raidSubgroupHurtCount = btp_health_status(DR_THRESH);

    if (playerName) then
        --
        -- Bandage Debuff check
        --
        hasBandageDebuff, myBandageDebuff,
        numBandageDebuff = btp_check_debuff("Bandage_08", playerName);

        --
        -- Rejuvination check
        --
        hasRejuvenation, myRejuvenation,
        numRejuvenation = btp_check_buff("Rejuvenation", playerName);

        --
        -- Lifebloom check
        --
        hasLifebloom, myLifebloom,
        numLifebloom = btp_check_buff("Felblossom", playerName);

        --
        -- Regrowth check
        --
        hasRegrowth, myRegrowth,
        numRegrowth = btp_check_buff("ResistNature", playerName);

        --
        -- Wild Growth check
        --
        hasWildGrowth, myWildGrowth,
        numWildGrowth = btp_check_buff("Flourish", playerName);

        if ((raidHurtCount > 1 or partyHurtCount > 1) and
            not myWildGrowth and
            btp_cast_spell_on_target("Wild Growth", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (partyHurtCount > 1 and UnitAffectingCombat("player") and
                not pvpBot and btp_cast_spell("Tranquility")) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            lastTranquility = GetTime();
            return true;
        elseif ((myRejuvenation or myRegrowth) and
                UnitAffectingCombat("player") and
                btp_cast_spell_on_target("Swiftmend", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (not myRegrowth and not pvpBot and
                btp_cast_spell_on_target("Regrowth", playerName)) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (not myRejuvenation and
                btp_cast_spell_on_target("Rejuvenation", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif ((not myLifebloom or (myLifebloom and numLifebloom < 3)) and
                UnitAffectingCombat("player") and (lastLBTarget == playerName or
                not btp_check_dist(lastLBTarget, 1) or
                UnitHealth(lastLBTarget)/UnitHealthMax(lastLBTarget) >
                DR_THRESH/2) and
                btp_cast_spell_on_target("Lifebloom", playerName)) then
            lastLBTarget = playerName;
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (partyHurtCount > 1 and UnitAffectingCombat("player") and
                btp_cast_spell("Tranquility")) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            lastTranquility = GetTime();
            return true;
        elseif (not myRegrowth and
                btp_cast_spell_on_target("Regrowth", playerName)) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (UnitAffectingCombat("player") and not hasClearCasting and
                btp_cast_spell_on_target("Nourish", playerName)) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (UnitAffectingCombat("player") and
                btp_cast_spell_on_target("Healing Touch", playerName)) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (hasBandage and not hasBandageDebuff and
                UnitAffectingCombat("player") and
                UnitMana("player")/UnitManaMax("player") <= DR_MANA/4) then
            lastBandage = GetTime();
            bandageTarget = playerName;
            FuckBlizzardTargetUnitContainer(playerName);
            FuckBlizUseContainerItem(bandageBag, bandageSlot);
            return true;
        end
    end

    --
    -- This is because people in raids need a res, and no matter what
    -- anyone says, the people that are critical should be healed first.
    -- Nevertheless, if the user just needs a helpful heal then we should
    -- battle res anyone that needs one first.
    --
    for i = 1, GetNumRaidMembers() do
        nextPlayer = "raid" .. i;
        if (UnitAffectingCombat("player") and
            UnitExists(nextPlayer) == 1 and UnitHealth(nextPlayer) <= 1 and
            btp_check_dist(nextPlayer, 1) and
            btp_cast_spell_on_target("Rebirth", nextPlayer)) then
            return true;
        elseif (not UnitAffectingCombat("player") and
                UnitExists(nextPlayer) == 1 and UnitHealth(nextPlayer) <= 1 and
                btp_check_dist(nextPlayer, 1) and
                btp_cast_spell_on_target("Revive", nextPlayer)) then
            return true;
        end
    end

    if (GetNumRaidMembers() <= 0) then
        for i = 1, GetNumPartyMembers() do
            nextPlayer = "party" .. i;
            if (UnitAffectingCombat("player") and
                UnitExists(nextPlayer) == 1 and UnitHealth(nextPlayer) <= 1 and
                btp_check_dist(nextPlayer, 1) and
                btp_cast_spell_on_target("Rebirth", nextPlayer)) then
                return true;
            elseif (not UnitAffectingCombat("player") and
                    UnitExists(nextPlayer) == 1 and
                    UnitHealth(nextPlayer) <= 1 and
                    btp_check_dist(nextPlayer, 1) and
                    btp_cast_spell_on_target("Revive", nextPlayer)) then
                return true;
            end
        end
    end

    --
    -- Check for Healing Over Time spells
    --
    playerName, partyHurtCount, raidHurtCount,
    raidSubgroupHurtCount = btp_health_status(DR_THRESH+DR_SCALAR, btpRaidHeal);

    --
    -- Tree Form has changed and we should now pick the times we want to use it.
    -- This should mean we never use it unless we're in combat, and more than
    -- two people are hurt at this level. 
    --
    if (UnitAffectingCombat("player") and not btp_druid_istree() and
       (raidHurtCount > 1 or partyHurtCount > 1) and
        btp_cast_spell("Tree of Life")) then
        return true;
    end

    --
    -- This should let us only heal people that _need_ to be healed when
    -- building up mana.  It will help keep us outside the 5 second rule
    -- and yield more healing over time.  In short, if we have an innervate
    -- up, then we will only heal people above DR_THRESH if they are tanking.
    --
    if (hasInnervate and not playerName) then
        return false;
    elseif (hasInnervate and playerName and
            UnitHealth(playerName)/UnitHealthMax(playerName) <=
            DR_THRESH + DR_SCALAR/2 and
            UnitThreatSituation(playerName) ~= nil and
            UnitThreatSituation(playerName) < 2) then
        return false;
    end

    if (playerName) then
        --
        -- Bandage Debuff check
        --
        hasBandageDebuff, myBandageDebuff,
        numBandageDebuff = btp_check_debuff("Bandage_08", playerName);

        --
        -- Rejuvination check
        --
        hasRejuvenation, myRejuvenation,
        numRejuvenation = btp_check_buff("Rejuvenation", playerName);

        --
        -- Lifebloom check
        --
        hasLifebloom, myLifebloom,
        numLifebloom = btp_check_buff("Felblossom", playerName);

        --
        -- Regrowth check
        --
        hasRegrowth, myRegrowth,
        numRegrowth = btp_check_buff("ResistNature", playerName);

        --
        -- Wild Growth check
        --
        hasWildGrowth, myWildGrowth,
        numWildGrowth = btp_check_buff("Flourish", playerName);

        --
        -- Thorns check
        --
        hasThorns, myThorns,
        numThorns = btp_check_buff("Thorns", nextPlayer);

        if ((raidHurtCount > 1 or partyHurtCount > 1) and
            not myWildGrowth and
            btp_cast_spell_on_target("Wild Growth", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (partyHurtCount > 3 and UnitAffectingCombat("player") and
                not pvpBot and btp_cast_spell("Tranquility")) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            lastTranquility = GetTime();
            return true;
        elseif ((myRejuvenation or myRegrowth) and
                UnitAffectingCombat("player") and
                UnitHealth(playerName)/UnitHealthMax(playerName) <= 
                DR_THRESH + DR_SCALAR/2 and
                btp_cast_spell_on_target("Swiftmend", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (not myRejuvenation and
                btp_cast_spell_on_target("Rejuvenation", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif ((not myLifebloom or (myLifebloom and numLifebloom < 3)) and
                UnitAffectingCombat("player") and (lastLBTarget == playerName or
                not btp_check_dist(lastLBTarget, 1) or
                UnitHealth(lastLBTarget)/UnitHealthMax(lastLBTarget) >
                DR_THRESH + DR_SCALAR/2) and
                btp_cast_spell_on_target("Lifebloom", playerName)) then
            lastLBTarget = playerName;
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (partyHurtCount > 3 and UnitAffectingCombat("player") and
                btp_cast_spell("Tranquility")) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            lastTranquility = GetTime();
            return true;
        elseif (UnitAffectingCombat("player") and not myThorns and
                UnitHealth(playerName)/UnitHealthMax(playerName) > 
                DR_THRESH + DR_SCALAR/2 and
                UnitThreatSituation(playerName) ~= nil and
                UnitThreatSituation(playerName) == 3 and
                btp_cast_spell_on_target("Thorns", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (UnitAffectingCombat("player") and not myThorns and
                UnitHealth(playerName)/UnitHealthMax(playerName) > 
                DR_THRESH + DR_SCALAR/2 and pvpBot and
                btp_cast_spell_on_target("Thorns", playerName)) then
            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (UnitAffectingCombat("player") and not myRegrowth and
                UnitHealth(playerName)/UnitHealthMax(playerName) <= 
                DR_THRESH + DR_SCALAR/2 and
                btp_cast_spell_on_target("Regrowth", playerName)) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (UnitAffectingCombat("player") and not hasClearCasting and
                UnitHealth(playerName)/UnitHealthMax(playerName) <= 
                DR_THRESH + DR_SCALAR/2 and
                btp_cast_spell_on_target("Nourish", playerName)) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (UnitAffectingCombat("player") and
                UnitHealth(playerName)/UnitHealthMax(playerName) <= 
                DR_THRESH + DR_SCALAR/2 and
                btp_cast_spell_on_target("Healing Touch", playerName)) then

            if (not stopMoving and pvpBot and farmBG) then
                stopMoving = true;
                FuckBlizzardMove("TURNLEFT");
            end

            FuckBlizzardTargetUnit("playertarget");
            return true;
        elseif (hasBandage and not hasBandageDebuff and
                UnitAffectingCombat("player") and
                UnitMana("player")/UnitManaMax("player") <= DR_MANA/4) then
            lastBandage = GetTime();
            bandageTarget = playerName;
            FuckBlizzardTargetUnitContainer(playerName);
            FuckBlizUseContainerItem(bandageBag, bandageSlot);
            return true;
        end
    end

    if (BTP_Decursive()) then
        return true;
    end

    return false;
end

function druid_buff()
    noMarkOfWild = true;
    hasWild = false;
    treeCount = 0;
    goodToBuff = true;
    nextPlayer = "player";

    Trinkets();
    ProphetKeyBindings();

    if (GetNumRaidMembers() > 0) then
        for i = 1, GetNumRaidMembers() do
            nextPlayer = "raid" .. i;
            if (UnitHealth(nextPlayer) < 4 or
                not btp_check_dist(nextPlayer,1)) then
                goodToBuff = false;
                break;
            end
        end
    end

    if (GetNumRaidMembers() <= 0) then
        for i = 1, GetNumPartyMembers() do
            nextPlayer = "party" .. i;
            if (UnitHealth(nextPlayer) < 4 or
                not btp_check_dist(nextPlayer,1)) then
                goodToBuff = false;
                break;
            end
        end
    end

    if (GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0) then
        goodToBuff = false;
    end

    for bag=0,4 do
      for slot=1,GetContainerNumSlots(bag) do
        if (GetContainerItemLink(bag,slot)) then
          if (string.find(GetContainerItemLink(bag,slot), "Wild")) then
              hasWild = true;
              break;
          end
        end
      end
    end

    --
    -- Mark of the Wild check
    --
    hasMark, myMark, numMark = btp_check_buff("Regeneration", "player");

    --
    -- Gift of the Wild check
    --
    hasGift, myGift, numGift = btp_check_buff("GiftoftheWild", "player");

    if (hasMark or hasGift) then
        noMarkOfWild = false;
    end

    if (noMarkOfWild and
        btp_cast_spell_on_target("Mark of the Wild", "player")) then
        FuckBlizzardTargetUnit("playertarget");
        return true;
    end

    if (math.random(100) == 69 and btp_cast_spell("Two Forms")) then
        return true;
    end

    for i = 1, GetNumRaidMembers() do
        nextPlayer = "raid" .. i;
        noMarkOfWild = true;

        if (UnitHealth(nextPlayer) >= 5 and
            btp_check_dist(nextPlayer,1)) then
            --
            -- Mark of the Wild check
            --
            hasMark, myMark,
            numMark = btp_check_buff("Regeneration", nextPlayer);

            --
            -- Gift of the Wild check
            --
            hasGift, myGift,
            numGift = btp_check_buff("GiftoftheWild", nextPlayer);

            --
            if (hasMark or hasGift) then
                noMarkOfWild = false;
            end

            if (hasWild and noMarkOfWild and goodToBuff and not pvpBot and
                btp_cast_spell_on_target("Gift of the Wild", nextPlayer)) then
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end

            if (noMarkOfWild and
                btp_cast_spell_on_target("Mark of the Wild", nextPlayer)) then
                FuckBlizzardTargetUnit("playertarget");
                return true;
            end
        end
    end

    if (GetNumRaidMembers() <= 0) then
        for i = 1, GetNumPartyMembers() do
            nextPlayer = "party" .. i;
            noMarkOfWild = true;

            if (UnitHealth(nextPlayer) >= 5 and
                btp_check_dist(nextPlayer,1)) then
                --
                -- Mark of the Wild check
                --
                hasMark, myMark,
                numMark = btp_check_buff("Regeneration", nextPlayer);

                --
                -- Gift of the Wild check
                --
                hasGift, myGift,
                numGift = btp_check_buff("GiftoftheWild", nextPlayer);

                --
                -- Thorns check
                --
                hasThorns, myThorns,
                numThorns = btp_check_buff("Thorns", nextPlayer);

                if (hasMark or hasGift) then
                    noMarkOfWild = false;
                end

                if (hasWild and noMarkOfWild and goodToBuff and not pvpBot and
                    btp_cast_spell_on_target("Gift of the Wild",
                    nextPlayer)) then
                    FuckBlizzardTargetUnit("playertarget");
                    return true;
                end

                if (noMarkOfWild and
                    btp_cast_spell_on_target("Mark of the Wild",
                    nextPlayer)) then
                    FuckBlizzardTargetUnit("playertarget");
                    return true;
                end

                if (noThorns and
                    btp_cast_spell_on_target("Thorns", nextPlayer)) then
                    FuckBlizzardTargetUnit("playertarget");
                    return true;
                end
            end
        end
    end
end

function druid_dps()
    if (current_cb ~= nil and current_cb()) then
        return true;
    end

    Trinkets();
    ProphetKeyBindings();

    --
    -- Thorns check
    --
    hasMoonfire, myMoonfire,
    numMoonfire = btp_check_debuff("StarFall", "target");

    if (SelfHeal(DR_THRESH, DR_MANA/3)) then
        --
        -- doing a self heal here (heathstones, potions, etc)
        --
    elseif (not myMoonfire and btp_cast_spell("Moonfire")) then
        return true;
    elseif (UnitHealth("player")/UnitHealthMax("player") == 1 and
            btp_cast_spell("Starfire")) then
        return true;
    elseif (btp_cast_spell("Wrath")) then
        return true;
    end

    return false;
end

function druid_solo()
    if (SelfHeal(DR_THRESH, DR_MANA/3)) then
        --
        -- doing a self heal here (heathstones, potions, etc)
        --
    elseif (druid_heal()) then
        return true;
    elseif (druid_buff()) then
        return true;
    elseif (druid_dps()) then
        return true;
    end

    return false;
end

function btp_druid_boomkin()
    -- This is the same number for tree form
    return btp_druid_istree();
end

function btp_druid_istree()
    if (GetShapeshiftForm(true) == 5) then
        return true;
    else
        return false;
    end
end

function btp_druid_isbird()
    if (GetShapeshiftForm(true) == 6) then
        return true;
    else
        return false;
    end
end

function btp_cb_druid_regrowth()
    --
    -- First we get the Casting and channel information about the player
    -- and use this to make sure the player is casting something.
    --
    cast_spell, cast_rank, cast_display_name, cast_icon, cast_start_time,
    cast_end_time, cast_is_trade_skill = UnitCastingInfo("player");

    --
    -- May just be beteen casts, so let it stand, otherwise we should
    -- clear the callback if it's not the spell we expect.
    --
    if (cast_spell == nil) then
        return false;
    elseif (cast_spell ~= "Regrowth") then
        --
        -- Well we are not casting our spell, so we can clear the callback.
        --
        current_cb = nil;
        return false;
    end

    --
    -- This is the second case where we clear the callback.  All the above
    -- code should stay the same; however, everything below this line will
    -- be very different based on the type of spell and what we expect to
    -- do with the callback.
    --

    --
    -- Regrowth check
    --
    hasRegrowth, myRegrowth,
    numRegrowth = btp_check_buff("ResistNature", current_cb_target);

    if ((myRegrowth and
         UnitHealth(current_cb_target)/UnitHealthMax(current_cb_target) >
         DR_THRESH) or UnitHealth(current_cb_target) < 2 or
       (((cast_start_time - GetTime()) <= 1) and
        UnitHealth(current_cb_target)/UnitHealthMax(current_cb_target) >
        DR_THRESH + DR_SCALAR/2)) then
        --
        -- We will use the IPT target box because we never use this,
        -- and we may get to do some back-to-back stop cast and cast
        -- something else action.  If this doesn't work well, then we
        -- should try to make this return true.
        --
        FuckBlizzardByNameStrange("stopcasting");
        current_cb = nil;
        return false;
    end

    return true;
end

function btp_cb_druid_healing_touch()
    --
    -- First we get the Casting and channel information about the player
    -- and use this to make sure the player is casting something.
    --
    cast_spell, cast_rank, cast_display_name, cast_icon, cast_start_time,
    cast_end_time, cast_is_trade_skill = UnitCastingInfo("player");

    --
    -- May just be beteen casts, so let it stand, otherwise we should
    -- clear the callback if it's not the spell we expect.
    --
    if (cast_spell == nil) then
        return false;
    elseif (cast_spell ~= "Healing Touch") then
        --
        -- Well we are not casting our spell, so we can clear the callback.
        --
        current_cb = nil;
        return false;
    end

    --
    -- This is the second case where we clear the callback.  All the above
    -- code should stay the same; however, everything below this line will
    -- be very different based on the type of spell and what we expect to
    -- do with the callback.
    --

    if (UnitHealth(current_cb_target) < 2 or
       (((cast_start_time - GetTime()) <= 1) and
        UnitHealth(current_cb_target)/UnitHealthMax(current_cb_target) >
        DR_THRESH + DR_SCALAR/2)) then
        --
        -- We will use the IPT target box because we never use this,
        -- and we may get to do some back-to-back stop cast and cast
        -- something else action.  If this doesn't work well, then we
        -- should try to make this return true.
        --
        FuckBlizzardByNameStrange("stopcasting");
        current_cb = nil;
        return false;
    end

    return true;
end

function btp_cb_druid_nourish()
    --
    -- First we get the Casting and channel information about the player
    -- and use this to make sure the player is casting something.
    --
    cast_spell, cast_rank, cast_display_name, cast_icon, cast_start_time,
    cast_end_time, cast_is_trade_skill = UnitCastingInfo("player");

    --
    -- May just be beteen casts, so let it stand, otherwise we should
    -- clear the callback if it's not the spell we expect.
    --
    if (cast_spell == nil) then
        return false;
    elseif (cast_spell ~= "Nourish") then
        --
        -- Well we are not casting our spell, so we can clear the callback.
        --
        current_cb = nil;
        return false;
    end

    --
    -- This is the second case where we clear the callback.  All the above
    -- code should stay the same; however, everything below this line will
    -- be very different based on the type of spell and what we expect to
    -- do with the callback.
    --

    if (UnitHealth(current_cb_target) < 2 or
       (((cast_start_time - GetTime()) <= 1) and
        UnitHealth(current_cb_target)/UnitHealthMax(current_cb_target) >
        DR_THRESH + DR_SCALAR/2)) then
        --
        -- We will use the IPT target box because we never use this,
        -- and we may get to do some back-to-back stop cast and cast
        -- something else action.  If this doesn't work well, then we
        -- should try to make this return true.
        --
        FuckBlizzardByNameStrange("stopcasting");
        current_cb = nil;
        return false;
    end

    return true;
end

function btp_cb_druid_tranquility()
    --
    -- First we get the Casting and channel information about the player
    -- and use this to make sure the player is casting something.
    --
    channel_spell, channel_rank, channel_display_name, channel_icon,
    channel_start_time, channel_end_time,
    channel_is_trade_skill = UnitChannelInfo("player");

    --
    -- Since channel works a bit different, we can clear the callback if nil.
    -- We also clear the callback if it's not the spell we expect.
    --
    if ((GetTime() - lastTranquility) <= 1) then
        return true;
    elseif (channel_spell == nil) then
        return false;
    elseif (channel_spell ~= "Tranquility") then
        --
        -- Well we are not casting our spell, so we can clear the callback.
        --
        current_cb = nil;
        return false;
    end

    --
    -- This is the second case where we clear the callback.  All the above
    -- code should stay the same; however, everything below this line will
    -- be very different based on the type of spell and what we expect to
    -- do with the callback.
    --

    --
    -- As it turns out, this is a great way to stop other spells from
    -- clobbering the current channel.  No timers or buff detection.
    --
    return true;
end
