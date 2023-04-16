--------------------------------------------------------------------
-- Lambda Players Culling | A simple script to save resources.
-- -----------------------------------------------------------------
-- Similar to how the Director culls Infected from Left 4 Dead
-- or any game that that culls npcs, is to save performance
-- Why have LambdaPlayers far from the player, outside their PVS
-- and can't watch/witness their glory AI in motion, instead
-- putting stain and stress onto your not so Elon Musk SpaceX super 
-- computer, to render a LambdaPlayer thats far, far away from you.
-- Insteading of crying, let's cull our hateful LambdaPlayer that
-- doesn't want anything to do with you, if it's not close to you
-- again, why waste your system resources, render something that
-- you cannot see? THIS IS MADNESS, MADNESS AT BEST. FOR I CREATED
-- TO SAVE YOUR SANITY, AND BRING CIVILIZATION BACK TO OUR GMOD SANDBOX
-- SERVERS! Alright, enough of that corny crap, let's get a move on.
-- -----------------------------------------------------------------
-- P.S; "Cull" means to remove.
--------------------------------------------------------------------
local ipairs = ipairs
local pairs = pairs
local IsValid = IsValid
local isCullingEnabled = GetConVar( "lambdaplayers_cull_enable" )

-- Checking for Lambda Players
local function isLambdaPlayer(ent)
    return ent:IsNextBot() and ent:GetClass() == "npc_lambdaplayer"
end

-- Check for the distance between the Players and Lamabda Players
local function isFarFromPlayer(ent, distance)
    for _, ply in pairs(player.GetAll()) do
        if ent:GetPos():DistToSqr( ply:GetPos() ) <= distance^2 then
            return false
        end
    end

    return true
end

-- Uh, if there's another way, instead of using a think hook,
-- I'm open to better ideas
hook.Add("Think", "RemoveFarLambda", function()
    if not isCullingEnabled then return end

    local lambdaPlayers = {}
    local cullDistance = GetConVar( "lambdaplayers_cull_distance" ):GetInt()

    for _, ent in pairs(ents.GetAll()) do
        if isLambdaPlayer( ent ) then
            lambdaPlayers[ #lambdaPlayers + 1 ] = ent
        end
    end

	if SERVER then -- Call this on ServerSide
		for _, lambda in pairs( lambdaPlayers ) do -- Search for all Lambda Players.
			if IsValid( lambda ) and isFarFromPlayer( lambda, cullDistance ) then
				lambda:Remove() -- Remove them
			end
		end
	end
end)

CreateConVar("lambdaplayers_cull_distance", "3000", FCVAR_ARCHIVE, "If the LambdaPlayer's distance is far away from any player with the value set, the lambdaplayer will be culled.", 400, 10000)
CreateConVar("lambdaplayers_cull_enable", "1", FCVAR_ARCHIVE, "If LambdaPlayers should be culled.")

if CLIENT then
    hook.Add("PopulateToolMenu", "LambdaPlayerCullOptions", function()
        spawnmenu.AddToolMenuOption( "Lambda Player", "Pyri's Lambda Collection", "lambdaplayers_culling", "Culling", "", "", function( Panel )

            if not game.SinglePlayer() and not LocalPlayer():IsAdmin() then
                Panel:AddControl( "Label", { Text = "Notice: Only admins can use this menu." } )
                Panel:AddControl( "Label", { Text = "You cannot change anything, you're not an admin." } )
                return
            end

            Panel:AddControl( "Header", {Description = "Culling will remove any LambdaPlayer that is far from any player. This will save on performance." } )
            Panel:AddControl( "Button", { Label = "Reset to Defaults", Command = "lambdaplayers_cull_reset_defaults", Description = "Reset the culling distance to the default (recommended) values.", Text = "Reset to Defaults", Function = function() RunConsoleCommand("lambdaplayers_cull_distance", "3000") RunConsoleCommand("lambdaplayers_cull_interval", "5") end } )

            Panel:CheckBox( "Enable Culling?","lambdaplayers_cull_enable" )
            Panel:AddControl( "Slider", { Label = "Culling Distance", Command = "lambdaplayers_cull_distance", Min = "1000", Max = "10000" } )
			Panel:ControlHelp( "If the distance between a Lambda Player and any player exceeds the value set, the Lambd aPlayer will be removed to improve performance." )

        end)
    end)

    concommand.Add("lambdaplayers_cull_reset_defaults", function()
        RunConsoleCommand("lambdaplayers_cull_distance", "3000")
    end)
    
end