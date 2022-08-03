DynamicMountAttacherPlacable = {
	DYNAMIC_MOUNT_GRAB_XML_PATH = "placeable.dynamicMountAttacherPlacable.grab",
	prerequisitesPresent = function (specializations)
		return true
	end,
	initSpecialization = function ()
		local schema = Placeable.xmlSchema

		schema:setXMLSpecializationType("DynamicMountAttacherPlacable")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacable#node", "Attacher node")
		schema:register(XMLValueType.FLOAT, "placeable.dynamicMountAttacherPlacable#forceLimitScale", "Force limit", 1)
		schema:register(XMLValueType.FLOAT, "placeable.dynamicMountAttacherPlacable#timeToMount", "No movement time until mounting", 1000)
		schema:register(XMLValueType.INT, "placeable.dynamicMountAttacherPlacable#numObjectBits", "Number of object bits to sync", 5)
		schema:register(XMLValueType.STRING, "placeable.dynamicMountAttacherPlacable.grab#openMountType", "Open mount type", "TYPE_FORK")
		schema:register(XMLValueType.STRING, "placeable.dynamicMountAttacherPlacable.grab#closedMountType", "Closed mount type", "TYPE_AUTO_ATTACH_XYZ")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacable.mountCollisionMask(?)#node", "Collision node")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacable.mountCollisionMask(?)#triggerNode", "Trigger node")
		schema:register(XMLValueType.STRING, "placeable.dynamicMountAttacherPlacable.mountCollisionMask(?)#mountType", "Mount type name", "FORK")
		schema:register(XMLValueType.FLOAT, "placeable.dynamicMountAttacherPlacable.mountCollisionMask(?)#forceLimitScale", "Force limit", 1)
		schema:register(XMLValueType.INT, "placeable.dynamicMountAttacherPlacable.mountCollisionMask(?)#collisionMask", "Collision mask while object mounted")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacable#triggerNode", "Trigger node")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacable#rootNode", "Root node")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacable#jointNode", "Joint node")
		schema:register(XMLValueType.FLOAT, "placeable.dynamicMountAttacherPlacable#forceAcceleration", "Force acceleration", 30)
		schema:register(XMLValueType.STRING, "placeable.dynamicMountAttacherPlacable#mountType", "Mount type", "TYPE_AUTO_ATTACH_XZ")
		schema:register(XMLValueType.BOOL, "placeable.dynamicMountAttacherPlacable#transferMass", "If this is set to 'true' the mass of the object to mount is tranfered to our own component. This improves phyiscs stability", false)
		schema:register(XMLValueType.STRING, "placeable.dynamicMountAttacherPlacable.lockPosition(?)#xmlFilename", "XML filename of vehicle to lock (needs to match only the end of the filename)")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacable.lockPosition(?)#jointNode", "Joint node (Representens the position of the other vehicles root node)")
		ObjectChangeUtil.registerObjectChangeXMLPaths(schema, "placeable.dynamicMountAttacherPlacable.lockPosition(?)")
		schema:register(XMLValueType.STRING, "placeable.dynamicMountAttacherPlacable.animation#name", "Animation name")
		schema:register(XMLValueType.FLOAT, "placeable.dynamicMountAttacherPlacable.animation#speed", "Animation speed", 1)
		schema:register(XMLValueType.BOOL, Cylindered.MOVING_TOOL_XML_KEY .. ".dynamicMountAttacherPlacable#value", "Update dynamic mount attacher joints")
		schema:register(XMLValueType.BOOL, Cylindered.MOVING_PART_XML_KEY .. ".dynamicMountAttacherPlacable#value", "Update dynamic mount attacher joints")
		schema:setXMLSpecializationType()
	end
}

