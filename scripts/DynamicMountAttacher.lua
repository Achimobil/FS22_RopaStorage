--[[
Copyright (C) Achimobil 2022

Author: Achimobil
Date: 06.08.2022
Version: 0.1.0.0

Contact:
https://discord.gg/Va7JNnEkcW

History:
V 0.1.0.0 @ 06.08.2022 - First published Version

Important:
Free for use in other mods - no permission needed, only provide my name.
No changes are to be made to this script without permission from Achimobil.

Frei verwendbar - keine erlaubnis nötig, Namensnennung im Mod erforderlich.
An diesem Skript dürfen ohne Genehmigung von Achimobil keine Änderungen vorgenommen werden.
]]

DynamicMountAttacherPlacable = {
    Version = "0.1.0.0",
    Name = "DynamicMountAttacherPlacable",
	prerequisitesPresent = function (specializations)
		return true
	end,
	initSpecialization = function ()
		local schema = Placeable.xmlSchema

		schema:setXMLSpecializationType("DynamicMountAttacherPlacable")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?)#node", "Attacher node")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?)#triggerNode", "Trigger node")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?)#rootNode", "Root node")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?)#jointNode", "Joint node")
		schema:register(XMLValueType.STRING, "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?).lockPosition(?)#xmlFilename", "XML filename of vehicle to lock (needs to match only the end of the filename)")
		schema:register(XMLValueType.NODE_INDEX, "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?).lockPosition(?)#jointNode", "Joint node (Representens the position of the other vehicles root node)")
		ObjectChangeUtil.registerObjectChangeXMLPaths(schema, "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?).lockPosition(?)")
		schema:register(XMLValueType.BOOL, Cylindered.MOVING_TOOL_XML_KEY .. ".dynamicMountAttacherPlacable#value", "Update dynamic mount attacher joints")
		schema:register(XMLValueType.BOOL, Cylindered.MOVING_PART_XML_KEY .. ".dynamicMountAttacherPlacable#value", "Update dynamic mount attacher joints")
		schema:setXMLSpecializationType()
	end
}
print(g_currentModName .. " - init " .. DynamicMountAttacherPlacable.Name .. "(Version: " .. DynamicMountAttacherPlacable.Version .. ")");

function DynamicMountAttacherPlacable.registerFunctions(placeableType)
	SpecializationUtil.registerFunction(placeableType, "writeDynamicMountObjectsToStream", DynamicMountAttacherPlacable.writeDynamicMountObjectsToStream)
	SpecializationUtil.registerFunction(placeableType, "readDynamicMountObjectsFromStream", DynamicMountAttacherPlacable.readDynamicMountObjectsFromStream)
	SpecializationUtil.registerFunction(placeableType, "readDynamicMountObjectsFromStream2", DynamicMountAttacherPlacable.readDynamicMountObjectsFromStream2)
	SpecializationUtil.registerFunction(placeableType, "dynamicMountTriggerCallback", DynamicMountAttacherPlacable.dynamicMountTriggerCallback)
	SpecializationUtil.registerFunction(placeableType, "lockDynamicMountedObject", DynamicMountAttacherPlacable.lockDynamicMountedObject)
	SpecializationUtil.registerFunction(placeableType, "addDynamicMountedObject", DynamicMountAttacherPlacable.addDynamicMountedObject)
	SpecializationUtil.registerFunction(placeableType, "removeDynamicMountedObject", DynamicMountAttacherPlacable.removeDynamicMountedObject)
	SpecializationUtil.registerFunction(placeableType, "getAllowDynamicMountFillLevelInfo", DynamicMountAttacherPlacable.getAllowDynamicMountFillLevelInfo)
	SpecializationUtil.registerFunction(placeableType, "getDynamicMountTimeToMount", DynamicMountAttacherPlacable.getDynamicMountTimeToMount)
	SpecializationUtil.registerFunction(placeableType, "getHasDynamicMountedObjects", DynamicMountAttacherPlacable.getHasDynamicMountedObjects)
	SpecializationUtil.registerFunction(placeableType, "getMyMountAttacher", DynamicMountAttacherPlacable.getMyMountAttacher)
end

