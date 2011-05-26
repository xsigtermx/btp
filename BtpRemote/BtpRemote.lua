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

function out(text)
 DEFAULT_CHAT_FRAME:AddMessage(text)
 UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10) 
end


function BtpRemote_OnLoad()
  -- out("BtpRemote: OnLoad");
  SLASH_BtpRemote1 = "/btpremote";
  SLASH_BtpRemote2 = "/btpr";
  SlashCmdList["BtpRemote"] = function(msg)
		BtpRemote_SlashCommandHandler(msg);
	end
end


function BtpRemote_OnEvent(event, arg1, arg2, arg3, arg4)
	if (event == "CHAT_MSG_ADDON" ) then
		message = arg2;
		sender = arg4;
	end
	if (event == "CHAT_MSG_WHISPER" ) then
		message = arg1;
		sender = arg2;
	end
	if (sender == BtpR_Name) then
		if (string.find(message, 'in PVP follow mode')) then
			BtpRemote_PVPButton:LockHighlight();
		end
		if ((string.find(message, 'in non')) or (string.find(message, 'in guild follow mode'))) then
			BtpRemote_PVPButton:UnlockHighlight();
			BtpRemote_FollowButton:UnlockHighlight();
		end
		if ((string.find(message, 'now following')) or (string.find(message, 'tagged to'))) then
			BtpRemote_FollowButton:LockHighlight();
		end
		if (string.find(message, 'tagged to no one')) then
			BtpRemote_FollowButton:UnlockHighlight();
		end

		-- You might want to disable this?
		if (string.find(message, 'Send me an invite')) then
			InviteUnit(BtpR_Name);
		end

		local frame = getglobal("BtpRemotePanel");
		BtpRemotePanel_ReplyText:SetText(message);
	end
end

function BtpRemote_OnClick(arg1)
   id = this:GetID();
   local BtpR_Command = { };
   BtpR_Command[1] = "btpstart";
   BtpR_Command[2] = "btpstop";
   BtpR_Command[3] = "btpforward";
   BtpR_Command[4] = "btpdrink";
   if (UnitName("target") ~= nil) then
	   BtpR_Command[5] = "btpfollow ".. UnitName("target");
   else
	   BtpR_Command[5] = "btpfollow ".. UnitName("player");
   end
   BtpR_Command[6] = "btppvp";
   
   -- THIS SHOULD BE CHANGED TO USE SendAddonMessage INSTEAD
   SendChatMessage(BtpR_Command[id], "WHISPER", nil, BtpR_Name);
   -- out("BtpRemote: Command: " .. BtpR_Command[id] .. " ,ID: " .. id .. " ,Button:" ..arg1 ..", Name: "..BtpR_Name)
end


function BtpRemote_SlashCommandHandler(msg)
    -- out("BtpRemote: " .. msg)
	if (msg == "0") then
	 ReloadUI();
	end
 	BtpRemote_Toggle(msg);
end


function BtpRemote_Toggle(name)
   BtpR_Name = name;
   local frame = getglobal("BtpRemotePanel")
   if (frame) then
   if(  frame:IsVisible() ) then
      frame:Hide();
   else
      frame:Show();
      BtpRemotePanel_Text:SetText(name);
      BtpRemotePanel_ReplyText:SetText("[replies and status messages go here]");
      SendChatMessage("btpstatus", "WHISPER", nil, BtpR_Name);
   end
   end
end
