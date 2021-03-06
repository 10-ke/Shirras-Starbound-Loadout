local contents
 
function init(args)
		entity.setAnimationState("bees", "off")
        if not self.spawnDelay or not contents then
                -- A gobal spawn time multiplier:
                self.spawnDelay = 1.05
                -- basic spawn variance:
                self.spawnBeeBrake = 350000
                self.spawnItemBrake = 150
                self.spawnHoneyBrake = 350
                self.spawnDroneBrake = 250
				-- modifiers for frames, higher means faster production:
				self.honeyModifier = 0
				self.itemModifier = 0
				self.beeModifier = 0
				self.droneModifier = 0
				self.mutationIncrease = 0
                reset()
        end
end
 
 
function reset()   ---When bees are not present, this sets a slightly increased timer for when bees are added again.
        self.spawnBeeCooldown = self.spawnBeeBrake * 2000
        self.spawnItemCooldown = self.spawnItemBrake * 2
        self.spawnHoneyCooldown = self.spawnHoneyBrake * 2
        self.spawnDroneCooldown = self.spawnDroneBrake * 2
        self.beePower = 0
        contents = world.containerItems(entity.id())
end
 
 function frame()
	contents = world.containerItems(entity.id())
		
		
--- Check the type of frame. Adjust variables-------------		
	if contents[19] then
		if contents[19].name == "basicframe" then
				self.honeyModifier = 6				---A basic reduction to the number of times the apiary has to reduce a cooldown to spawn honey.
		end											---A 600 cooldown, with 30 beepower, is now reduced to a 570 cooldown. 30 beepower = 60 reduced per second, or 9.5 seconds, instead of 10.
		if contents[19].name == "sweetframe" then
				self.honeyModifier = 8
		end
		if contents[19].name == "provenframe" then
				self.itemModifier = 6
		end
		if contents[19].name == "durasteelframe" then
				self.itemModifier = 8
		end
		if contents[19].name == "scentedframe" then
				self.droneModifier = 6
		end
		if contents[19].name == "uraniumframe" then
				self.mutationIncrease = 0.02
				radiatebees = true
		end
		if contents[19].name == "plutoniumframe" then
				self.mutationIncrease = 0.05
		end
		if contents[19].name == "rubiumframe" then
				self.droneModifier = 6
				self.beeModifier = 6
		end
		if contents[19].name == "solarframe" then
			whatTimeOfDay = 1
		end
		if contents[19].name == "eclipseframe" then
			whatTimeOfDay = 2
		end
		if contents[19].name == "copperframe" then
			coppercombs = true
		end
		if contents[19].name == "silverframe" then
			silvercombs = true
		end
		if contents[19].name == "goldframe" then
			goldcombs = true
		end
		if contents[19].name == "diamondframe" then
			preciouscombs = true
		end
		if contents[19].name == "ironframe" then
			ironcombs = true
		end
		if contents[19].name == "titaniumframe" then
			titaniumcombs = true
		end
	end
	

end

function equipped(queen,drone)  ---Apiaries function faster with more drones. 64 drones work just over twice as effecient as 1 drone. (well, exactly (13/6) times)
        contents = world.containerItems(entity.id())
        -- -- log("equipped(" .. queen .. "," .. drone .. ")")
        -- does no matter in which slot the queen or the drone is
		local spawnArea = world.entityPosition(entity.id())
		if contents[17] and contents[18] then
        if contents[17].name == queen and contents[18].name == drone then
                -- log("FOUND BY QUEEN")
                self.beePower = math.ceil(math.sqrt(contents[18].count) + 10)  ---Beepower = cooldown reduction rate. At 500ms scriptDelta, and with 20 beePower, it takes 5 seconds to reduce a 200 cooldown to 0.
				return true
        end
        if contents[18].name == queen and contents[17].name == drone then
                -- log("FOUND BY DRONE")
                self.beePower = math.ceil(math.sqrt(contents[17].count) + 10)  ---Queens dont affect beePower. You can only fit 1 anyway.
				return true
				
        end
        return false
	end