function DynamicMountAttacherPlacable.registerFunctions(placeableType)
	SpecializationUtil.registerFunction(placeableType, "writeDynamicMountObjectsToStream", DynamicMountAttacherPlacable.writeDynamicMountObjectsToStream)
	SpecializationUtil.registerFunction(placeableType, "readDynamicMountObjectsFromStream", DynamicMountAttacherPlacable.readDynamicMountObjectsFromStream)
	SpecializationUtil.registerFunction(placeableType, "getAllowDynamicMountObjects", DynamicMountAttacherPlacable.getAllowDynamicMountObjects)
	SpecializationUtil.registerFunction(placeableType, "dynamicMountTriggerCallback", DynamicMountAttacherPlacable.dynamicMountTriggerCallback)
	SpecializationUtil.registerFunction(placeableType, "lockDynamicMountedObject", DynamicMountAttacherPlacable.lockDynamicMountedObject)
	SpecializationUtil.registerFunction(placeableType, "addDynamicMountedObject", DynamicMountAttacherPlacable.addDynamicMountedObject)
	SpecializationUtil.registerFunction(placeableType, "removeDynamicMountedObject", DynamicMountAttacherPlacable.removeDynamicMountedObject)
	SpecializationUtil.registerFunction(placeableType, "setDynamicMountAnimationState", DynamicMountAttacherPlacable.setDynamicMountAnimationState)
	SpecializationUtil.registerFunction(placeableType, "getAllowDynamicMountFillLevelInfo", DynamicMountAttacherPlacable.getAllowDynamicMountFillLevelInfo)
	SpecializationUtil.registerFunction(placeableType, "loadDynamicMountGrabFromXML", DynamicMountAttacherPlacable.loadDynamicMountGrabFromXML)
	SpecializationUtil.registerFunction(placeableType, "getIsDynamicMountGrabOpened", DynamicMountAttacherPlacable.getIsDynamicMountGrabOpened)
	SpecializationUtil.registerFunction(placeableType, "getDynamicMountTimeToMount", DynamicMountAttacherPlacable.getDynamicMountTimeToMount)
	SpecializationUtil.registerFunction(placeableType, "getHasDynamicMountedObjects", DynamicMountAttacherPlacable.getHasDynamicMountedObjects)
	SpecializationUtil.registerFunction(placeableType, "forceDynamicMountPendingObjects", DynamicMountAttacherPlacable.forceDynamicMountPendingObjects)
	SpecializationUtil.registerFunction(placeableType, "forceUnmountDynamicMountedObjects", DynamicMountAttacherPlacable.forceUnmountDynamicMountedObjects)
	SpecializationUtil.registerFunction(placeableType, "getDynamicMountAttacherPlacableSettingsByNode", DynamicMountAttacherPlacable.getDynamicMountAttacherPlacableSettingsByNode)
end

function DynamicMountAttacherPlacable.registerOverwrittenFunctions(placeableType)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "getFillLevelInformation", DynamicMountAttacherPlacable.getFillLevelInformation)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "addNodeObjectMapping", DynamicMountAttacherPlacable.addNodeObjectMapping)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "removeNodeObjectMapping", DynamicMountAttacherPlacable.removeNodeObjectMapping)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "loadExtraDependentParts", DynamicMountAttacherPlacable.loadExtraDependentParts)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "updateExtraDependentParts", DynamicMountAttacherPlacable.updateExtraDependentParts)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "getIsAttachedTo", DynamicMountAttacherPlacable.getIsAttachedTo)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "getAdditionalComponentMass", DynamicMountAttacherPlacable.getAdditionalComponentMass)
end

function DynamicMountAttacherPlacable.registerEventListeners(placeableType)
	SpecializationUtil.registerEventListener(placeableType, "onLoad", DynamicMountAttacherPlacable)
	SpecializationUtil.registerEventListener(placeableType, "onDelete", DynamicMountAttacherPlacable)
	SpecializationUtil.registerEventListener(placeableType, "onReadUpdateStream", DynamicMountAttacherPlacable)
	SpecializationUtil.registerEventListener(placeableType, "onWriteUpdateStream", DynamicMountAttacherPlacable)
	SpecializationUtil.registerEventListener(placeableType, "onUpdate", DynamicMountAttacherPlacable)
	SpecializationUtil.registerEventListener(placeableType, "onPreAttachImplement", DynamicMountAttacherPlacable)
end

