TOOL.Name = "#tool.koptilnya_mouse_steering.name"
TOOL.Category = "Koptilnya"
TOOL.Command = nil
TOOL.Information = {{name = "left", stage = 0}}
TOOL.ClientConVar = {
    model = "models/hunter/plates/plate025x025.mdl",
    max_angle = 40,
    sensitivity = 1,
    deadzone = 0,
    exponent = 1
}

function TOOL:LeftClick(trace)
    if self:GetStage() ~= 0 then
        return false
    end

    if SERVER then
        ent = ents.Create("koptilnya_mouse_steering")
        ent:SetPos(trace.HitPos)
        ent:SetAngles(trace.HitNormal:Angle())
        ent:Spawn()

        ent:SetModel(self:GetClientInfo("model"))
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
        ent.nocollide = true
        local min = ent:OBBMins()
        ent:SetPos(trace.HitPos - trace.HitNormal * min.z)
        ent:SetPlayer(self:GetOwner())
        ent:Setup(self:GetClientNumber("max_angle"), self:GetClientNumber("sensitivity"), self:GetClientNumber("deadzone"), self:GetClientNumber("exponent"))

        undo.Create("koptilnya_mouse_steering")
        undo.AddEntity(ent)
        undo.SetPlayer(self:GetOwner())
        undo.Finish()
    end

    return true
end

function TOOL:RightClick(trace)
    if not IsValid(trace.Entity) then
        return false
    end

    if SERVER then
        if self:GetStage() == 0 then
            if trace.Entity:GetClass() == "koptilnya_mouse_steering" then
                self.Controller = trace.Entity
                self:SetStage(1)
            else
                return false
            end
        elseif self:GetStage() == 1 then
            self:SetStage(0)

            if self:GetOwner():KeyDown(IN_SPEED) then
                self.Controller:SetRelativeEntity(trace.Entity)
            else
                if trace.Entity:IsVehicle() then
                    trace.Entity.AttachedMouseSteering = self.Controller
                else
                    return false
                end
            end
        end
    end

    return true
end

function TOOL:Reload(trace)
    if SERVER then
        self:SetStage(0)

        if trace.Entity:IsValid() and trace.Entity:IsVehicle() and trace.Entity.AttachedMouseSteering ~= nil then
            trace.Entity.AttachedMouseSteering = nil
        else
            return false
        end
    end

    return true
end

function TOOL.BuildCPanel(CPanel)
    CPanel:AddControl("Header", {Description = "Mouse Steering"})
    CPanel:AddControl("Slider", {Label = "Max Angle", Command = "koptilnya_mouse_steering_max_angle", Type = "Float", Min = 0.1, Max = 89})
    CPanel:AddControl("Slider", {Label = "Sensitivity", Command = "koptilnya_mouse_steering_sensitivity", Type = "Float", Min = 0.1, Max = 10})
    CPanel:AddControl("Slider", {Label = "Deadzone", Command = "koptilnya_mouse_steering_deadzone", Type = "Float", Min = 0, Max = 16})
    CPanel:AddControl("Slider", {Label = "Exponent", Command = "koptilnya_mouse_steering_exponent", Type = "Float", Min = 1, Max = 4})
end

if CLIENT then
    language.Add("tool.koptilnya_mouse_steering.name", "Mouse Steering")
    language.Add("tool.koptilnya_mouse_steering.desc", "))))))))))))))")
    language.Add("tool.koptilnya_mouse_steering.left", "Spawn a controller")
end