end		

function equippedBees(queen,drone)
        if not drone then
                drone = queen
        end
        -- -- log("equippedBees(" .. queen .. "," .. drone .. ")")
        local q = queen .. "queen"
        local d = drone .. "drone"
        if equipped(q,d) then 
		return true 
		end
        local q = drone .. "queen"
        local d = queen .. "drone"
        if equipped(q,d) then 
		return true 
		end
        return false
end

function trySpawnBee(chance,type,amount)        -- tries to spawn bees if we haven't in this round
        type = type .. "bee"   ---Type is normally things "normal" or "bone", as the code inputs them in workingBees() or breedingBees(), this function uses them to spawn bee monsters. "normalbee" for example.
        amount = amount or 1        -- chance is a float value between 0.00 (will never spawn) and 1.00 (will always spawn)
        if self.doBees and math.random(100)/100 <= chance then      ---math.random(100)/100 allows me to set spawns to anything from 0.00 to 1.00, so chance has to be in that range.
                while amount>0 do
                        world.spawnMonster(type, entity.toAbsolutePosition({ 2, 3 }), { level = 1 })
                        amount = amount - 1
                end
                self.doBees = false
        end
end
 
function trySpawnMutantBee(chance,type,amount)
        type = type .. "bee"
        amount = amount or 1
        if self.doBees and math.random(100)/100 <= ( chance + self.mutationIncrease ) then
                while amount>0 do
                        world.spawnMonster(type, entity.toAbsolutePosition({ 2, 3 }), { level = 1 })
                        amount = amount - 1
                end
                self.doBees = false
        end
end
 

function droneStarter()   ---Spawn more drones in newer apiaries.               -- Drone QTY:  1-40       41-80
	if contents[37] and contents[38] then 										-- Spawn QTY:  +2         +1     (This adds to the function trySpawnDrone: amount)																		
		local beeQuanity = ((contents[37].count + contents[38].count) - 1)      -- I subtracted 1 since the queen inflates the total. Keep in mind either slot could be drones, easiest to add them and then subtract.
		
		if beeQuanity < 81 then 
			droneBonus = math.ceil((81 - beeQuanity / 40))
			return
		end
	end
end


function trySpawnDrone(chance,type,amount)
		droneBonus = 0
		droneStarter()
        -- analog to trySpawnBee() for items (like goldensand)
        amount = (math.random(2) + droneBonus)
			if self.doDrone and math.random(100)/100 <= chance then
						world.containerAddItems(entity.id(), { name=type .. "drone", count = amount, data={}})
						self.doItems = false
			end
end


function trySpawnItems(chance,type,amount)
        -- analog to trySpawnBee() for items (like goldensand)
        amount = amount or 1
        if self.doItems and math.random(100)/100 <= chance then
                world.containerAddItems(entity.id(), { name=type, count = amount, data={}})
                self.doItems = false
        end
end


function trySpawnMutantDrone(chance,type,amount)
        -- analog to trySpawnBee() for items (like goldensand)
        amount = amount or 1
				if self.doDrone and math.random(100)/100 <= ( chance + self.mutationIncrease ) then
						world.containerAddItems(entity.id(), { name=type .. "drone", count = amount, data={}})
						self.doItems = false
				end
end
 
