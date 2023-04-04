include("fs_scoreboard_row.lua")
if SERVER then
	util.AddNetworkString("HandleInvisibility")
end
local Panel = {}

local SCREEN_COEFFICIENT = ScrW()/1920;
if SCREEN_COEFFICIENT > 1 then SCREEN_COEFFICIENT = 1 end
local WIDTH = 1400*SCREEN_COEFFICIENT;
local HEIGHT = 900*SCREEN_COEFFICIENT;

surface.CreateFont( "fsscoreboardheader", {
	font = "Verdana",
	size = 62*SCREEN_COEFFICIENT,
	weight = 5
})
surface.CreateFont( "fsscoreboardsubheader", {
	font = "Verdana",
	size = 18*SCREEN_COEFFICIENT,
	weight = 5
})

surface.CreateFont("fsscoreboardmain",{
	font = "Verdana",
	size = 17*SCREEN_COEFFICIENT,
	weight = 5
})
surface.CreateFont("fsscoreboardmainheader",{
	font = "Verdana",
	size = 17*SCREEN_COEFFICIENT,
	weight = 25
})

local function checkInWL(ply)
	if(ply:IsAdmin()) then
		return true
	end
end

local function L18N(checkstr)
	local Lang = "en"
	if GetConVar('gmod_language'):GetString() == "ru" then Lang = "ru" end
	local Localization = {
		["urltitle"]={
			["ru"] = "Троллейбус FS (https://fsproject.ru). Загружена карта: ",
			["en"] = "Trolleybus FS (https://fsproject.ru). Current map: "
		},
		["nick"]={
			["ru"] = "Ник",
			["en"] = "Nick"
		},
		["position"]={
			["ru"] = "Должность",
			["en"] = "Postion"
		},
		["route"]={
			["ru"] = "Маршрут",
			["en"] = "Route"
		},
		["place"]={
			["ru"] = "Местоположение",
			["en"] = "Place"
		},
		["trolleybus"]={
			["ru"] = "Троллейбус",
			["en"] = "Trolleybus"
		},
		["pax"]={
			["ru"] = "Пасс.",
			["en"] = "Pax"
		},
		["ping"]={
			["ru"] = "Пинг",
			["en"] = "Ping"
		}
	}
	if Localization[checkstr] then
		return Localization[checkstr][Lang]
	end
	return str
end