function DynamicMountAttacherPlacable.registerOverwrittenFunctions(placeableType)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "updateInfo", DynamicMountAttacherPlacable.updateInfo)
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
    
    spec.myMountAttacherList = {};
    local i = 0;

    while true do
        local currentBaseKey = string.format("placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(%d)", i);

        if not self.xmlFile:hasProperty(currentBaseKey) then
            break;
        end
        
        local myMountAttacher = {};
        myMountAttacher.dynamicMountAttacherPlacableNode = self.xmlFile:getValue(currentBaseKey .. "#node", nil, self.components, self.i3dMappings)
        myMountAttacher.lockPositions = {}

        if self.isServer then

            local dynamicMountTrigger = {
                triggerNode = self.xmlFile:getValue(currentBaseKey .. "#triggerNode", nil, self.components, self.i3dMappings),
                rootNode = self.xmlFile:getValue(currentBaseKey .. "#rootNode", nil, self.components, self.i3dMappings),
                jointNode = self.xmlFile:getValue(currentBaseKey .. "#jointNode", nil, self.components, self.i3dMappings)
            }

            if dynamicMountTrigger.triggerNode ~= nil and dynamicMountTrigger.rootNode ~= nil and dynamicMountTrigger.jointNode ~= nil then
                local collisionMask = getCollisionMask(dynamicMountTrigger.triggerNode)

                if collisionMask == CollisionMask.TRIGGER_DYNAMIC_MOUNT then
                    addTrigger(dynamicMountTrigger.triggerNode, "dynamicMountTriggerCallback", self)

                    myMountAttacher.dynamicMountAttacherPlacableTrigger = dynamicMountTrigger
                else
                    Logging.xmlWarning(self.xmlFile, "Dynamic Mount trigger has invalid collision mask (should be %d)!", CollisionMask.TRIGGER_DYNAMIC_MOUNT)
                end
            end

            self.xmlFile:iterate(currentBaseKey .. ".lockPosition", function (index, key)
                local entry = {
                    xmlFilename = self.xmlFile:getValue(key .. "#xmlFilename"),
                    jointNode = self.xmlFile:getValue(key .. "#jointNode", nil, self.components, self.i3dMappings)
                }

                if entry.xmlFilename ~= nil and entry.jointNode ~= nil then
                    entry.xmlFilename = entry.xmlFilename:gsub("$data", "data")
                    entry.objectChanges = {}

                    ObjectChangeUtil.loadObjectChangeFromXML(self.xmlFile, key, entry.objectChanges, self.components, self)
                    table.insert(myMountAttacher.lockPositions, entry)
                else
                    Logging.xmlWarning(self.xmlFile, "Invalid lock position '%s'. Missing xmlFilename or jointNode!", key)
                end
            end)
        end

        myMountAttacher.pendingDynamicMountObjects = {}
        
        table.insert(spec.myMountAttacherList, myMountAttacher);
                
        i = i + 1;
    end
    
    
	spec.dynamicMountAttacherPlacableForceLimitScale = 1;
	spec.dynamicMountAttacherPlacableTimeToMount = 1000;
	spec.numObjectBits = 5;
	spec.maxNumObjectsToSend = 2^spec.numObjectBits - 1;
	spec.mountType = DynamicMountUtil.TYPE_FIX_ATTACH;
	spec.forceAcceleration = 5000;

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

    for _, myMountAttacher in pairs(spec.myMountAttacherList) do
        if myMountAttacher.dynamicMountAttacherPlacableTrigger ~= nil then
            removeTrigger(myMountAttacher.dynamicMountAttacherPlacableTrigger.triggerNode)
        end
	end
end

function DynamicMountAttacherPlacable:onReadUpdateStream(streamId, timestamp, connection)
	if connection:getIsServer() then
		local spec = self.spec_dynamicMountAttacherPlacable

		if streamReadBool(streamId) then
			local sum = self:readDynamicMountObjectsFromStream(streamId, spec.dynamicMountedObjects)

			self:readDynamicMountObjectsFromStream2(streamId, spec.myMountAttacherList)
		end
	end
end

function DynamicMountAttacherPlacable:onWriteUpdateStream(streamId, connection, dirtyMask)
	if not connection:getIsServer() then
		local spec = self.spec_dynamicMountAttacherPlacable

		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dynamicMountedObjectsDirtyFlag) ~= 0) then
			self:writeDynamicMountObjectsToStream(streamId, spec.dynamicMountedObjects, 0)
            for attacherIndex, myMountAttacher in pairs(spec.myMountAttacherList) do
                self:writeDynamicMountObjectsToStream(streamId, myMountAttacher.pendingDynamicMountObjects, attacherIndex)
            end
		end
	end
end

