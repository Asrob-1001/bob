AddCSLuaFile()
ENT.PrintName = "Bob"
ENT.Author = "Bubbie & Asrob"
ENT.Category = "Other"
ENT.Base = "base_nextbot"
ENT.Spawnable = true
ENT.AdminOnly = true

function BobChat( pname, msg, action )
	hook.Call( "BobChat", GAMEMODE, msg )
	net.Start( "bobchat" )
	net.WriteString( pname )
	net.WriteString( msg )
	net.WriteBool( action )
	net.Broadcast()
end
net.Receive( "bobchat", function( ply )
pname = net.ReadString()
msg = net.ReadString()
action = net.ReadBool()
if action == true then
	chat.AddText( Color(0, 255, 255, 255), pname, " ", msg )
else
	chat.AddText( Color(0, 255, 255, 255), pname, Color(255, 255, 255, 255), ": " , msg )
end
end )

function FixedPrefix( prefix )
	if string.sub( prefix, 1, 4 ) == "npc_" then
		return "THAT " .. string.sub( prefix, 5 )
	elseif prefix == "bobe" then
		return "bob"
	else
		return prefix
	end
end

function ENT:OnRemove()
	hook.Call( "BobRemoved", GAMEMODE )
	BobStop()
end

function ENT:Initialize()
	bobhideradius = 3000
	hook.Call( "BobSpawned", GAMEMODE, self.Owner )
	if SERVER then
		HappyBob( self )
		util.AddNetworkString( "bobchat" )
		BobChat( "Bob", "HELLO :D", false )
		self:SetModel( "models/kleiner.mdl" )
		BobSetNextUse( self, 0 )
		timer.Create( "Bob:D", 10, 0, function()
			BobChat( "Bob", table.Random( bob ), false )
		end )
		timer.Create( "MakeSureBobIsNotDrowning:D", 0, 0, function()
			if self:WaterLevel() > 0 then
				BobChat( "Bob", "OH MY GOD I'M DROWNING", false )
				BobChat( "Bob", "drowns :(", true )
				self:BecomeRagdoll( DamageInfo() )
				BobStop()
				hook.Call( "BobDrowned", GAMEMODE )
			end
		end )
	end
end
function ENT:OnKilled( dmginfo )
	if SERVER then
		hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
		BobChat( "Bob", "OH MY GOD YOU JUST KILLED ME", false )
		self:BecomeRagdoll( dmginfo )
		BobChat( "Bob", "dies :(", true )
		BobStop()
	end
	hook.Call( "BobKilled", GAMEMODE, dmginfo )
end
function ENT:OnOtherKilled( victim, dmginfo )
	if SERVER then
		if victim:GetClass() == "player" then return end
		if string.find( victim:GetClass(), "zombi", 1 ) or string.find( victim:GetClass(), "antlion", 1 ) or string.find( victim:GetClass(), "headcrab", 1 ) or string.find( victim:GetClass(), "combine", 1 ) or string.find( victim:GetClass(), "barnacle", 1 ) or string.find( victim:GetClass(), "metro", 1 ) then
			BobChat( "Bob", "Nice shot! :D" )
		return end
		if victim:GetClass() == "npc_crow" or victim:GetClass() == "npc_seagull" or victim:GetClass() == "npc_pigeon" then
			BobChat( "Bob", "Please don't harm our wildlife! D:" )
			dmginfo:GetAttacker():SetNWInt( "BobsBirdiesKilled", dmginfo:GetAttacker():GetNWInt( "BobsBirdiesKilled", 0 ) + 1 )
			hook.Call( "BobBirdieKilled", GAMEMODE, dmginfo:GetAttacker() )
			if dmginfo:GetAttacker():GetNWInt( "BobsBirdiesKilled", 0 ) > 5 then
				AngryBob( self, dmginfo:GetAttacker() )
				hook.Call( "BobAngered", GAMEMODE, dmginfo:GetAttacker() )
			end
		return end
		BobChat( "Bob", "OH MY GOD YOU JUST KILLED " .. string.upper( FixedPrefix( victim:GetClass() ) ) , false )
		if victim:GetClass() == "bobe" then
			BobChat( "Bob", "has a heart attack and dies :(", true )
			self:BecomeRagdoll( DamageInfo() )
			BobStop()
			hook.Call( "BobDeath", GAMEMODE )
		return end
		if math.random( 1, 100 ) < 50 then
			if math.random( 1, 100 ) == 37 then
				BobChat( "Bob", "pisses himself!", true )
				timer.Simple( 3, function()
					self:BecomeRagdoll( DamageInfo() )
					BobStop()
					hook.Call( "BobScared", GAMEMODE, dmginfo:GetAttacker() )
					hook.Call( "BobDeath", GAMEMODE )
				end )
			return end
			bobhideradius = 8000
			BobChat( "Bob", "runs!", true )
			hook.Call( "BobScared", GAMEMODE, dmginfo:GetAttacker() )
		else
			BobChat( "Bob", "has a heart attack and dies :(", true )
			self:BecomeRagdoll( DamageInfo() )
			BobStop()
			hook.Call( "BobDeath", GAMEMODE )
		end
	end