function trySpawnHoney(chance,honeyType,amount)
		if not self.doHoney then return nil end  --if the apiary isn't spawning honey, do nothing
		amount = amount or 1  --- if not specified, just spawn 1 honeycomb.
		local flowerIds = world.objectQuery(entity.position(), 25, {name="beeflower", order="nearest"})  --find all flowers within range
 
		if (math.random(100) / (100 + ( #flowerIds * 3 )) ) <= chance then   --- The more flowers in range, the more likely honey is to spawn. Honey still spawns 1 at a time, at the same interval
			world.containerAddItems(entity.id(), { name=honeyType .. "comb", count = amount, data={}})
			self.doHoney = false
		end
end


function expellQueens(type)   ---Checks how many queens are in the apiary, either under the first or second bee slot, and removes all but 1. The rest will be dropped on the ground. Only functions when the apiary is working.
        contents = world.containerItems(entity.id())
		local queenLocate = type .. "queen"  ---Input the used bee type, and create a string such as "normal" .. "queen" = "normalqueen"
		
		if contents[17].name == queenLocate then	---is queen in slot17? (Top bee slot)
			if contents[17].count > 1 then			---how many queens, exactly?
				local queenname = contents[17].name		---sets the variable queenname to be use for queen removal
				local queenremoval = (contents[17].count - 1) ---How many queens are we removing?
				world.containerConsume(entity.id(), {name = queenname, count = queenremoval, data={}})  ---PEACE OUT, YA QUEENS
				world.spawnItem(queenname, entity.toAbsolutePosition({ 1, 2 }), queenremoval)			--- Oh, hi. Why are you on the ground? SHE THREW YOU OUT? THAT BITCH!
			end
		elseif contents[18].name == queenLocate then  --is queen in slot18? (Bottom bee slot), here we go again....
			if contents[18].count > 1 then
				local queenname = contents[18].name
				local queenremoval = (contents[18].count - 1)
				world.containerConsume(entity.id(), {name = queenname, count = queenremoval, data={}})
				world.spawnItem(queenname, entity.toAbsolutePosition({ 1, 2 }), queenremoval)
			end
		end
end


function spawnHoneyDronesBees(type)  ---condenses the functions that every breeding bee uses, to save space.
    trySpawnHoney(0.60, type)
    trySpawnBee(  0.40, type)			---Some randomization is added by the 0.35 chance of spawn.
    trySpawnDrone(0.40, type)
	expellQueens(type)  -- bitches this be MY house. (Kicks all queens but 1 out of the apiary)
end

function beeSting()
	if math.random(2) == 2 then
	world.spawnProjectile("stingstatusprojectile", entity.position())
	end
end

function flowerCheck()
	local flowerRed = world.objectQuery(entity.position(), 80, {name="flowerred"})
	local flowerYellow = world.objectQuery(entity.position(), 80, {name="floweryellow"})
	local flowerBlue = world.objectQuery(entity.position(), 80, {name="flowerblue"})
	local flowerSpring = world.objectQuery(entity.position(), 80, {name="flowerspring"})
	local FFenergiflower = world.objectQuery(entity.position(), 80, {name="energiflowerseed"})   ----Frackin Flora/Universe 'Flowers'
	local FFfloralytplant = world.objectQuery(entity.position(), 80, {name="floralytplantseed"})
	local FFgoldenglow = world.objectQuery(entity.position(), 80, {name="goldenglowseed"})	
	local FFhaleflower = world.objectQuery(entity.position(), 80, {name="haleflowerseed"})	
	local FFita = world.objectQuery(entity.position(), 80, {name="itaseed"})
	local FFniss = world.objectQuery(entity.position(), 80, {name="nissseed"})
	local FFwubstem = world.objectQuery(entity.position(), 80, {name="wubstemseed"}) 
	
	local noFlowersYet = self.beePower 			---- Check the initial "beePower" before flowers...
	if flowerRed ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#flowerRed) / 2)
	end
	if flowerYellow ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#flowerYellow) / 2)
	end
	if flowerBlue ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#flowerBlue) / 2)
	end
	if flowerSpring ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#flowerSpring) / 2)
	end
	---FrackinUniverse---
	if FFenergiflower ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#FFenergiflower) / 2)
	end
	if FFfloralytplant ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#FFfloralytplant) / 2)
	end
	if FFgoldenglow ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#FFgoldenglow) / 2)
	end
	if FFhaleflower ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#FFhaleflower) / 2)
	end
	if FFita ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#FFita) / 2)
	end
	if FFniss ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#FFniss) / 2)
	end
	if FFwubstem ~= nil then	
		self.beePower = self.beePower + math.ceil(math.sqrt(#FFwubstem) / 2)
	end

	
	if self.beePower == noFlowersYet then
		self.beePower = -1				--- If there are no flowers for the bees... they can't do anything.
		entity.setAnimationState("bees", "off")
		elseif self.beePower >= 60 then
		self.beePower = 60
	end
end


function deciding()
        if self.beePower == -1 then   ---if the apiary doesn't have bees, then stop.
                return
        end
		
        -- counting down and looking for events like spawning a bee, an item or honey
        -- also applies the effects if something has to spawn (increasing cooldown, slowing things down)
		
        if self.spawnDroneCooldown <= 0 then
                self.spawnDroneBrake = self.spawnDroneBrake + 20
                self.doDrone = true
                self.spawnDroneCooldown = ( self.spawnDelay * self.spawnDroneBrake ) - self.droneModifier
        else
                self.doDrone = false
                self.spawnDroneCooldown = self.spawnDroneCooldown - math.ceil( self.beePower )
        end
 
        if self.spawnItemCooldown <= 0 then
                self.spawnItemBrake = self.spawnItemBrake + 20
                self.doItems = true
                self.spawnItemCooldown = ( self.spawnDelay * self.spawnItemBrake ) - self.itemModifier
        else
                self.doItems = false
                self.spawnItemCooldown = self.spawnItemCooldown - self.beePower
        end
		
        if self.spawnHoneyCooldown <= 0 then
                self.spawnHoneyBrake = self.spawnHoneyBrake + 20
                self.doHoney = true
                self.spawnHoneyCooldown = ( self.spawnDelay * self.spawnHoneyBrake ) - self.honeyModifier
        else
                self.doHoney = false
                self.spawnHoneyCooldown = self.spawnHoneyCooldown - self.beePower
        end
end

function miteInfection()   ---Random mite infection.
---see if the container has room for more mites
	local vmiteFitCheck = 	world.containerItemsCanFit(entity.id(), { name= "vmite", count = 1, data={}})
---see if the container is infected with mites
	local vmiteInfectedCheck = 	world.containerConsume(entity.id(), { name= "vmite", count = 1, data={}})
	

	
		---initial infection. with a 500ms polling rate, this runs at once per 60 minutes per apiary, an infection should happen.
		if math.random(7200) == 600 then
			if vmiteFitCheck == true then
				world.containerAddItems(entity.id(), { name="vmite", count = 64, data={}})
			end
		end
	
		---Infection clears if the frame is the anti-mite frame.
		if contents[19] and contents[19].name == "amite" then
				world.containerConsume(entity.id(), { name= "vmite", count = 10, data={}})
				world.containerConsume(entity.id(), { name= "vmite", count = 5, data={}})
				world.containerConsume(entity.id(), { name= "vmite", count = 2, data={}})
				world.containerConsume(entity.id(), { name= "vmite", count = 1, data={}})
		elseif vmiteInfectedCheck == true then
				world.containerAddItems(entity.id(), { name="vmite", count = 31, data={}})
				world.containerAddItems(entity.id(), { name="vmite", count = 60, data={}})
				world.containerAddItems(entity.id(), { name="vmite", count = 60, data={}})
				world.containerAddItems(entity.id(), { name="vmite", count = 60, data={}})
				world.containerAddItems(entity.id(), { name="vmite", count = 60, data={}})
				world.containerAddItems(entity.id(), { name="vmite", count = 60, data={}})
				world.containerAddItems(entity.id(), { name="vmite", count = 60, data={}})
				self.beePower = -1
				entity.setAnimationState("bees", "off")
				return
		end

		---Otherwise it just spreads.
		
end

function daytimeCheck()
		if world.timeOfDay() < 0.50 then
			whatTimeOfDay = 1
			else
			whatTimeOfDay = 2
		end
		if contents[19] then
			if contents[19].name == "solarframe" then       ---temp fix
				whatTimeOfDay = 1
			end
			if contents[19].name == "eclipseframe" then
				whatTimeOfDay = 2
			end
		end
		if whatTimeOfDay == 2 then
			if beeNocturnalDiurnal == "diurnal" then
				entity.setAnimationState("bees", "off")
			end
			if beeNocturnalDiurnal == "nocturnal" then
				entity.setAnimationState("bees", "on")
			end
		end
		if whatTimeOfDay == 1 then
			if beeNocturnalDiurnal == "nocturnal" then
				entity.setAnimationState("bees", "off")
			end
			if beeNocturnalDiurnal == "diurnal" then
				entity.setAnimationState("bees", "on")
			end
		end
end

function update(dt)

		contents = world.containerItems(entity.id())
		daytimeCheck()
		flowerCheck()
		frame()   ---Checks to see if a frame in installed. Must take place after daytimeCheck for eclipse frames.
		
        if not contents[17] or not contents[18] then
                -- removing bees will reset the timers
                if self.beePower ~= 0 then
                        reset()
						frame()
                        -- log("going noop")
                else
                        -- log("sleeping")
                end
				entity.setAnimationState("bees", "off")
                return
        end
		
        deciding()
		
        if not self.doBees and not self.doItems and not self.doHoney and not self.doDrone then
                -- no need to search for the bees if there is nothing to do with them
                self.beePower = 0 -- exchanging a bee without having an empty slot bugs out - so we randomly recheck if the bees match something we know (or is there an on change event?)
                if self.beePower ~= 0 then
                    return
                end
        end
		
		miteInfection()		--- Try to spawn mites.
        -- If bees aren't a match, check to see if the bee types are meant for breeding.
        if not workingBees() then
                breedingBees()
        end
		
end
 
function workingBees()
	if whatTimeOfDay == 1 then
			if equippedBees("normal") then					--NORMAL
                spawnHoneyDronesBees("normal")
				beeNocturnalDiurnal = "diurnal"					
                return true -- no need to check for other bees
			end
			if equippedBees("arid") then					--ARID
                spawnHoneyDronesBees("arid")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("miner") then					--BORING
                spawnHoneyDronesBees("miner")
				beeNocturnalDiurnal = "diurnal"	
				if coppercombs == true then
					trySpawnHoney(1, "copper")
				end
				if silvercombs == true then
					trySpawnHoney(1, "silver")
				end
				if goldcombs == true then
					trySpawnHoney(1, "gold")
				end
				if preciouscombs == true then
					trySpawnHoney(1, "precious")
				end
				if ironcombs == true then
					trySpawnHoney(1, "iron")
				end
				if titaniumcombs == true then
					trySpawnHoney(1, "titanium")
				end
				if radiatebees == true then
					trySpawnMutantBee(  0.16, "radioactive")
					trySpawnMutantDrone(0.12, "radioactive")
				end
				return true
			end
			if equippedBees("exceptional") then					--EXCEPTIONAL
			    trySpawnHoney(0.80, "normal")
				trySpawnBee(  0.40, "exceptional")
				trySpawnDrone(0.40, "exceptional")
                trySpawnItems(0.40, "liquidhoney")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("flower") then					--FLOWER
                spawnHoneyDronesBees("flower")
                trySpawnItems(0.25, "beeflower")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("forest") then					--FOREST
                spawnHoneyDronesBees("forest")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("jungle") then					--JUNGLE
                spawnHoneyDronesBees("jungle")
                trySpawnItems(0.70, "plantfibre")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("mythical") then					--MYTHICAL
                spawnHoneyDronesBees("mythical")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("plutonium") then					--PLUTONIUM
                spawnHoneyDronesBees("plutonium")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("radioactive") then					--RADIOACTIVE
                spawnHoneyDronesBees("radioactive")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("red") then					--RED
                spawnHoneyDronesBees("red")
                trySpawnItems(0.20, "redwaxchunk")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("aggressive") then					--AGGRESSIVE
			    trySpawnHoney(0.80, "red")
				trySpawnBee(  0.40, "aggressive")
				trySpawnDrone(0.40, "aggressive")
				trySpawnItems(0.10, "alienmeat")
				expellQueens("aggressive")
				beeNocturnalDiurnal = "diurnal"	
--				beeSting()
                return true
			end
			if equippedBees("morbid") then					--Morbid
                spawnHoneyDronesBees("morbid")
				trySpawnItems(0.60, "ghostlywax")
				beeNocturnalDiurnal = "diurnal"	
--				beeSting()
                return true
			end
			if equippedBees("hunter") then					--HUNTER
			    trySpawnHoney(0.50, "silk")
				trySpawnBee(  0.40, "hunter")
				trySpawnDrone(0.40, "hunter")
				beeNocturnalDiurnal = "diurnal"	
				expellQueens("hunter")
                return true
			end

			if equippedBees("solarium") then					--SOLARIUM
                spawnHoneyDronesBees("solarium")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("adaptive") then					--Adaptive
			    trySpawnHoney(0.80, "normal")
				trySpawnBee(  0.40, "adaptive")
				beeNocturnalDiurnal = "diurnal"	
				trySpawnDrone(0.40, "adaptive")
				expellQueens("adaptive")
                return true
			end

			if equippedBees("hardy") then					--HARDY
			    trySpawnHoney(0.80, "normal")
				trySpawnBee(  0.40, "hardy")
				trySpawnDrone(0.40, "hardy")		
				beeNocturnalDiurnal = "diurnal"	
				expellQueens("hardy")
                return true
			end
			if equippedBees("godly") then					--GODLY
                spawnHoneyDronesBees("godly")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("volcanic") then					--VOLCANIC
                spawnHoneyDronesBees("volcanic")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			
			if equippedBees("sun") then					--SUN
                spawnHoneyDronesBees("sun")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("arctic") then					--arctic
                spawnHoneyDronesBees("arctic")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("arid") then					--DESERT BEE DONT GIVE A $#@% BOUT CLIMATE
                spawnHoneyDronesBees("arid")
                trySpawnItems(0.30, "goldensand")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
	end
		
--- In case temp gets added back to Starbound. (Everything Bees)-----------------------------------------------------------------
		
----- Nocturnal Bees ------
	if whatTimeOfDay == 2 then	
			if equippedBees("moon") then					--MOON
                spawnHoneyDronesBees("moon")
				beeNocturnalDiurnal = "nocturnal"
                return true
			end
			if equippedBees("nocturnal") then					--NOCTURNAL
                spawnHoneyDronesBees("nocturnal")
				beeNocturnalDiurnal = "nocturnal"
                return true
			end
	end
        return false -- we do not have found a match yet, returning false so we can run breedingBees() in main()
end
 
function breedingBees()
	if whatTimeOfDay == 1 then          ---is it day?
			-----Exceptional Branch
			if equippedBees("normal","forest") then		
                trySpawnHoney(0.40,"normal")
                trySpawnMutantBee(  0.16,"hardy")
				trySpawnMutantDrone(0.12, "hardy")
				expellQueens("normal")
				expellQueens("forest")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("arctic","volcanic") then	
                trySpawnHoney(0.40,"normal")
                trySpawnMutantBee(  0.16,"adaptive")
				trySpawnMutantDrone(0.12, "adaptive")
				expellQueens("arctic")
				expellQueens("volcanic")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("hardy","adaptive") then	
                trySpawnHoney(0.40,"normal")
                trySpawnMutantBee(  0.12,"exceptional")
				trySpawnMutantDrone(0.08, "exceptional")
				expellQueens("hardy")
				expellQueens("adaptive")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end

			-------Miner Branch
			if equippedBees("arid","adaptive") then	
                trySpawnHoney(0.40,"arid")
                trySpawnMutantBee(  0.16,"miner")
				trySpawnMutantDrone(0.12, "miner")
				expellQueens("arid")
				expellQueens("adaptive")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			
			-------Morbid Branch
			if equippedBees("jungle","adaptive") then	
                trySpawnHoney(0.40,"jungle")
                trySpawnMutantBee(  0.16,"hunter")
				trySpawnMutantDrone(0.12, "hunter")
				expellQueens("jungle")
				expellQueens("adaptive")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("hunter","red") then	
                trySpawnHoney(0.40,"red")
                trySpawnMutantBee(  0.14,"aggressive")
				trySpawnMutantDrone(0.10, "aggressive")
				expellQueens("hunter")
				expellQueens("red")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("aggressive","nocturnal") then	
                trySpawnHoney(0.40,"red")
                trySpawnMutantBee(  0.12,"morbid")
				trySpawnMutantDrone(0.08, "morbid")
				expellQueens("aggressive")
				expellQueens("nocturnal")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			
			--------Solarium Branch
			if equippedBees("radioactive","hardy") then	
                trySpawnHoney(0.40,"radioactive")
                trySpawnMutantBee(  0.14,"plutonium")
				trySpawnMutantDrone(0.08, "plutonium")
				expellQueens("radioactive")
				expellQueens("hardy")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("plutonium","exceptional") then	
                trySpawnHoney(0.40,"plutonium")
                trySpawnMutantBee(  0.16,"solarium")
				trySpawnMutantDrone(0.12, "solarium")
				expellQueens("plutonium")
				expellQueens("exceptional")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			
			-------Flower Branches
			if equippedBees("forest","jungle") then	
                trySpawnHoney(0.40,"forest")
                trySpawnMutantBee(  0.18,"flower")
				trySpawnMutantDrone(0.14, "flower")
				expellQueens("forest")
				expellQueens("jungle")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("flower","normal") then	
                trySpawnHoney(0.40,"flower")
                trySpawnMutantBee(  0.18,"red")
				trySpawnMutantDrone(0.14, "red")
				expellQueens("flower")
				expellQueens("normal")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("flower","exceptional") then	
                trySpawnHoney(0.40,"flower")
                trySpawnMutantBee(  0.18,"mythical")
				trySpawnMutantDrone(0.14, "mythical")
				expellQueens("flower")
				expellQueens("exceptional")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			
			----------Godly Branch
			if equippedBees("miner","nocturnal") then	
                trySpawnHoney(0.40,"nocturnal")
                trySpawnMutantBee(  0.18,"moon")
				trySpawnMutantDrone(0.14, "moon")
				expellQueens("miner")
				expellQueens("nocturnal")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("moon","solarium") then	
                trySpawnHoney(0.40,"moon")
                trySpawnMutantBee(  0.18,"sun")
				trySpawnMutantDrone(0.14, "sun")
				expellQueens("moon")
				expellQueens("solarium")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
			if equippedBees("sun","mythical") then					--SUN + MYTHICAL = GODLY   ... YEAH THERES A GOD IN THAT RADIOACTIVE MOON!
                trySpawnHoney(0.30,"normal")
		        trySpawnMutantBee(  0.12, "godly")
				trySpawnMutantDrone(0.08, "godly")
				expellQueens("sun")
				expellQueens("mythical")
				beeNocturnalDiurnal = "diurnal"	
                return true
			end
	end
		beeNocturnalDiurnal = "unknown"	
		entity.setAnimationState("bees", "off")
        -- log("no bees matching: " .. contents[17].name .. " " .. contents[18].name)
        self.beePower = -1
	return false
end
		