--[[
   Copyright 2007-2021 The OpenRA Developers (see AUTHORS)
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

Seconds = 0
CPModifier = Map.LobbyOption("cpmodifier")

if CPModifier == "one" then
	PointsPerRank = { 1, 1, 1, 1, 1 }
elseif CPModifier == "normal" then
	PointsPerRank = { 1, 1, 1, 1, 3 }
elseif CPModifier == "two" then
	PointsPerRank = { 2, 2, 2, 2, 2 }
elseif CPModifier == "double" then
	PointsPerRank = { 2, 2, 2, 2, 6 }
elseif CPModifier == "three" then
	PointsPerRank = { 3, 3, 3, 3, 3 }
elseif CPModifier == "triple" then
	PointsPerRank = { 3, 3, 3, 3, 5 }
else
	PointsPerRank = { 4, 0, 11, 0, 2 }
end

PointActorExists = { }
Points = { }
HasPointsActors =  { }
Levels = { }
TextColors ={ }

Ranks =
{
	america = { "中尉", "上尉", "少校", "上校", "将军" },
	england = { "中尉", "上尉", "少校", "上校", "将军" },
	france = { "中尉", "上尉", "少校", "上校", "将军" },
	germany = { "中尉", "上尉", "少校", "上校", "将军" },
	korea = { "中尉", "上尉", "少校", "上校", "将军" },
	japan = { "中尉", "上尉", "少校", "上校", "将军" },
	belarus = { "中尉", "上尉", "少校", "上校", "将军" },
	poland = { "中尉", "上尉", "少校", "上校", "将军" },
	ukraine = { "中尉", "上尉", "少校", "上校", "将军" },
	aussie = { "中尉", "上尉", "少校", "上校", "将军" },
	china = { "中尉", "上尉", "少校", "上校", "将军" },
	turkey = { "中尉", "上尉", "少校", "上校", "将军" },
	canada = { "中尉", "上尉", "少校", "上校", "将军" },
	russia = { "中尉", "上尉", "少校", "上校", "将军" },
	iraq = { "中尉", "上尉", "少校", "上校", "将军" },
	vietnam = { "中尉", "上尉", "少校", "上校", "将军" },
	cuba = { "中尉", "上尉", "少校", "上校", "将军" },
	libya = { "中尉", "上尉", "少校", "上校", "将军" },
	chile = { "中尉", "上尉", "少校", "上校", "将军" },
	mexico = { "中尉", "上尉", "少校", "上校", "将军" },
	mongolia = { "中尉", "上尉", "少校", "上校", "将军" },
	psicorps = { "使徒", "执事", "司铎", "主教", "枢机主教" },
	psinepal = { "使徒", "执事", "司铎", "主教", "枢机主教" },
	psitrans = { "使徒", "执事", "司铎", "主教", "枢机主教" },
	psisouth = { "使徒", "执事", "司铎", "主教", "枢机主教" },
	psimoon = { "使徒", "执事", "司铎", "主教", "枢机主教" },
}
RankXPs = { 0, 300, 1300, 2500, 5000 }

ReducePoints = function(player)
	Trigger.OnProduction(player.GetActorsByType("player")[1], function(_, actor)
		if Points[player.InternalName] > 0 and Actor.Cost(actor.Type) == 0 then
			Points[player.InternalName] = Points[player.InternalName] - 1
		end
	end)
end

TickCommandersPowers = function()
	local localPlayerIsNull = true
	for _,player in pairs(players) do
		if player.IsLocalPlayer then
			localPlayerIsNull = false
			if Levels[player.InternalName] < 4 then
				CommandersPowerText = "您的军衔: " .. Ranks[player.Faction][Levels[player.InternalName] + 1] .. "\n指挥官点数: " .. Points[player.InternalName] .. "\n晋升进度: " .. player.Experience - RankXPs[Levels[player.InternalName] + 1] .. "/" .. RankXPs[Levels[player.InternalName] + 2] - RankXPs[Levels[player.InternalName] + 1] .. "\n\n"
			else
				CommandersPowerText = "您的军衔: " .. Ranks[player.Faction][Levels[player.InternalName] + 1] .. "\n指挥官点数: " .. Points[player.InternalName] .. "\n\n"
			end
			UserInterface.SetMissionText(CommandersPowerText .. DominationText .. KotHText, TextColors[player.InternalName])
		end

		if localPlayerIsNull then
			CommandersPowerText = ""
			UserInterface.SetMissionText(CommandersPowerText .. DominationText .. KotHText)
		end

		if Points[player.InternalName] > 0 and not PointActorExists[player.InternalName] then
			HasPointsActors[player.InternalName] = Actor.Create("hack.has_points", true, { Owner = player })

			PointActorExists[player.InternalName] = true
		end

		if not (Points[player.InternalName] > 0) and PointActorExists[player.InternalName] and HasPointsActors[player.InternalName] ~= nil then
			HasPointsActors[player.InternalName].Destroy()

			PointActorExists[player.InternalName] = false
		end

		if player.Experience >= RankXPs[2] and not (Levels[player.InternalName] > 0) then
			Levels[player.InternalName] = Levels[player.InternalName] + 1
			Points[player.InternalName] = Points[player.InternalName] + PointsPerRank[2]

			Media.PlaySpeechNotification(player, "YouHavePromoted")
		end

		if player.Experience >= RankXPs[3] and not (Levels[player.InternalName] > 1) then
			Levels[player.InternalName] = Levels[player.InternalName] + 1
			Points[player.InternalName] = Points[player.InternalName] + PointsPerRank[3]

			Media.PlaySpeechNotification(player, "YouHavePromoted")
			Actor.Create("hack.rank_3", true, { Owner = player })
		end

		if player.Experience >= RankXPs[4] and not (Levels[player.InternalName] > 2) then
			Levels[player.InternalName] = Levels[player.InternalName] + 1
			Points[player.InternalName] = Points[player.InternalName] + PointsPerRank[4]

			Media.PlaySpeechNotification(player, "YouHavePromoted")
		end

		if player.Experience >= RankXPs[5] and not (Levels[player.InternalName] > 3) then
			Levels[player.InternalName] = Levels[player.InternalName] + 1
			Points[player.InternalName] = Points[player.InternalName] + PointsPerRank[5]

			Media.PlaySpeechNotification(player, "YouHavePromoted")
			Actor.Create("hack.rank_5", true, { Owner = player })
		end
	end
end

Second = function()
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Seconds = Seconds + 1

		for _,player in pairs(players) do
			if Points[player.InternalName] > 0 and Seconds % 2 == 0 then
				TextColors[player.InternalName] = HSLColor.White
			else
				TextColors[player.InternalName] = player.Color
			end
		end

		Second()
	end)
end

SetUpDefaults = function()
	for _,player in pairs(players) do
		PointActorExists[player.InternalName] = false
		Points[player.InternalName] = PointsPerRank[1]
		HasPointsActors[player.InternalName] = nil
		Levels[player.InternalName] = 0
		TextColors[player.InternalName] = HSLColor.White
	end
end

WorldLoadedCommandersPowers = function()
	players = Player.GetPlayers(function(p) return not p.IsNonCombatant end)
	SetUpDefaults()

	if CPModifier ~= "disabled" then
		for _,player in pairs(players) do
			ReducePoints(player)
		end

		Second()
	end
end

                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          
                                                                                                                                                          