end

function ENT:RunBehaviour()
	self:StartActivity( ACT_RUN )
	if self:FindSpot( "random", { type = 'hiding', radius = bobhideradius } ) == nil then
		self:MoveToPos( self:GetPos() + Vector( 800, 0, 0 ) )
	else
		self:MoveToPos( self:FindSpot( "random", { type = 'hiding', radius = bobhideradius } ) )
	end
	self:RunBehaviour()
end

function ENT:Think()
	self:NextThink( CurTime() )
	hook.Call( "RunBehaviour", GAMEMODE )
end

function BobSetNextUse( self, seconds )
	self:SetNWBool( "CanUse", false )
	timer.Create( "BobNextUse", seconds, 1, function()
		self:SetNWBool( "CanUse", true )
		timer.Destroy( "BobNextUse" )
	end )
end
function BobCanUse( self )
	if self:GetNWBool( "CanUse", true ) == false then
		return false
	else
		return true
	end
end

function ENT:Use( activator, caller, use, value )
	if BobCanUse( self ) then
		BobSetNextUse( self, 1 )
		self:SetUseType( SIMPLE_USE )
		local bobchat = { "hello " .. string.lower(caller:Nick()) .. "! :D", "this is fun", "how are you today? :D", "im just feeling amazing, " .. string.lower(caller:Nick()) .. "! :D", "what are you up to today? :D", "hi, my name is Bob! :D", "I feel like a rainbow!", "I feel like dancing! :D", "hello, friend! :D" }
		BobChat( "Bob", table.Random( bobchat ), false )
		hook.Call( "BobInteract", GAMEMODE, caller )
	end
end

function ENT:OnStuck()
	hook.Call( "RunBehaviour", GAMEMODE )
	self:SetPos( self:GetPos() + Vector( 0, 0, 30 ) ) -- now he can slowly climb stairs
end

function HappyBob( self )
	bob = { "I love running!", "I love everybody!", "Hello everybody!", "Who wants to play tag with me? :D", "RUNNING :D", "I love the wildlife!", "Bet you can't find me!", "Hey, play tag with me!", "Hey, let's play hide and seek!", "Everybody is beautiful! :D", "I love this! :D" }
end

function AngryBob( self, provoker )
	bob = { "You're a cruel evil monster, " .. provoker:Nick() .. "!", "Why would you shoot all those birds? >:(", "You're not my friend!", "I'm angry with you, " .. provoker:Nick() .. "!", "I hate you, " .. provoker:Nick() .. "!", "All those poor birdies are dead. ;-;" }
end

function DarkBob( self ) -- honestly need to get other shit done like Bob breaking at certain points on gm_construct before I get this done
	bob = { "Hey, what would your cold, lifeless and dead body look like? :D" }
end

function BobStop()
	hook.Call( "BobStop", GAMEMODE )
	timer.Destroy( "MakeSureBobIsNotDisabled:D" )
	timer.Destroy( "MakeSureBobIsNotDrowning:D" )
	timer.Destroy( "Bob:D" )
	timer.Destroy( "MakeSureBobIsNotDrowning2:D" )
end