function DynamicMountAttacherPlacable:onLoad(savegame)
    self.spec_dynamicMountAttacherPlacable = {};
	local spec = self.spec_dynamicMountAttacherPlacable

	XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "placeable.dynamicMountAttacherPlacable#index", "placeable.dynamicMountAttacherPlacable#node")

	spec.dynamicMountAttacherPlacableNode = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#node", nil, self.components, self.i3dMappings)
	spec.dynamicMountAttacherPlacableForceLimitScale = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#forceLimitScale", 1)
	spec.dynamicMountAttacherPlacableTimeToMount = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#timeToMount", 1000)
	spec.numObjectBits = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#numObjectBits", 5)
	spec.maxNumObjectsToSend = 2^spec.numObjectBits - 1
	local grabKey = "placeable.dynamicMountAttacherPlacable.grab"

	if self.xmlFile:hasProperty(grabKey) then
		spec.dynamicMountAttacherPlacableGrab = {}

		self:loadDynamicMountGrabFromXML(self.xmlFile, grabKey, spec.dynamicMountAttacherPlacableGrab)
	end

	spec.pendingDynamicMountObjects = {}
	spec.dynamicMountCollisionMasks = {}
	spec.lockPositions = {}

	if self.isServer then
		self.xmlFile:iterate("placeable.dynamicMountAttacherPlacable.mountCollisionMask", function (index, key)
			local mountCollision = {
				node = self.xmlFile:getValue(key .. "#node", nil, self.components, self.i3dMappings),
				triggerNode = self.xmlFile:getValue(key .. "#triggerNode", nil, self.components, self.i3dMappings),
				mountedCollisionMask = self.xmlFile:getValue(key .. "#collisionMask")
			}

			if mountCollision.node ~= nil and mountCollision.mountedCollisionMask ~= nil then
				local mountTypeStr = self.xmlFile:getValue(key .. "#mountType", "FORK")
				mountCollision.mountType = DynamicMountUtil["TYPE_" .. mountTypeStr] or DynamicMountUtil.TYPE_FORK
				mountCollision.forceLimitScale = self.xmlFile:getValue(key .. "#forceLimitScale", spec.dynamicMountAttacherPlacableForceLimitScale)
				mountCollision.unmountedCollisionMask = getCollisionMask(mountCollision.node)

				table.insert(spec.dynamicMountCollisionMasks, mountCollision)
			else
				Logging.xmlWarning(self.xmlFile, "Missing node or collisionMask in '%s'", key)
			end
		end)

		local dynamicMountTrigger = {
			triggerNode = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#triggerNode", nil, self.components, self.i3dMappings),
			rootNode = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#rootNode", nil, self.components, self.i3dMappings),
			jointNode = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#jointNode", nil, self.components, self.i3dMappings)
		}

		if dynamicMountTrigger.triggerNode ~= nil and dynamicMountTrigger.rootNode ~= nil and dynamicMountTrigger.jointNode ~= nil then
			local collisionMask = getCollisionMask(dynamicMountTrigger.triggerNode)

			if collisionMask == CollisionMask.TRIGGER_DYNAMIC_MOUNT then
				addTrigger(dynamicMountTrigger.triggerNode, "dynamicMountTriggerCallback", self)

				dynamicMountTrigger.forceAcceleration = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#forceAcceleration", 30)
				local mountTypeString = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#mountType", "TYPE_AUTO_ATTACH_XZ")
				dynamicMountTrigger.mountType = Utils.getNoNil(DynamicMountUtil[mountTypeString], DynamicMountUtil.TYPE_AUTO_ATTACH_XZ)
				dynamicMountTrigger.currentMountType = dynamicMountTrigger.mountType
				-- dynamicMountTrigger.component = self:getParentComponent(dynamicMountTrigger.triggerNode)
				spec.dynamicMountAttacherPlacableTrigger = dynamicMountTrigger
			else
				Logging.xmlWarning(self.xmlFile, "Dynamic Mount trigger has invalid collision mask (should be %d)!", CollisionMask.TRIGGER_DYNAMIC_MOUNT)
			end
		end

		spec.transferMass = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable#transferMass", false)

		self.xmlFile:iterate("placeable.dynamicMountAttacherPlacable.lockPosition", function (index, key)
			local entry = {
				xmlFilename = self.xmlFile:getValue(key .. "#xmlFilename"),
				jointNode = self.xmlFile:getValue(key .. "#jointNode", nil, self.components, self.i3dMappings)
			}

			if entry.xmlFilename ~= nil and entry.jointNode ~= nil then
				entry.xmlFilename = entry.xmlFilename:gsub("$data", "data")
				entry.objectChanges = {}

				ObjectChangeUtil.loadObjectChangeFromXML(self.xmlFile, key, entry.objectChanges, self.components, self)
				table.insert(spec.lockPositions, entry)
			else
				Logging.xmlWarning(self.xmlFile, "Invalid lock position '%s'. Missing xmlFilename or jointNode!", key)
			end
		end)
	end

	spec.animationName = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable.animation#name")
	spec.animationSpeed = self.xmlFile:getValue("placeable.dynamicMountAttacherPlacable.animation#speed", 1)

	if spec.animationName ~= nil then
		-- self:playAnimation(spec.animationName, spec.animationSpeed, self:getAnimationTime(spec.animationName), true)
	end

	spec.dynamicMountedObjects = {}
	spec.dynamicMountedObjectsDirtyFlag = self:getNextDirtyFlag()
end

