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

-- Check for the distance between the Players and Lambda Players
local function isFarFromPlayer(ent, distance)
    for _, ply in pairs(player.GetAll()) do
        if ent:GetPos():DistToSqr( ply:GetPos() ) <= distance^2 then
            return false
        end
    end

    return true
end

-- Function to remove Lambda Players that are far from any player
local function RemoveFarLambda()
    if not isCullingEnabled:GetBool() then return end

    local LambdaPlayerTable = {}
    local cullDistance = GetConVar( "lambdaplayers_cull_distance" ):GetInt()

    for _, ent in pairs(ents.GetAll()) do
        if isLambdaPlayer( ent ) then
            LambdaPlayerTable[ #LambdaPlayerTable + 1 ] = ent
        end
    end

    if SERVER then
        for _, lambda in pairs( LambdaPlayerTable ) do -- Search for all Lambda Players.
            if IsValid( lambda ) and isFarFromPlayer( lambda, cullDistance ) then
                lambda:Remove() -- Remove them
            end
        end
    end
end

-- Set up a timer to periodically check and remove Lambda Players
timer.Create("RemoveFarLambdaTimer", 5, 0, RemoveFarLambda)


CreateConVar("lambdaplayers_cull_distance", "2000", FCVAR_ARCHIVE, "If the LambdaPlayer's distance is far away from any player with the value set, the lambdaplayer will be culled. 1600-2000, 2400-3000 recommended.", 400, 10000)
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
            Panel:AddControl( "Button", { Label = "Reset to Defaults", Command = "lambdaplayers_cull_reset_defaults", Description = "Reset the culling distance to the default (recommended) values.", Text = "Reset to Defaults", Function = function() RunConsoleCommand("lambdaplayers_cull_distance", "3000") end } )

            Panel:CheckBox( "Enable Culling?","lambdaplayers_cull_enable" )
            Panel:AddControl( "Slider", { Label = "Culling Distance", Command = "lambdaplayers_cull_distance", Min = "400", Max = "10000" } )
			Panel:ControlHelp( "If the distance between a Lambda Player and any player exceeds the value set, the LambdaPlayer will be removed to improve performance.\n\nRecommended Values:\n\n 1500, 1600, 1800, 2000, 2400, 3000" )

        end)
    end)

    concommand.Add("lambdaplayers_cull_reset_defaults", function()
        RunConsoleCommand("lambdaplayers_cull_distance", "3000")
    end)

end