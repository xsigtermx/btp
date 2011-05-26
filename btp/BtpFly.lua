--[[
	BtpFly
	Originally By Torgo <-- talk to that guy, we didn't.
		
   ]]

function BtpFly_OnEvent(event, arg1, arg2)
	if (event == "GOSSIP_SHOW" ) then
		BtpFly_Gossip_Show();
	end
	if (event == "TAXIMAP_OPENED" ) then
		BtpFly_Taximap_Opened();
	end
	if (event == "MERCHANT_SHOW" ) then
		BtpFly_Merchant_Show();
	end
	if (event == "BATTLEFIELDS_SHOW" ) then
		-- *** JOIN FIRST AVAILABLE
		JoinBattlefield(0);
	end
	if (event == "CURSOR_UPDATE") then
		BtpFly_CursorUpdate();
	end
end

function BtpFly_Gossip_Show()
	title1, gossip1 = GetGossipOptions();
	if (gossip1 == "taxi" or gossip1 == "battlemaster") then
	    SelectGossipOption(1);
	end
end

function BtpFly_CursorUpdate()
	if (UnitIsFriend("player","mouseover") and
           (not UnitPlayerControlled("mouseover")) and
            CheckInteractDistance("mouseover", 2)) then
		-- *** RIGHT-CLICK IT! 
	end;
end

function BtpFly_Taximap_Opened()
        hasFlightFrom = false;
        hasSwiftFlightFrom = false;

        local i = 1
        while true do
           local spellName, spellRank = GetSpellBookItemName(i, BOOKTYPE_SPELL);
           if not spellName then
              do break end
           end
       
           if (strfind(spellName, "Swift Flight Form")) then
               hasSwiftFlightFrom = true;
           end
       
           if (strfind(spellName, "Flight Form")) then
               hasFlightFrom = true;
           end
       
           i = i + 1
        end

	-- *** IF THE VAR BELOW IS SET THEN THE CODE WILL ATTEMPT TO FLY THERE
	-- *** I'VE GOT IT TEMPORARILY HARDCODED FOR DEBUGGING
	-- FlightDestination = "Shat";

	Dismount();

        if (btp_druid_isbird()) then
            if (hasSwiftFlightFrom) then
                FuckBlizzardByName("Swift Flight Form");
            elseif (hasFlightFrom) then
                FuckBlizzardByName("Flight Form");
            end
        end

	if (FlightDestination ~= nil) then
		local numButtons = NumTaxiNodes();
		TaxiDestination = "";

		for i = 1, numButtons, 1 do
			if(TaxiNodeGetType(i) == "CURRENT") then
				TaxiOrigin = TaxiNodeName(i);
		end
		
			if((TaxiNodeGetType(i) == "REACHABLE") and
                          (string.find(TaxiNodeName(i),FlightDestination))) then
				TaxiDestination = TaxiNodeName(i);
				TaxiDestinationNode = i;
			end
		end	
	
		if (TaxiDestination ~= "") then
			TakeTaxiNode(TaxiDestinationNode);
			if (GetNumPartyMembers() > 0) then
				SendChatMessage("Flying from " .. TaxiOrigin ..
                                                " to " .. TaxiDestination,
                                                "Party");
			end		
			FlightDestination = nil;
		end	
	end
end

function BtpFly_Merchant_Show()
	AutoRepair = 1;
	if (CanMerchantRepair() and AutoRepair) then
		repairAllCost, canRepair = GetRepairAllCost()
		if (canRepair) then
			RepairAllItems();
			if (GetNumPartyMembers() > 0) then
				SendChatMessage("Repaired all items for " ..
                                                (repairAllCost/10000) .. 
                                                " gold", "Party");
			end		
		else
			if (GetNumPartyMembers() > 0) then
				SendChatMessage("Repairs not needed.", "Party");
			end		
		end
	end
end