function DynamicMountAttacherPlacable:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	if self.isServer then
		local spec = self.spec_dynamicMountAttacherPlacable

        for _, myMountAttacher in pairs(spec.myMountAttacherList) do
            for object, _ in pairs(myMountAttacher.pendingDynamicMountObjects) do
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
                        local trigger = myMountAttacher.dynamicMountAttacherPlacableTrigger
                        local objectJoint = createTransformGroup("dynamicMountObjectJoint")

                        link(trigger.jointNode, objectJoint)
                        setWorldTranslation(objectJoint, getWorldTranslation(objectRoot))

                        -- attacher eintragen ins objekt, da ich sonst keine zuweisung hin bekomme
                        object.myMountAttacher = myMountAttacher;
                        local couldMount = object:mountDynamic(self, trigger.rootNode, objectJoint, spec.mountType, spec.forceAcceleration)

                        if couldMount then
                            object.additionalDynamicMountJointNode = objectJoint

                            self:addDynamicMountedObject(object)
                        else
                            delete(objectJoint)
                        end
                    else
                        myMountAttacher.pendingDynamicMountObjects[object] = nil

                        self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
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

	object.myMountAttacher.pendingDynamicMountObjects[object] = nil

	object:setWorldPosition(x, y, z, rx, ry, rz, 1, true)
	object:addToPhysics()

	local trigger = object.myMountAttacher.dynamicMountAttacherPlacableTrigger
	local couldMount = object:mountDynamic(self, trigger.rootNode, trigger.jointNode, spec.mountType, spec.forceAcceleration)

	if not couldMount then
		self:removeDynamicMountedObject(object, false)
	end
end

function DynamicMountAttacherPlacable:addDynamicMountedObject(object)
	local spec = self.spec_dynamicMountAttacherPlacable

-- print("object.myMountAttacher")
-- DebugUtil.printTableRecursively(object.myMountAttacher,"_",0,2)

	if spec.dynamicMountedObjects[object] == nil then
		spec.dynamicMountedObjects[object] = object

        for i = 1, #object.myMountAttacher.lockPositions do
            local position = object.myMountAttacher.lockPositions[i]

            if string.find(object.configFileName, position.xmlFilename) then
                local x, y, z = getWorldTranslation(position.jointNode)
                local rx, ry, rz = getWorldRotation(position.jointNode)

                self:lockDynamicMountedObject(object, x, y, z, rx, ry, rz)
                ObjectChangeUtil.setObjectChanges(position.objectChanges, true, self, self.setMovingToolDirty)

                break
            end
        end

		self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
	end
end

function DynamicMountAttacherPlacable:removeDynamicMountedObject(object, isDeleting)
	local spec = self.spec_dynamicMountAttacherPlacable
	spec.dynamicMountedObjects[object] = nil

	if isDeleting then
		object.myMountAttacher.pendingDynamicMountObjects[object] = nil
	end

	for i = 1, #object.myMountAttacher.lockPositions do
		ObjectChangeUtil.setObjectChanges(object.myMountAttacher.lockPositions[i].objectChanges, false, self, self.setMovingToolDirty)
	end

	self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
end

function DynamicMountAttacherPlacable:writeDynamicMountObjectsToStream(streamId, objects, attacherIndex)
	local spec = self.spec_dynamicMountAttacherPlacable
	local num = math.min(table.size(objects), spec.maxNumObjectsToSend)

	streamWriteUIntN(streamId, num, spec.numObjectBits)

	local objectIndex = 0

	for object, _ in pairs(objects) do
		objectIndex = objectIndex + 1

		if num >= objectIndex then
			streamWriteInt32(streamId, attacherIndex)
			NetworkUtil.writeNodeObject(streamId, object)
		else
			Logging.xmlWarning(self.xmlFile, "Not enough bits to send all mounted objects. Please increase '%s'", "placeable.dynamicMountAttacherPlacables.dynamicMountAttacherPlacable(?)#numObjectBits")
		end
	end
end

function DynamicMountAttacherPlacable:readDynamicMountObjectsFromStream2(streamId, myMountAttacherList)
	local spec = self.spec_dynamicMountAttacherPlacable
	local sum = streamReadUIntN(streamId, spec.numObjectBits)

    for attacherIndex, myMountAttacher in pairs(myMountAttacherList) do
        for k, _ in pairs(myMountAttacher.pendingDynamicMountObjects) do
            myMountAttacher.pendingDynamicMountObjects[k] = nil
        end
	end

	for _ = 1, sum do
        local attacherIndex = streamReadInt32(streamId)
		local object = NetworkUtil.readNodeObject(streamId)

		if object ~= nil then
			myMountAttacherList[attacherIndex].pendingDynamicMountObjects[object] = object
		end
	end

	return sum
end

