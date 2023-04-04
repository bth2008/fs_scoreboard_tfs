FSScoreBoard = FSScoreBoard or {}

if SERVER then
	AddCSLuaFile("fs_scoreboard/fs_scoreboard.lua")
	AddCSLuaFile("fs_scoreboard/fs_scoreboard_row.lua")
else
	include("fs_scoreboard/fs_scoreboard.lua")
end

hook.Add("PostGamemodeLoaded", "FSScoreboardLoader", function()
	function GAMEMODE:ScoreboardShow()
		FSScoreBoard:Show()
	end
	function GAMEMODE:ScoreboardHide()
		FSScoreBoard:Hide()
	end
end)
