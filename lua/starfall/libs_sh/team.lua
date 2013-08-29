-- -------------------------- Team functions ------------------------ --

--- Team Library
-- @shared
local teams_lib, _ = SF.Libraries.Register("team")

--- Get team name
-- @param teamID Team ID
-- @return Team name
function teams_lib.name(teamID)
	SF.CheckType(teamID, "number")
	local str = team.GetName(teamID)
	if str == nil then return "" end
	return str
end

--- Get team score
-- @param teamID Team ID
-- @return Team score
function teams_lib.score(teamID)
	SF.CheckType(teamID, "number")
	return team.GetScore(teamID)
end

--- Get number of players in team
-- @param teamID Team ID
-- @return Team number of players
function teams_lib.players(teamID)
	SF.CheckType(teamID, "number")
	return team.NumPlayers(teamID)
end

--- Get total team deaths
-- @param teamID Team ID
-- @return Team deaths
function teams_lib.deaths(teamID)
	SF.CheckType(teamID, "number")
	return team.TotalDeaths(teamID)
end

--- Get total team frags
-- @param teamID Team ID
-- @return Team frags
function teams_lib.frags(teamID)
	SF.CheckType(teamID, "number")
	return team.TotalFrags(teamID)
end

--- Get team color
-- @param teamID Team ID
-- @return r,g,b team color
function teams_lib.color(teamID)
	SF.CheckType(teamID, "number")
	local col = team.GetColor(teamID)
	return col.r, col.g, col.b
end

--- Get all teams ID
-- @return Teams ID array
function teams_lib.allTeams()
	local team_indexes = {}
	for index,_ in pairs(team.GetAllTeams()) do
		team_indexes[#team_indexes+1] = index
	end
	table.sort(team_indexes)
	return team_indexes
end