function DynamicMountAttacherPlacable:onDelete()
	local spec = self.spec_dynamicMountAttacherPlacable

	if self.isServer and spec.dynamicMountedObjects ~= nil then
		for object, _ in pairs(spec.dynamicMountedObjects) do
			object:unmountDynamic()
		end
	end

	if spec.dynamicMountAttacherPlacableTrigger ~= nil then
		removeTrigger(spec.dynamicMountAttacherPlacableTrigger.triggerNode)
	end
end

function DynamicMountAttacherPlacable:onReadUpdateStream(streamId, timestamp, connection)
	if connection:getIsServer() then
		local spec = self.spec_dynamicMountAttacherPlacable

		if streamReadBool(streamId) then
			local sum = self:readDynamicMountObjectsFromStream(streamId, spec.dynamicMountedObjects)

			self:setDynamicMountAnimationState(sum > 0)
			self:readDynamicMountObjectsFromStream(streamId, spec.pendingDynamicMountObjects)
		end
	end
end

function DynamicMountAttacherPlacable:onWriteUpdateStream(streamId, connection, dirtyMask)
	if not connection:getIsServer() then
		local spec = self.spec_dynamicMountAttacherPlacable

		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dynamicMountedObjectsDirtyFlag) ~= 0) then
			self:writeDynamicMountObjectsToStream(streamId, spec.dynamicMountedObjects)
			self:writeDynamicMountObjectsToStream(streamId, spec.pendingDynamicMountObjects)
		end
	end
end

function DynamicMountAttacherPlacable:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
-- print("DynamicMountAttacherPlacable:onUpdate")
	if self.isServer then
		local spec = self.spec_dynamicMountAttacherPlacable

		if self:getAllowDynamicMountObjects() then
			for object, _ in pairs(spec.pendingDynamicMountObjects) do
				self:raiseActive()

				if spec.dynamicMountedObjects[object] == nil and object.lastMoveTime + self:getDynamicMountTimeToMount() < g_currentMission.time then
					local doAttach = false
					local objectRoot = nil

					if object.components ~= nil then
						if object.getCanByMounted ~= nil then
							doAttach = object:getCanByMounted()
						elseif entityExists(object.components[1].node) then
							doAttach = true
						end

						objectRoot = object.components[1].node
					end

					if object.nodeId ~= nil then
						if object.getCanByMounted ~= nil then
							doAttach = object:getCanByMounted()
						elseif entityExists(object.nodeId) then
							doAttach = true
						end

						objectRoot = object.nodeId
					end

					if doAttach then
						local trigger = spec.dynamicMountAttacherPlacableTrigger
						local objectJoint = createTransformGroup("dynamicMountObjectJoint")

						link(trigger.jointNode, objectJoint)
						setWorldTranslation(objectJoint, getWorldTranslation(objectRoot))

						local couldMount = object:mountDynamic(self, trigger.rootNode, objectJoint, trigger.mountType, trigger.forceAcceleration)

						if couldMount then
							object.additionalDynamicMountJointNode = objectJoint

							self:addDynamicMountedObject(object)
						else
							delete(objectJoint)
						end
					else
						spec.pendingDynamicMountObjects[object] = nil

						self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
					end
				end
			end
		else
			for object, _ in pairs(spec.dynamicMountedObjects) do
				self:removeDynamicMountedObject(object, false)
				object:unmountDynamic()

				if object.additionalDynamicMountJointNode ~= nil then
					delete(object.additionalDynamicMountJointNode)

					object.additionalDynamicMountJointNode = nil
				end
			end
		end

		if spec.dynamicMountAttacherPlacableGrab ~= nil then
			for object, _ in pairs(spec.dynamicMountedObjects) do
				local usedMountType = spec.dynamicMountAttacherPlacableGrab.closedMountType

				if self:getIsDynamicMountGrabOpened(spec.dynamicMountAttacherPlacableGrab) then
					usedMountType = spec.dynamicMountAttacherPlacableGrab.openMountType
				end

				if spec.dynamicMountAttacherPlacableGrab.currentMountType ~= usedMountType then
					spec.dynamicMountAttacherPlacableGrab.currentMountType = usedMountType
					local x, y, z = getWorldTranslation(spec.dynamicMountAttacherPlacableNode)

					setJointPosition(object.dynamicMountJointIndex, 1, x, y, z)

					if usedMountType == DynamicMountUtil.TYPE_FORK then
						setJointRotationLimit(object.dynamicMountJointIndex, 0, true, 0, 0)
						setJointRotationLimit(object.dynamicMountJointIndex, 1, true, 0, 0)
						setJointRotationLimit(object.dynamicMountJointIndex, 2, true, 0, 0)

						if object.dynamicMountSingleAxisFreeX then
							setJointTranslationLimit(object.dynamicMountJointIndex, 0, false, 0, 0)
						else
							setJointTranslationLimit(object.dynamicMountJointIndex, 0, true, -0.01, 0.01)
						end

						if object.dynamicMountSingleAxisFreeY then
							setJointTranslationLimit(object.dynamicMountJointIndex, 1, false, 0, 0)
						else
							setJointTranslationLimit(object.dynamicMountJointIndex, 1, true, -0.01, 0.01)
						end

						setJointTranslationLimit(object.dynamicMountJointIndex, 2, false, 0, 0)
					else
						setJointRotationLimit(object.dynamicMountJointIndex, 0, true, 0, 0)
						setJointRotationLimit(object.dynamicMountJointIndex, 1, true, 0, 0)
						setJointRotationLimit(object.dynamicMountJointIndex, 2, true, 0, 0)

						if usedMountType == DynamicMountUtil.TYPE_AUTO_ATTACH_XYZ or usedMountType == DynamicMountUtil.TYPE_FIX_ATTACH then
							setJointTranslationLimit(object.dynamicMountJointIndex, 0, true, -0.01, 0.01)
							setJointTranslationLimit(object.dynamicMountJointIndex, 1, true, -0.01, 0.01)
							setJointTranslationLimit(object.dynamicMountJointIndex, 2, true, -0.01, 0.01)
						elseif usedMountType == DynamicMountUtil.TYPE_AUTO_ATTACH_XZ then
							setJointTranslationLimit(object.dynamicMountJointIndex, 0, true, -0.01, 0.01)
							setJointTranslationLimit(object.dynamicMountJointIndex, 1, false, 0, 0)
							setJointTranslationLimit(object.dynamicMountJointIndex, 2, true, -0.01, 0.01)
						elseif usedMountType == DynamicMountUtil.TYPE_AUTO_ATTACH_Y then
							setJointTranslationLimit(object.dynamicMountJointIndex, 0, false, 0, 0)
							setJointTranslationLimit(object.dynamicMountJointIndex, 1, true, -0.01, 0.01)
							setJointTranslationLimit(object.dynamicMountJointIndex, 2, false, 0, 0)
						end
					end
				end
			end
		end
	end
