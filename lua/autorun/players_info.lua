if SERVER then
        local function GetPlatform(trol)
            for k,v in ipairs(ents.FindByClass("trolleybus_stop")) do
                if v:IsTrolleybusInBounds(trol) then
                   return v
                end
            end
            return nil
        end
        local function GetTrol(ply)
            if Trolleybus_System.PlayerInDriverPlace(nil,ply) then
				return Trolleybus_System.GetSeatTrolleybus(ply:GetVehicle())
            end
            return nil
        end
	-- Обновление информации игроков
	local PlayerList = {}
	timer.Create("UpdatePlayersInfo",3,0, function()
		PlayerList = player.GetAll()
		for k, v in pairs(PlayerList) do
		    local trol = GetTrol(v)
                    if IsValid(trol) then
						v:SetNW2String("TrolName", trol.PrintName)
						v:SetNW2String("RouteNumber", trol:GetRouteNum())
						v:SetNW2String("PassCount", trol:GetPassCount())
						v:SetNW2String("BortNum", trol:GetBortNumber())
                        local platform = GetPlatform(trol)
                        if IsValid(platform) then
                            v:SetNWBool("is_on_platform", true)
                            v:SetNWEntity("Platform", platform)
                        else
                            v:SetNWBool("is_on_platform", false)
                            v:SetNWString("Platform", "-")
                        end
                    else
                        v:SetNW2String("RouteNumber", "-")
                        v:SetNW2String("TrolName", "-")
                        v:SetNWBool("is_on_platform", false)
                        v:SetNWString("Platform", "-")
						v:SetNW2String("PassCount", "0")
                    end
                    trol = nil
		end
	end)
       	util.AddNetworkString("HandleInvisibility")
	net.Receive( "HandleInvisibility", function(len, ply)
	    local is_invis = ply:GetNW2Bool("is_invisible", false)
		if(is_invis) then
			ulx.fancyLogAdmin(ply, true, "#A вернул своё отображение в TAB")	
			--набор фейковых сообщений о подключении
			hook.Run("player_connect", {bot=0,networkid=ply:SteamID(),name=ply:Nick(),userid=ply:UserID(),index=ply:EntIndex(),address=ply:IPAddress()})
			timer.Simple(10, function()
					hook.Run("PlayerInitialSpawnFake",ply)
				    timer.Simple(10, function()
					    hook.Run("PlayerLoaded",ply)
						ply:SetNW2Bool("is_invisible", false)
				    end)
			end)
		else
			ulx.fancyLogAdmin(ply, true, "#A скрыл своё отображение в TAB")	
			-- фейковое сообщение о выходе
			hook.Run("player_disconnect", {bot=0,networkid=ply:SteamID(),name=ply:Nick(),userid=ply:UserID(),index=ply:EntIndex(), reason="Disconnected by user"})
			ply:SetNW2Bool("is_invisible", true)
			ulx.cloak( ply, {ply}, 255, false )
		end
	end )
end