function DynamicMountAttacherPlacable:readDynamicMountObjectsFromStream(streamId, objects)
	local spec = self.spec_dynamicMountAttacherPlacable
	local sum = streamReadUIntN(streamId, spec.numObjectBits)

	for k, _ in pairs(objects) do
		objects[k] = nil
	end

	for _ = 1, sum do
        local attacherIndex = streamReadInt32(streamId)
		local object = NetworkUtil.readNodeObject(streamId)

		if object ~= nil then
			objects[object] = object
		end
	end

	return sum
end

function DynamicMountAttacherPlacable:getMyMountAttacher(triggerId)
	local spec = self.spec_dynamicMountAttacherPlacable
    
-- print("spec.myMountAttacherList")
-- DebugUtil.printTableRecursively(spec.myMountAttacherList,"_",0,2)

    for _, myMountAttacher in pairs(spec.myMountAttacherList) do
        if myMountAttacher.dynamicMountAttacherPlacableTrigger.triggerNode == triggerId then
            return myMountAttacher;
        end
    end
    
    return nil;
end

function DynamicMountAttacherPlacable:dynamicMountTriggerCallback(triggerId, otherActorId, onEnter, onLeave, onStay, otherShapeId)
	local spec = self.spec_dynamicMountAttacherPlacable
    
    local myMountAttacher = self:getMyMountAttacher(triggerId);

	if getRigidBodyType(otherActorId) == RigidBodyType.DYNAMIC and not getHasTrigger(otherActorId) then
		if onEnter then
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
					myMountAttacher.pendingDynamicMountObjects[object] = Utils.getNoNil(myMountAttacher.pendingDynamicMountObjects[object], 0) + 1

					if myMountAttacher.pendingDynamicMountObjects[object] == 1 then
						self:raiseDirtyFlags(spec.dynamicMountedObjectsDirtyFlag)
					end
				end
			end
		elseif onLeave then
			local object = g_currentMission:getNodeObject(otherActorId)

			if object == nil then
				object = g_currentMission.nodeToObject[otherActorId]
			end

			if object ~= nil and myMountAttacher.pendingDynamicMountObjects[object] ~= nil then
				local count = myMountAttacher.pendingDynamicMountObjects[object] - 1

				if count == 0 then
					myMountAttacher.pendingDynamicMountObjects[object] = nil

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
					myMountAttacher.pendingDynamicMountObjects[object] = count
				end
			end
		end
	end
    self:raiseActive()
end

function DynamicMountAttacherPlacable:getAllowDynamicMountFillLevelInfo()
	return true
end

function DynamicMountAttacherPlacable:getDynamicMountTimeToMount()
	return self.spec_dynamicMountAttacherPlacable.dynamicMountAttacherPlacableTimeToMount
end

function DynamicMountAttacherPlacable:getHasDynamicMountedObjects()
	return next(self.spec_dynamicMountAttacherPlacable.dynamicMountedObjects) ~= nil
end

function DynamicMountAttacherPlacable:onPreAttachImplement(object, inputJointDescIndex, jointDescIndex)
	local objSpec = object.spec_dynamicMountAttacherPlacable

	if objSpec ~= nil and self.isServer then
        for _, myMountAttacher in pairs(objSpec.myMountAttacherList) do
            myMountAttacher.pendingDynamicMountObjects[self] = nil

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
end

function DynamicMountAttacherPlacable:updateInfo(superFunc, infoTable)
    local spec = self.spec_dynamicMountAttacherPlacable;

	local owningFarm = g_farmManager:getFarmById(self:getOwnerFarmId())

	table.insert(infoTable, {
		title = g_i18n:getText("fieldInfo_ownedBy"),
		text = owningFarm.name
	})
        
    for index, myMountAttacher in pairs(spec.myMountAttacherList) do
        local text = g_i18n:getText("bigDisplay_empty")
        for object, _ in pairs(spec.dynamicMountedObjects) do
            if object.myMountAttacher ~= nil and object.myMountAttacher == myMountAttacher then
                text = object:getName();
    
    -- print("object");
    -- DebugUtil.printTableRecursively(object,"_",0,2);
            end
        end
        
        table.insert(infoTable, {
            title = g_i18n:getText("bigDisplay_attacher") .. " " .. tostring(index),
            text = text;
        })
    end
    -- if (spec.loadingStationToUse ~= nil) then
        -- table.insert(infoTable, {
            -- title = g_i18n:getText("bigDisplay_connected_with"),
            -- text = spec.loadingStationToUse:getName();
        -- })
    -- end
end