end

function DynamicMountAttacherPlacable:lockDynamicMountedObject(object, x, y, z, rx, ry, rz)
	local spec = self.spec_dynamicMountAttacherPlacable

	DynamicMountUtil.unmountDynamic(object, false)
	object:removeFromPhysics()

	spec.pendingDynamicMountObjects[object] = nil

	object:setWorldPosition(x, y, z, rx, ry, rz, 1, true)
	object:addToPhysics()

	local trigger = spec.dynamicMountAttacherPlacableTrigger
	local couldMount = object:mountDynamic(self, trigger.rootNode, trigger.jointNode, trigger.mountType, trigger.forceAcceleration)

	if not couldMount then
		self:removeDynamicMountedObject(object, false)
	end
end

function DynamicMountAttacherPlacable:addDynamicMountedObject(object)
	local spec = self.spec_dynamicMountAttacherPlacable

	if spec.dynamicMountedObjects[object] == nil then
		spec.dynamicMountedObjects[object] = object
		local lockedToPosition = false

		if object.getMountableLockPositions ~= nil then
			local lockPositions = object:getMountableLockPositions()

			for i = 1, #lockPositions do
				local position = lockPositions[i]

				if string.endsWith(self.configFileName, position.xmlFilename) then
					local jointNode = I3DUtil.indexToObject(self.components, position.jointNode, self.i3dMappings)

					if jointNode ~= nil then
						local x, y, z = localToWorld(jointNode, position.transOffset[1], position.transOffset[2], position.transOffset[3])
						local rx, ry, rz = localRotationToWorld(jointNode, position.rotOffset[1], position.rotOffset[2], position.rotOffset[3])

						self:lockDynamicMountedObject(object, x, y, z, rx, ry, rz)

						lockedToPosition = true

						break
					end
				end
			end
		end

		if not lockedToPosition then
			for i = 1, #spec.lockPositions do
				local position = spec.lockPositions[i]

				if string.endsWith(object.configFileName, position.xmlFilename) then
					local x, y, z = getWorldTranslation(position.jointNode)
					local rx, ry, rz = getWorldRotation(position.jointNode)

					self:lockDynamicMountedObject(object, x, y, z, rx, ry, rz)
					ObjectChangeUtil.setObjectChanges(position.objectChanges, true, self, self.setMovingToolDirty)

					break
				end
			end
		end

		for _, info in pairs(spec.dynamicMountCollisionMasks) do
			setCollisionMask(info.node, info.mountedCollisionMask)
		end

		-- if spec.transferMass and object.setReducedComponentMass ~= nil then
			-- object:setReducedComponentMass(true)
			-- self:setMassDirty()
		-- end

		self:setDynamicMountAnimationState(true)
		self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
	end
