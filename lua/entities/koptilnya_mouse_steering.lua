AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "Opti1337"
ENT.Contact = "wraker6@gmail.com"
ENT.PrintName = "Mouse Steering"

if SERVER then
    function ENT:Initialize()
        self:DrawShadow(false)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self.driver = nil
        self.X = 0

        self:SetOverlayText("Mouse Steering")
        self:Setup(40, 1, 0, 1)
    end

    function ENT:Think()
        if IsValid(self.relativeEntity) then
            self:SetAngles(self.relativeEntity:LocalToWorldAngles(Angle(0, self.steerAngle, 0)))
        else
            self:SetAngles(Angle(0, self.steerAngle, 0))
        end

        self:NextThink(CurTime())

        return true
    end

    function ENT:Setup(maxAngle, sensitivity, deadzone, exponent)
        self.maxAngle = maxAngle
        self.sensitivity = sensitivity
        self.deadzone = deadzone
        self.exponent = exponent
    end

    function ENT:SetRelativeEntity(ent)
        if not IsValid(ent) then
            return
        end

        self.relativeEntity = ent
    end

    function ENT:Steer(steer)
        self.steerAngle = -steer * self.maxAngle
    end

    -- hook.Add("PlayerEnteredVehicle", "koptilnya_mouse_steering_entervehicle", function(ply, vehicle)
    --     local mouseSteering = vehicle.AttachedMouseSteering

    --     if mouseSteering ~= nil then
    --         if IsValid(mouseSteering) then
    --             mouseSteering.driver = vehicle:GetDriver()
    --         else
    --             vehicle.AttachedMouseSteering = nil
    --         end
    --     end
    -- end)

    -- hook.Add("PlayerLeaveVehicle", "koptilnya_mouse_steering_leavevehicle", function(ply, vehicle)
    --     local mouseSteering = vehicle.AttachedMouseSteering

    --     if mouseSteering ~= nil then
    --         if IsValid(mouseSteering) then
    --             mouseSteering.driver = nil
    --         else
    --             vehicle.AttachedMouseSteering = nil
    --         end
    --     end
    -- end)

    local X = 0
    hook.Add("StartCommand", "koptilnya_startcommand", function(ply, cmd)
        if not IsValid(ply) then
            return
        end

        if not ply:InVehicle() then
            return
        end

        local vehicle = ply:GetVehicle()
        if not IsValid(vehicle) then
            return
        end

        local mouseSteering = vehicle.AttachedMouseSteering
        if not IsValid(mouseSteering) then
            return
        end

        local frametime = FrameTime()
        local deltaX = cmd:GetMouseX()

        X = math.Clamp(X + deltaX * frametime * 0.05 * mouseSteering.sensitivity, -1, 1)

        local steer = ((math.max(math.abs(X) - mouseSteering.deadzone / 16, 0) ^ mouseSteering.exponent) / (1 - mouseSteering.deadzone / 16)) *
                          ((X > 0) and 1 or -1)

        mouseSteering:Steer(steer)
    end)

    -- hook.Add("CreateMove", "koptilnya_mouse_steering_setupmove", function(ucmd)
    -- end)
else
    function ENT:Initialize()
        self:SetPredictable(true)
    end
end