function Panel:Init()
	self.Hostname = vgui.Create( "DLabel", self )
	self.Hostname:SetText( GetHostName() )
	self.URL = vgui.Create( "DLabel", self )
	self.URL:SetText(L18N('urltitle')..game.GetMap())
	self.MuteAllButton = vgui.Create( "DImageButton", self)
	self.MuteAllButton:SetImage( "icon32/muted.png")
	self.UnMuteAllButton = vgui.Create( "DImageButton", self)
	self.UnMuteAllButton:SetImage( "icon32/unmuted.png")
	if(checkInWL(LocalPlayer())) then
		self.InvisButton = vgui.Create("DImageButton", self)
		self.InvisButton:SetImage("icon32/wand.png")
	end
	self.PlayerRows = {}
	self.Frame = vgui.Create("fsplayersframe",self)
	self.HeaderRow = vgui.Create("fsheaders", self.Frame)
	self.MuteAllButton.DoClick = function()
		for _,ply in pairs(player.GetAll()) do
			if IsValid(ply) then
				ply:SetMuted(true);
			end
		end
	end
	self.UnMuteAllButton.DoClick = function()
		for _,ply in pairs(player.GetAll()) do
			if IsValid(ply) then
				ply:SetMuted(false);
			end
		end
	end
	if(checkInWL(LocalPlayer())) then
		self.InvisButton.DoClick = function ()
			net.Start("HandleInvisibility")
			net.SendToServer()
		end
		end
	end
	function Panel:Paint(w,h)
		--Заголовок
		draw.RoundedBox(0,10,10,self:GetWide(), 120 , Color(0,0,0,230))
		surface.SetDrawColor( 255, 255, 255, 128 )
		surface.DrawOutlinedRect( 10, 10, self:GetWide() - 10, 120, 1)

		--Левое меню
		draw.RoundedBox(0,10,140,50, self:GetTall()-140 , Color(0,0,0,230))
		surface.SetDrawColor( 255, 255, 255, 128 )
		surface.DrawOutlinedRect( 10, 140, 50, self:GetTall()-140, 1)

	end
	function Panel:PerformLayout()
	self:SetSize(WIDTH,HEIGHT)
	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)
	self.Hostname:SizeToContents()
	self.Hostname:SetPos( 30, 25 )
	self.URL:SizeToContents()
	self.URL:SetPos( 30, 95 )
	self.MuteAllButton:SetSize(30,30)
	self.MuteAllButton:SetPos(20,150)
	self.UnMuteAllButton:SetSize(30,30)
	self.UnMuteAllButton:SetPos(20,190)
	if(checkInWL(LocalPlayer())) then
		self.InvisButton:SetSize(30,30)
		self.InvisButton:SetPos(20, 220)
	end
	self.Frame:SetPos(70,140)
	self.Frame:SetSize(self:GetWide() - 70, self:GetTall() - 140)

	end
	function Panel:ApplySchemeSettings()
		self.Hostname:SetFont( "fsscoreboardheader" )
		self.URL:SetFont( "fsscoreboardsubheader" )
	end

	function Panel:AddPlayerRow(ply)
		local row = vgui.Create("fsplayerrow",self.Frame)
		row:SetPlayer(ply)
		row:SetCursor("user")
		self.Frame.ScrollPanel:AddItem(row)
		row:Dock(TOP)
		row:DockMargin(2,2,2,0)
		row:SetSize(self.Frame:GetWide(),50*SCREEN_COEFFICIENT)
		self.PlayerRows[ply] = row
	end

	function Panel:GetPlayerRow(ply)
		return self.PlayerRows[ply]
	end

	function Panel:Update()
		if not self or not self:IsVisible() then return end
		self.Frame.ScrollPanel:AddItem(self.HeaderRow)
		self.HeaderRow:Dock(TOP)
		local PlayerList = player.GetAll()
		table.sort(PlayerList,function(a,b)
			if a:Team() == TEAM_CONNECTING then return false end
			if b:Team() == TEAM_CONNECTING then return true end
			if a:Team() ~= b:Team() then
				return a:Team() < b:Team()
			end
		end)

		for _,ply in pairs(PlayerList) do
			if self:GetPlayerRow(ply) and ply:GetNW2Bool("is_invisible", false) then
				self.PlayerRows[ply] = false;
			end
			if not self:GetPlayerRow(ply) and not ply:GetNW2Bool("is_invisible", false) then
				self:AddPlayerRow(ply)
			end
		end
		self:InvalidateLayout()
	end

	vgui.Register("FSScoreBoard",Panel,"Panel")

	timer.Create("FSScoreBoardThink",0.6,0,function()
		if FSScoreBoard.Panel then
			FSScoreBoard.Panel:Update()
		end
	end)

	-- ФРЕЙМ ИГРОКОВ --
	local Frame = {}

	function Frame:Init()
		self.ScrollPanel = vgui.Create("DScrollPanel",self)
	end

	function Frame:Paint(w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,230))
		surface.SetDrawColor( 255, 255, 255, 128 )
		surface.DrawOutlinedRect( 0, 0, w-70,h, 1)
	end

	function Frame:PerformLayout()
		self:SetSize(self:GetParent():GetWide(),self:GetTall())
		self.ScrollPanel:Dock(FILL)
		local ScrollBar = self.ScrollPanel:GetVBar()
		ScrollBar:SetSize(0,0)
	end
	vgui.Register("fsplayersframe",Frame,"Panel")

	--Панель с заголовками таблицы
	local HeaderRow = {}
	function HeaderRow:Init()
		self.NickLabel = vgui.Create("DLabel",self)
		self.NickLabel:SetText(L18N("nick"))
		self.TeamLabel = vgui.Create("DLabel",self)
		self.TeamLabel:SetText(L18N("position"))
		self.RouteLabel = vgui.Create("DLabel",self)
		self.RouteLabel:SetText(L18N("route"))
		self.TrainLabel = vgui.Create("DLabel",self)
		self.TrainLabel:SetText(L18N("trolleybus"))
		self.StationLabel = vgui.Create("DLabel",self)
		self.StationLabel:SetText(L18N("place"))
		self.PaxLabel = vgui.Create("DLabel",self)
		self.PaxLabel:SetText(L18N("pax"))
		self.PingLabel = vgui.Create("DLabel",self)
		self.PingLabel:SetText(L18N("ping"))
	end
	function HeaderRow:Paint(w,h)
		surface.SetDrawColor( 255, 255, 255, 128 )
		surface.DrawOutlinedRect( 8*SCREEN_COEFFICIENT, 5*SCREEN_COEFFICIENT, w-85*SCREEN_COEFFICIENT,h-5, 1)
	end
	function HeaderRow:PerformLayout()
		self:SetSize(self:GetParent():GetWide(),40)
		self.NickLabel:SetPos(60*SCREEN_COEFFICIENT,15*SCREEN_COEFFICIENT)
		self.TeamLabel:SetPos(250*SCREEN_COEFFICIENT,15*SCREEN_COEFFICIENT)
		self.RouteLabel:SetPos(500*SCREEN_COEFFICIENT,15*SCREEN_COEFFICIENT)
		self.StationLabel:SetPos(600*SCREEN_COEFFICIENT,15*SCREEN_COEFFICIENT)
		self.TrainLabel:SetPos(900*SCREEN_COEFFICIENT,15*SCREEN_COEFFICIENT)
		self.PaxLabel:SetPos(1150*SCREEN_COEFFICIENT, 15*SCREEN_COEFFICIENT)
		self.PingLabel:SetPos(1200*SCREEN_COEFFICIENT, 15*SCREEN_COEFFICIENT)

		self.NickLabel:SizeToContents()
		self.TeamLabel:SizeToContents()
		self.RouteLabel:SizeToContents()
		self.TrainLabel:SizeToContents()
		self.StationLabel:SizeToContents()
		self.PaxLabel:SizeToContents()
		self.PingLabel:SizeToContents()

		self.NickLabel:SetFont("fsscoreboardmainheader")
		self.TeamLabel:SetFont("fsscoreboardmainheader")
		self.RouteLabel:SetFont("fsscoreboardmainheader")
		self.TrainLabel:SetFont("fsscoreboardmainheader")
		self.StationLabel:SetFont("fsscoreboardmainheader")
		self.PaxLabel:SetFont("fsscoreboardmainheader")
		self.PingLabel:SetFont("fsscoreboardmainheader")

		self.NickLabel:SetTextColor(Color(255,255,0,255))
		self.TeamLabel:SetTextColor(Color(255,255,0,255))
		self.RouteLabel:SetTextColor(Color(255,255,0,255))
		self.TrainLabel:SetTextColor(Color(255,255,0,255))
		self.StationLabel:SetTextColor(Color(255,255,0,255))
		self.PaxLabel:SetTextColor(Color(255,255,0,255))
		self.PingLabel:SetTextColor(Color(255,255,0,255))

	end
	vgui.Register("fsheaders",HeaderRow,"Panel")

	-- Глобальные функции
	function FSScoreBoard:Show()
		if FSScoreBoard.Panel then
			FSScoreBoard.Panel:Remove()
			FSScoreBoard.Panel = nil
		end
		FSScoreBoard.Panel = vgui.Create("FSScoreBoard")
		FSScoreBoard.Panel:Update()
		gui.EnableScreenClicker(true)
	end
	function FSScoreBoard:Hide()
		FSScoreBoard.Panel:Remove()
		FSScoreBoard.Panel = nil
		gui.EnableScreenClicker(false)
	end