end

function DynamicMountAttacherPlacable:removeDynamicMountedObject(object, isDeleting)
	local spec = self.spec_dynamicMountAttacherPlacable
	spec.dynamicMountedObjects[object] = nil

	if isDeleting then
		spec.pendingDynamicMountObjects[object] = nil
	end

	for i = 1, #spec.lockPositions do
		ObjectChangeUtil.setObjectChanges(spec.lockPositions[i].objectChanges, false, self, self.setMovingToolDirty)
	end

	if next(spec.dynamicMountedObjects) == nil and next(spec.pendingDynamicMountObjects) == nil then
		for _, info in pairs(spec.dynamicMountCollisionMasks) do
			setCollisionMask(info.node, info.unmountedCollisionMask)
		end
	end

	-- if spec.transferMass then
		-- self:setMassDirty()
	-- end

	self:setDynamicMountAnimationState(false)
	self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
end

function DynamicMountAttacherPlacable:setDynamicMountAnimationState(state)
	local spec = self.spec_dynamicMountAttacherPlacable

	-- if state then
		-- self:playAnimation(spec.animationName, spec.animationSpeed, self:getAnimationTime(spec.animationName), true)
	-- else
		-- self:playAnimation(spec.animationName, -spec.animationSpeed, self:getAnimationTime(spec.animationName), true)
	-- end
end

function DynamicMountAttacherPlacable:writeDynamicMountObjectsToStream(streamId, objects)
	local spec = self.spec_dynamicMountAttacherPlacable
	local num = math.min(table.size(objects), spec.maxNumObjectsToSend)

	streamWriteUIntN(streamId, num, spec.numObjectBits)

	local objectIndex = 0

	for object, _ in pairs(objects) do
		objectIndex = objectIndex + 1

		if num >= objectIndex then
			NetworkUtil.writeNodeObject(streamId, object)
		else
			Logging.xmlWarning(self.xmlFile, "Not enough bits to send all mounted objects. Please increase '%s'", "placeable.dynamicMountAttacherPlacable#numObjectBits")
		end
	end
end

function DynamicMountAttacherPlacable:readDynamicMountObjectsFromStream(streamId, objects)
	local spec = self.spec_dynamicMountAttacherPlacable
	local sum = streamReadUIntN(streamId, spec.numObjectBits)

	for k, _ in pairs(objects) do
		objects[k] = nil
	end

	for _ = 1, sum do
		local object = NetworkUtil.readNodeObject(streamId)

		if object ~= nil then
			objects[object] = object
		end
	end

	return sum
end

function DynamicMountAttacherPlacable:getAllowDynamicMountObjects()
	return true
end

function DynamicMountAttacherPlacable:dynamicMountTriggerCallback(triggerId, otherActorId, onEnter, onLeave, onStay, otherShapeId)
print("DynamicMountAttacherPlacable:dynamicMountTriggerCallback")
	local spec = self.spec_dynamicMountAttacherPlacable

	if getRigidBodyType(otherActorId) == RigidBodyType.DYNAMIC and not getHasTrigger(otherActorId) then
		if onEnter then
print("DynamicMountAttacherPlacable:onEnter")
			local object = g_currentMission:getNodeObject(otherActorId)

			if object == nil then
				object = g_currentMission.nodeToObject[otherActorId]
			end

			if object == self.rootVehicle or self.spec_attachable ~= nil and self.spec_attachable.attacherVehicle == object then
				object = nil
			end

			if object ~= nil and object ~= self then
				local isObject = object.getSupportsMountDynamic ~= nil and object:getSupportsMountDynamic() and object.lastMoveTime ~= nil
				local isVehicle = object.getSupportsTensionBelts ~= nil and object:getSupportsTensionBelts() and object.lastMoveTime ~= nil

				if isObject or isVehicle then
					spec.pendingDynamicMountObjects[object] = Utils.getNoNil(spec.pendingDynamicMountObjects[object], 0) + 1

					if spec.pendingDynamicMountObjects[object] == 1 then
						self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
					end
				end
			end
		elseif onLeave then
