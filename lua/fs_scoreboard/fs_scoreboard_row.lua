local PlayerRow = {}

local SCREEN_COEFFICIENT = ScrW()/1920;
if SCREEN_COEFFICIENT > 1 then SCREEN_COEFFICIENT = 1 end

function PlayerRow:Init()
    self.AvatarBTN = vgui.Create("DButton",self)
    self.AvatarBTN.DoClick = function() self.Player:ShowProfile() end
    self.AvatarIMG = vgui.Create("AvatarImage",self.AvatarBTN)
    self.AvatarIMG:SetMouseInputEnabled(false)
        self.Nick = vgui.Create("DLabel",self)
    self.Team = vgui.Create("DLabel",self)
    self.Route = vgui.Create("DLabel",self)
    self.Train = vgui.Create("DLabel",self)
    self.Station = vgui.Create("DLabel",self)
    self.Pax = vgui.Create("DLabel",self)
    self.Ping = vgui.Create("DLabel",self)
    self.MuteButton = vgui.Create("DImageButton", self)

end

function PlayerRow:GetCustomRouteName(ply)
    local routeName = ply:GetNW2String("RouteNumber","-")
    if Trolleybus_System and Trolleybus_System.Routes and
       Trolleybus_System.Routes.GetRouteName and routeName == tostring(tonumber(routeName))
       and tonumber(routeName) > 0 then
        return Trolleybus_System.Routes.GetRouteName(tonumber(routeName))
    end
    return routeName
end

function PlayerRow:GetPlatformName(ply)
    local P_N = "-"
    if Trolleybus_System and Trolleybus_System.GetLanguagePhrase and Trolleybus_System.GetLanguagePhraseName then
        if ply:GetNWBool("is_on_platform") then
            local v = ply:GetNWEntity("Platform")
            if IsValid(v) and v.GetStopName then
                local L = Trolleybus_System.GetLanguagePhrase
                local LN = Trolleybus_System.GetLanguagePhraseName
                P_N = L(LN("stop."..game.GetMap()..".",v:GetStopName()))
            end
        else
            P_N = ply:GetNWString("Platform")
        end
    end
    return P_N
end

function PlayerRow:Paint(w,h)
    if not IsValid(self.Player) then
        self:Remove()
        FSScoreBoard.Panel:InvalidateLayout()
        return
    end
    local color = Color(100,100,100,255)
    if IsValid(self.Player) then
        color = team.GetColor(self.Player:Team())
    end
    draw.RoundedBox(0,5*SCREEN_COEFFICIENT,5*SCREEN_COEFFICIENT,self:GetWide()-80,50*SCREEN_COEFFICIENT,Color(0,0,0,180))
    draw.RoundedBox(0,5*SCREEN_COEFFICIENT,5*SCREEN_COEFFICIENT,self:GetWide()-80,50*SCREEN_COEFFICIENT,Color(color.r,color.g,color.b,30))
    surface.SetDrawColor(255,255,255,150)
    surface.DrawOutlinedRect(5*SCREEN_COEFFICIENT,5*SCREEN_COEFFICIENT,self:GetWide()-80,45*SCREEN_COEFFICIENT,1)
end

function PlayerRow:PerformLayout()
    self.AvatarBTN:SetPos(6*SCREEN_COEFFICIENT,6*SCREEN_COEFFICIENT)
    self.AvatarBTN:SetSize(43*SCREEN_COEFFICIENT,43*SCREEN_COEFFICIENT)
    self.AvatarIMG:SetSize(43*SCREEN_COEFFICIENT,43*SCREEN_COEFFICIENT)
    self.Nick:SetPos(60*SCREEN_COEFFICIENT,20*SCREEN_COEFFICIENT)
    self.Team:SetPos(250*SCREEN_COEFFICIENT,20*SCREEN_COEFFICIENT)
    self.Route:SetPos(500*SCREEN_COEFFICIENT,20*SCREEN_COEFFICIENT)
    self.Train:SetPos(900*SCREEN_COEFFICIENT,20*SCREEN_COEFFICIENT)
    self.Station:SetPos(600*SCREEN_COEFFICIENT,20*SCREEN_COEFFICIENT)
    self.Pax:SetPos(1150*SCREEN_COEFFICIENT, 20*SCREEN_COEFFICIENT)
    self.Ping:SetPos(1200*SCREEN_COEFFICIENT, 20*SCREEN_COEFFICIENT)
    self.MuteButton:SetPos(1250*SCREEN_COEFFICIENT, 13*SCREEN_COEFFICIENT)

    self.MuteButton:SetSize(32*SCREEN_COEFFICIENT,32*SCREEN_COEFFICIENT)
    self.Nick:SetMouseInputEnabled(true)
    self.Nick:SetCursor("hand")
end

function PlayerRow:ApplySchemeSettings()
    self.Nick:SetFont("fsscoreboardmain")
    self.Team:SetFont("fsscoreboardmain")
    self.Route:SetFont("fsscoreboardmain")
    self.Train:SetFont("fsscoreboardmain")
    self.Station:SetFont("fsscoreboardmain")
    self.Pax:SetFont("fsscoreboardmain")
    self.Ping:SetFont("fsscoreboardmain")

end

function PlayerRow:UpdatePlayerData()
    local ply = self.Player
    local csrn = self:GetCustomRouteName(ply)
    if not IsValid(ply) then return end
    self.Nick:SetText(ply:Nick())
    self.Team:SetText(team.GetName(ply:Team()))
    self.Route:SetText( csrn and csrn or "-" )
    if ply:GetNW2String("TrolName","-") ~= "-" then
	self.Train:SetText(ply:GetNW2String("TrolName","-").."["..ply:GetNW2String("BortNum","-").."]")
    else
	self.Train:SetText(ply:GetNW2String("TrolName","-"))
    end
    self.Station:SetText(self:GetPlatformName(ply))
    self.Pax:SetText(ply:GetNW2String("PassCount","0"))
    self.Ping:SetText(ply:Ping())
    self.Nick:SizeToContents()
    self.Team:SizeToContents()
    self.Route:SizeToContents()
    self.Train:SizeToContents()
    self.Station:SizeToContents()
    self.Pax:SizeToContents()
    self.Ping:SizeToContents()

    if(ply:IsMuted()) then
        self.MuteButton:SetImage("icon32/muted.png")
    else
        self.MuteButton:SetImage("icon32/unmuted.png")
    end
    self.MuteButton.DoClick = function()
        ply:SetMuted(not ply:IsMuted())
    end
    function self.Nick:DoClick()
        if ply:SteamID() == LocalPlayer():SteamID() then return end
        RunConsoleCommand("ulx","goto",ply:Nick())
    end
    function self.Nick:DoRightClick()
       chat.AddText( Color( 100, 100, 255 ), ply:Nick().." ("..ply:SteamID()..") скопировано в буфер обмена") 
       SetClipboardText(ply:Nick().." ("..ply:SteamID()..")")
    end
    if(ply:GetNW2Bool("is_invisible", false)) then
        self:Remove()
    end
end

function PlayerRow:SetPlayer(ply)
    self.Player = ply
    self:UpdatePlayerData()
    self.AvatarIMG:SetPlayer(ply)
end

function PlayerRow:Think()
    if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
        self.PlayerUpdate = CurTime() + 1
        self:UpdatePlayerData()
    end
end

vgui.Register("fsplayerrow",PlayerRow,"DPanel")