print("DynamicMountAttacherPlacable:onLeave")
			local object = g_currentMission:getNodeObject(otherActorId)

			if object == nil then
				object = g_currentMission.nodeToObject[otherActorId]
			end

			if object ~= nil and spec.pendingDynamicMountObjects[object] ~= nil then
				local count = spec.pendingDynamicMountObjects[object] - 1

				if count == 0 then
					spec.pendingDynamicMountObjects[object] = nil

					if spec.dynamicMountedObjects[object] ~= nil then
						self:removeDynamicMountedObject(object, false)
						object:unmountDynamic()

						if object.additionalDynamicMountJointNode ~= nil then
							delete(object.additionalDynamicMountJointNode)

							object.additionalDynamicMountJointNode = nil
						end
					end

					self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
				else
					spec.pendingDynamicMountObjects[object] = count
				end
			end
		end
	end
    self:raiseActive()
end

function DynamicMountAttacherPlacable:getAllowDynamicMountFillLevelInfo()
	return true
end

function DynamicMountAttacherPlacable:loadDynamicMountGrabFromXML(xmlFile, key, entry)
	local openMountType = self.xmlFile:getValue(key .. "#openMountType")
	entry.openMountType = Utils.getNoNil(DynamicMountUtil[openMountType], DynamicMountUtil.TYPE_FORK)
	local closedMountType = self.xmlFile:getValue(key .. "#closedMountType")
	entry.closedMountType = Utils.getNoNil(DynamicMountUtil[closedMountType], DynamicMountUtil.TYPE_AUTO_ATTACH_XYZ)
	entry.currentMountType = entry.openMountType

	return true
end

function DynamicMountAttacherPlacable:getIsDynamicMountGrabOpened(grab)
	return true
end

function DynamicMountAttacherPlacable:getDynamicMountTimeToMount()
	return self.spec_dynamicMountAttacherPlacable.dynamicMountAttacherPlacableTimeToMount
end

function DynamicMountAttacherPlacable:getHasDynamicMountedObjects()
	return next(self.spec_dynamicMountAttacherPlacable.dynamicMountedObjects) ~= nil
end

function DynamicMountAttacherPlacable:forceDynamicMountPendingObjects(onlyBales)
	if self:getAllowDynamicMountObjects() then
		local spec = self.spec_dynamicMountAttacherPlacable

		for object, _ in pairs(spec.pendingDynamicMountObjects) do
			if spec.dynamicMountedObjects[object] == nil and (not onlyBales or object:isa(Bale)) then
				local trigger = spec.dynamicMountAttacherPlacableTrigger
				local couldMount = object:mountDynamic(self, trigger.rootNode, trigger.jointNode, trigger.mountType, trigger.forceAcceleration)

				if couldMount then
					self:addDynamicMountedObject(object)
				end
			end
		end
	end
end

function DynamicMountAttacherPlacable:forceUnmountDynamicMountedObjects()
	local spec = self.spec_dynamicMountAttacherPlacable

	for object, _ in pairs(spec.dynamicMountedObjects) do
		self:removeDynamicMountedObject(object, false)
		object:unmountDynamic()

		if object.additionalDynamicMountJointNode ~= nil then
			delete(object.additionalDynamicMountJointNode)

			object.additionalDynamicMountJointNode = nil
		end
	end
end

function DynamicMountAttacherPlacable:getDynamicMountAttacherPlacableSettingsByNode(node)
	local spec = self.spec_dynamicMountAttacherPlacable

	for i = 1, #spec.dynamicMountCollisionMasks do
		local mountCollision = spec.dynamicMountCollisionMasks[i]

		if mountCollision.triggerNode == node then
			return mountCollision.mountType, mountCollision.forceLimitScale
		end
	end

	return DynamicMountUtil.TYPE_FORK, 1
end

function DynamicMountAttacherPlacable:getFillLevelInformation(superFunc, display)
	superFunc(self, display)

	if self:getAllowDynamicMountFillLevelInfo() then
		local spec = self.spec_dynamicMountAttacherPlacable

		for object, _ in pairs(spec.dynamicMountedObjects) do
			if object.getFillLevelInformation ~= nil then
				object:getFillLevelInformation(display)
			elseif object.getFillLevel ~= nil and object.getFillType ~= nil then
				local fillType = object:getFillType()
				local fillLevel = object:getFillLevel()
				local capacity = fillLevel

				if object.getCapacity ~= nil then
					capacity = object:getCapacity()
				end

				display:addFillLevel(fillType, fillLevel, capacity)
			end
		end
	end
end

function DynamicMountAttacherPlacable:addNodeObjectMapping(superFunc, list)
	superFunc(self, list)

	local spec = self.spec_dynamicMountAttacherPlacable

	if spec.dynamicMountAttacherPlacableTrigger ~= nil and spec.dynamicMountAttacherPlacableTrigger.triggerNode ~= nil then
		list[spec.dynamicMountAttacherPlacableTrigger.triggerNode] = self
	end
end

function DynamicMountAttacherPlacable:removeNodeObjectMapping(superFunc, list)
	superFunc(self, list)

	local spec = self.spec_dynamicMountAttacherPlacable

	if spec.dynamicMountAttacherPlacableTrigger ~= nil and spec.dynamicMountAttacherPlacableTrigger.triggerNode ~= nil then
		list[spec.dynamicMountAttacherPlacableTrigger.triggerNode] = nil
	end
end

function DynamicMountAttacherPlacable:loadExtraDependentParts(superFunc, xmlFile, baseName, entry)
	if not superFunc(self, xmlFile, baseName, entry) then
		return false
	end

	entry.updateDynamicMountAttacherPlacable = xmlFile:getValue(baseName .. ".dynamicMountAttacherPlacable#value")

	return true
end

function DynamicMountAttacherPlacable:updateExtraDependentParts(superFunc, part, dt)
	superFunc(self, part, dt)

	if self.isServer and part.updateDynamicMountAttacherPlacable ~= nil and part.updateDynamicMountAttacherPlacable then
		local spec = self.spec_dynamicMountAttacherPlacable

		for object, _ in pairs(spec.dynamicMountedObjects) do
			setJointFrame(object.dynamicMountJointIndex, 0, object.dynamicMountJointNode)
		end
	end
end

function DynamicMountAttacherPlacable:getIsAttachedTo(superFunc, vehicle)
	if superFunc(self, vehicle) then
		return true
	end

	local spec = self.spec_dynamicMountAttacherPlacable

	for object, _ in pairs(spec.dynamicMountedObjects) do
		if object == vehicle then
			return true
		end
	end

	for object, _ in pairs(spec.pendingDynamicMountObjects) do
		if object == vehicle then
			return true
		end
	end

	return false
end

function DynamicMountAttacherPlacable:getAdditionalComponentMass(superFunc, component)
	local additionalMass = superFunc(self, component)
	local spec = self.spec_dynamicMountAttacherPlacable

	if spec.transferMass and spec.dynamicMountAttacherPlacableTrigger.component == component.node then
		for object, _ in pairs(spec.dynamicMountedObjects) do
			if object.getAllowComponentMassReduction ~= nil and object:getAllowComponentMassReduction() then
				additionalMass = additionalMass + object:getDefaultMass() - 0.1
			end
		end
	end

	return additionalMass
end

function DynamicMountAttacherPlacable:onPreAttachImplement(object, inputJointDescIndex, jointDescIndex)
	local objSpec = object.spec_dynamicMountAttacherPlacable

	if objSpec ~= nil and self.isServer then
		objSpec.pendingDynamicMountObjects[self] = nil

		if objSpec.dynamicMountedObjects[self] ~= nil then
			object:removeDynamicMountedObject(self, false)
			self:unmountDynamic()

			if object.additionalDynamicMountJointNode ~= nil then
				delete(object.additionalDynamicMountJointNode)

				object.additionalDynamicMountJointNode = nil
			end
		end
	end
end

function DynamicMountAttacherPlacable:updateDebugValues(values)
	local spec = self.spec_dynamicMountAttacherPlacable

	if self.isServer then
		local timeToMount = self.lastMoveTime + spec.dynamicMountAttacherPlacableTimeToMount - g_currentMission.time

		table.insert(values, {
			name = "timeToMount:",
			value = string.format("%d", timeToMount)
		})

		for object, _ in pairs(spec.pendingDynamicMountObjects) do
			table.insert(values, {
				name = "pendingDynamicMountObject:",
				value = string.format("%s timeToMount: %d", object.configFileName or object, math.max(object.lastMoveTime + spec.dynamicMountAttacherPlacableTimeToMount - g_currentMission.time, 0))
			})
		end

		for object, _ in pairs(spec.dynamicMountedObjects) do
			table.insert(values, {
				name = "dynamicMountedObjects:",
				value = string.format("%s", object.configFileName or object)
			})
		end
	end

	table.insert(values, {
		name = "allowMountObjects:",
		value = string.format("%s", self:getAllowDynamicMountObjects())
	})

	if spec.dynamicMountAttacherPlacableGrab ~= nil then
		table.insert(values, {
			name = "grabOpened:",
			value = string.format("%s", self:getIsDynamicMountGrabOpened(spec.dynamicMountAttacherPlacableGrab))
		})
	end
end