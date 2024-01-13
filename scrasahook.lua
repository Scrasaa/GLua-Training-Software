---------------------------- GLOBAL VARS ----------------------------------
local scrW = ScrW()
local scrH = ScrH()
local localPlayer = LocalPlayer()

local bMenuOpen = false

local mainMenuWindow = {}

local bToggle = false

local bToggleDelay = false

local szMenuTitle = "ScrasaHook[0.0.2]"
local colWhite = Color(255,255,255,255)

local bESPToggle = false
local bESPdrawVisible = false
local bCustomESPColor = false

local ESPColor = colWhite
local ESPCustomColor = colWhite
local ESPColorVisible = Color(0, 255, 0, 255)
local ESPColorInvisible = Color(255, 0, 0, 255)
local bDrawFOVCircle = false

local fAimbotFOV = 10
local bAimbotToggle = false
local bRecoilToggle = false
local bAimbotIgnoreJob = false
local bAimbotLOS = false
local szJobIgnore = ""

local bTriggerbotToggle = false

local bDarkRP = false 
local gameModeName = {"darkrp", "starwarsrp", "scprp", "militaryrp"}

for _, gm_name in pairs(gameModeName) do
    if engine.ActiveGamemode() == gm_name then
        bDarkRP = true
        break
    end
end

local subMenus = 
{
    aimbot = nil,
    triggerbot = nil,
    esp = nil
}
----------------------- EFFICIENTY -------------------------------------------------
local radToDeg = 180 / math.pi
local sqrt = math.sqrt
local atan2 = math.atan2
local asin = math.asin

local getAllPlayers = player.GetAll()

local screenMiddleX = ScrW() * .5
local screenMiddleY = ScrH() * .5

local subMenuButtonTextColor = Color(185, 185, 185)

local function ShowOnlySubMenu(menuName)
    for name, panel in pairs(subMenus) do
        if IsValid(panel) then 
            if name == menuName then 
                panel:Show()  -- Corrected to use the variable 'panel'
            else
                panel:Hide()  -- Corrected to use the variable 'panel'
            end
        end
    end
end
--------------------------------- SETTINGS ------------------------------------------
---------------------------- GLOBAL VARS ----------------------------------
function centerTxtX(width, szString)
    local strLen = string.len(szString)
    local centerX = (width * .5)  - strLen * 4.5
    return centerX
end
---------------------------- VGUI SHIT ----------------------------------
surface.CreateFont( "fMenuTitle", {
    font = "System", 
    extended = false,
    size = 23,
    weight = 500,
} )

surface.CreateFont( "espfont", {
    font = "System", 
    extended = false,
    size = 15,
    weight = 500,
    outline = true,
} )

function drawMenu()
    mainMenuWindow = vgui.Create("DFrame")
    mainMenuWindow:SetSize(scrW * 0.5, scrH * 0.65)
    mainMenuWindow:Center()
    mainMenuWindow:SetTitle("")
    mainMenuWindow:SetDraggable(false)
    mainMenuWindow:MakePopup()
    mainMenuWindow:SetDeleteOnClose(false)
    mainMenuWindow:ShowCloseButton(false)
    mainMenuWindow.btnMinim:SetVisible(false)
    mainMenuWindow.btnMaxim:SetVisible(false)
    mainMenuWindow.btnClose:SetVisible(false)

    mainMenuWindow.Paint = function(self, w, h)
        surface.SetDrawColor(50, 50, 50, 255)
        surface.DrawRect(0, 0, w, h)
    end

---------------------------MENU BAR--------------------------------

    local menuBar = vgui.Create("DPanel", mainMenuWindow)
    menuBar:SetPos(0, 0)
    menuBar:SetSize(mainMenuWindow:GetWide(), mainMenuWindow:GetTall() * 0.04)

    menuBar.Paint = function(self, w, h)
        surface.SetDrawColor(25, 25, 25, 255)
        surface.DrawRect(0,0,w,h)
        surface.SetFont("fMenuTitle")
        surface.SetTextColor(subMenuButtonTextColor)
        surface.SetTextPos(w * 0.02, h * 0.1)
        surface.DrawText(szMenuTitle)
    end
----------------------------MENU SIDE PANEL-------------------------------

    local menuSidePanel = vgui.Create("DPanel", mainMenuWindow)
    menuSidePanel:SetPos(0, menuBar:GetTall())
    menuSidePanel:SetSize(mainMenuWindow:GetWide() * 0.2, mainMenuWindow:GetTall() - menuBar:GetTall())

    menuSidePanel.Paint = function(self, w, h)
        surface.SetDrawColor(25,25,25,255)
        surface.DrawRect(0,0,w,h)
    end

--------------------------MENU BUTTONS---------------------------------

    local menuButtons = {}

    function menuButtons:Init()
        self:SetSize(menuSidePanel:GetWide(), menuSidePanel:GetTall() * 0.075)
        self:SetPos(0, 0)
        self:SetText("")
    end

    function menuButtons:Paint(w, h)
        -- Define colors
        local bgColor = Color(25, 25, 25, 255) -- Dark background color
        local borderColor = Color(50, 50, 50, 255) -- Slightly lighter border color
        local hoverInnerColor = Color(35, 35, 35, 255) 

        local borderRadius = 4

        -- Initialize animation progress if not already defined
        self.animProgress = self.animProgress or 0

        -- Update the animation progress
        if self:IsHovered() then
            self.animProgress = math.min(self.animProgress + FrameTime() * 3, 1) -- Clamped between 0 and 1
        else
            self.animProgress = math.max(self.animProgress - FrameTime() * 3, 0)
        end

        -- Calculate the size of the inner box based on the animation progress
        local padding = Lerp(self.animProgress, w * 0.1, 0) -- Calculate padding for smaller box
        local innerBoxWidth = w - padding * 2
        local innerBoxHeight = h - padding * 2

        -- Calculate the alpha of the hover color based on the animation progress
        local hoverAlpha = Lerp(self.animProgress, 0, 255)

        -- Draw the hover effect
        local hoverFillColor = Color(hoverInnerColor.r, hoverInnerColor.g, hoverInnerColor.b, hoverAlpha)
        draw.RoundedBox(borderRadius, padding, padding, innerBoxWidth, innerBoxHeight, hoverFillColor)
    end
 
    vgui.Register("MenuButtonSidePanel", menuButtons, "DButton")

---------------------------MENU SUB MENU--------------------------------

    local menuSubMenus = {}

    function menuSubMenus:Init()
        self:SetSize(mainMenuWindow:GetWide() - menuSidePanel:GetWide(), menuSidePanel:GetTall())
        self:SetPos(0,0)
        mainMenuWindow:SetDeleteOnClose(true)
    end

    function menuSubMenus:Paint(w, h)
        surface.SetDrawColor(50, 50, 50, 255)
        surface.DrawRect(0, 0, w, h)
    end

    vgui.Register("SubMenuPanel", menuSubMenus, "DPanel")

-----------------------------SETUP MENU---------------------------------
    local aimbotButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)

    aimbotButton.Paint = function(self, w, h)
        menuButtons.Paint(self, w, h)
        draw.DrawText("Aimbot", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
    end

    if (subMenus.aimbot == nil) then
        subMenus.aimbot = vgui.Create("SubMenuPanel", mainMenuWindow)
        subMenus.aimbot:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())   

        local aimbotFovSlider = subMenus.aimbot:Add("DNumSlider")
        aimbotFovSlider:SetPos(subMenus.aimbot:GetWide() * 0.05, subMenus.aimbot:GetTall() * 0.055)
        aimbotFovSlider:SetSize(subMenus.aimbot:GetWide() * 0.5, subMenus.aimbot:GetTall() * 0.1)
        aimbotFovSlider:SetText("Aimbot FOV")
        aimbotFovSlider:SetMin(0)
        aimbotFovSlider:SetMax(360)
        aimbotFovSlider:SetValue(fAimbotFOV)

        aimbotFovSlider.OnValueChanged = function(self, value)
            fAimbotFOV = value
        end
        bAimbotFovSliderCreated = true

        local aimbotLOSCheckBox = subMenus.aimbot:Add("DCheckBoxLabel")
        aimbotLOSCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.05, subMenus.aimbot:GetTall() * 0.125)
        aimbotLOSCheckBox:SetText("Visible Check ON/OFF")
        function aimbotLOSCheckBox:OnChange(val) 
            if (val) then
                bAimbotLOS = true 
            else 
                bAimbotLOS = false
            end
        end

        local recoilCheckBox = subMenus.aimbot:Add("DCheckBoxLabel")
        recoilCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.05, subMenus.aimbot:GetTall() * 0.06)
        recoilCheckBox:SetText("Recoil ON/OFF (M9K ONLY)")
        function recoilCheckBox:OnChange(val)
            if val then 
                bRecoilToggle = true
            else
                bRecoilToggle = false
            end
        end

        local jobSelectBox = subMenus.aimbot:Add("DComboBox")
        jobSelectBox:SetPos(subMenus.aimbot:GetWide() * 0.6, subMenus.aimbot:GetTall() * 0.025)
        jobSelectBox:SetSize(subMenus.aimbot:GetWide() * 0.125, subMenus.aimbot:GetTall() * 0.025)
        jobSelectBox:SetValue("Ignore Jobs")

        local jobTable = {}
        if (bDarkRP) then 
        for _, v in pairs(getAllPlayers) do 
            if (table.HasValue(jobTable, v:getDarkRPVar("job"))) then continue end
            table.insert(jobTable, v:getDarkRPVar("job"))
            jobSelectBox:AddChoice(v:getDarkRPVar("job"))
        end
        jobSelectBox.OnSelect = function(index, value, data)
            szJobIgnore = data
            print (value)
        end 
        end

        local ignoreJobCheckBox = subMenus.aimbot:Add("DCheckBoxLabel")
        ignoreJobCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.6, subMenus.aimbot:GetTall() * 0.06)
        ignoreJobCheckBox:SetText("Ignore Job ON/OFF")
        function ignoreJobCheckBox:OnChange(val)
            if val then 
                bAimbotIgnoreJob = true
            else
                bAimbotIgnoreJob = false
            end
        end
    
        local aimbotCheckBox = subMenus.aimbot:Add("DCheckBoxLabel")
        aimbotCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.05, subMenus.aimbot:GetTall() * 0.025)
        aimbotCheckBox:SetText("Aimbot ON/OFF")
        function aimbotCheckBox:OnChange(val)
            if val then 
                bAimbotToggle = true
            else
                bAimbotToggle = false
            end
        end
    end

    aimbotButton.DoClick = function()
        ShowOnlySubMenu("aimbot")
    end

    local triggerbotButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)
    triggerbotButton:SetPos(triggerbotButton:GetX(), aimbotButton:GetTall())

    triggerbotButton.Paint = function(self, w, h)
        menuButtons.Paint(self, w, h)
        draw.DrawText("Triggerbot", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
    end

    if (subMenus.triggerbot == nil) then
        subMenus.triggerbot = vgui.Create("SubMenuPanel", mainMenuWindow)
        subMenus.triggerbot:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())

        if (subMenus.triggerbot != nil) then 
            local triggerbotCheckBox = subMenus.triggerbot:Add("DCheckBoxLabel")
            triggerbotCheckBox:SetPos(subMenus.triggerbot:GetWide() * 0.05, subMenus.triggerbot:GetTall() * 0.025)
            triggerbotCheckBox:SetText("Triggerbot ON/OFF")
            function triggerbotCheckBox:OnChange(val)
                if val then 
                    bTriggerbotToggle = true
                else
                    bTriggerbotToggle = false
                end
            end
        end
    end

    triggerbotButton.DoClick = function()
        ShowOnlySubMenu("triggerbot")
    end

    local espButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)
    espButton:SetPos(espButton:GetX(), aimbotButton:GetTall() * 2)

    espButton.Paint = function(self, w, h)
        menuButtons.Paint(self, w, h)
        draw.DrawText("ESP", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
    end

    if (subMenus.esp == nil) then
        subMenus.esp = vgui.Create("SubMenuPanel", mainMenuWindow)
        subMenus.esp:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())

        if (subMenus.esp != nil) then 
            local espCheckBox = subMenus.esp:Add("DCheckBoxLabel")
            espCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.025)
            espCheckBox:SetText("ESP ON/OFF")
            function espCheckBox:OnChange(val)
                if val then 
                    bESPToggle = true
                else
                    bESPToggle = false
                end
            end

            local espDrawVisibleCheckBox = subMenus.esp:Add("DCheckBoxLabel")
            espDrawVisibleCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.05)
            espDrawVisibleCheckBox:SetText("Only Visible ON/OFF")
            function espDrawVisibleCheckBox:OnChange(val)
                if val then 
                    bESPdrawVisible = true
                else
                    bESPdrawVisible = false
                end
            end

            local espColorPalette = subMenus.esp:Add("DColorMixer")
            espColorPalette:SetPos(subMenus.esp:GetWide() * 0.5, subMenus.esp:GetTall() * 0.025)
            espColorPalette:SetSize(subMenus.esp:GetWide() * 0.25, subMenus.esp:GetTall() * 0.25)
            function espColorPalette:ValueChanged(col) 
                ESPCustomColor = col
            end


            local espDrawFOVCircleCheckBox = subMenus.esp:Add("DCheckBoxLabel")
            espDrawFOVCircleCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.075)
            espDrawFOVCircleCheckBox:SetText("Draw FOV Circle ON/OFF")
            function espDrawFOVCircleCheckBox:OnChange(val)
                if val then 
                    bDrawFOVCircle = true
                else
                    bDrawFOVCircle = false
                end
            end

            local espCustomESPColorCheckBox = subMenus.esp:Add("DCheckBoxLabel")
            espCustomESPColorCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.125)
            espCustomESPColorCheckBox:SetText("Custom ESP Box Color ON/OFF")
            function espCustomESPColorCheckBox:OnChange(val)
                if val then 
                    bCustomESPColor = true
                else
                    bCustomESPColor = false
                end
            end

        end

    end

    espButton.DoClick = function()
        ShowOnlySubMenu("esp")
    end

end -- If Click on a button close all other SubMenuPanels, Need to stay the panel open when its closed, just hide it.

---------------------------- VGUI SHIT ----------------------------------

---------------------------- Aimbot ----------------------------------

function calcAngle(vFrom, vTo)

    local retAngles = Angle(0, 0, 0)

    local vOrigin = vTo - vFrom

    local hypotenuse = sqrt(vOrigin.x * vOrigin.x + vOrigin.y * vOrigin.y + vOrigin.z * vOrigin.z)

    retAngles.y = atan2(vOrigin.y, vOrigin.x) * radToDeg
    retAngles.x = -(asin(vOrigin.z / hypotenuse) * radToDeg)
    retAngles.z = 0

    retAngles:Normalize()

    return retAngles

end

function GetClosestByFov(myAngles)
    local closestDist = 1000000

    local retPlayer = nil

    for k, v in pairs(getAllPlayers) do 
        if (v == localPlayer or v == nil or v:Health() <= 0) then
            continue end 

        local entPos = v:GetPos()
        
        local cAngles = calcAngle(localPlayer:GetPos(), entPos)
            -- x left 0-180 right 0-180
        local currDist = math.abs(cAngles.x - myAngles.x) + math.abs(cAngles.y - myAngles.y)
        if (currDist < closestDist and currDist < fAimbotFOV) then 
            closestDist = currDist
            retPlayer = v
        end
        
    end
    return retPlayer
end

---------------------------- Aimbot ----------------------------------

---------------------------- ESP ----------------------------------
function calcBoundedBoxes(players)

    local vMin = players:OBBMins()
    local vMax = players:OBBMaxs()

    local points = {
        Vector(vMin.x, vMin.y, vMin.z), //blb
        Vector(vMin.x, vMax.y, vMin.z), //brb
        Vector(vMax.x, vMax.y, vMin.z), // frb
        Vector(vMax.x, vMin.y, vMin.z), // flb
        Vector(vMax.x, vMax.y, vMax.z), // frt
        Vector(vMin.x, vMax.y, vMax.z), // brt
        Vector(vMin.x, vMin.y, vMax.z), // blt
        Vector(vMax.x, vMin.y, vMax.z), // flt
    }

    local x, y, w, h = nil

    for key, v in pairs(points) do 
        local screenPos = players:LocalToWorld( v ):ToScreen()
        if (x != nil) then 
            x = math.max( x, screenPos.x )
            y = math.max( y, screenPos.y)
            w = math.min( w, screenPos.x)
            h = math.min( h, screenPos.y)
        else 
            x, y, w, h = screenPos.x, screenPos.y, screenPos.x, screenPos.y
        end
    end
    return x, y, w, h
end
---------------------------- ESP ----------------------------------

---------------------------- MISC ----------------------------------

function IsVisible(pEnt)
    local tr = util.TraceLine( 
        {
            start = localPlayer:EyePos(),
            endpos = pEnt:EyePos(),
            filter = function(ent)
                if (IsValid(ent) and ent != localPlayer and ent:IsPlayer() and ent:Health() <= 0 and ent == pEnt) then 
                    return ent
                end
            end,
            mask = MASK_SHOT_HULL,
        }
    )
    return !tr.Hit
end

function IsShootable(pEnt)
    local tr = util.TraceLine( 
        {
            start = localPlayer:EyePos(),
            endpos = pEnt:EyePos(),
            filter = function(ent)
                if (IsValid(ent) and ent != localPlayer and ent:IsPlayer() and ent:Health() <= 0 and ent == pEnt) then 
                    return ent
                end
            end,
            mask = MASK_SHOT,
        }
    )
    return !tr.Hit
end

function IsPlayerInSight()
    local shootPos = localPlayer:GetShootPos() -- The position from which the trace starts
    local aimVector = localPlayer:GetAimVector() -- The direction the player is aiming

    local trace = util.TraceLine({
        start = shootPos,
        endpos = shootPos + aimVector * 10000, -- Trace forward in the aim direction for a long distance
        filter = localPlayer -- Make sure the trace doesn't hit the player themselves
    })

    if trace.Hit and IsValid(trace.Entity) and trace.Entity:IsPlayer() then
        return true
    else
        return false
    end
end
---------------------------- MISC ----------------------------------

---------------------------- HOOKS ----------------------------------
hook.Add("CreateMove", "CreateMoveHook", function(cmd)

    if (bAimbotToggle) then 
        if (input.IsButtonDown(MOUSE_5)) then
            local closestEnt = GetClosestByFov(cmd:GetViewAngles())
            if (closestEnt == nil) then return end
            if (bAimbotIgnoreJob and bDarkRP and closestEnt:getDarkRPVar("job") == szJobIgnore) then return end
            -- Aimbot Code Goes Here
            local matrix = closestEnt:GetBoneMatrix(closestEnt:LookupBone("ValveBiped.Bip01_Head1")) -- head
            local pos = matrix:GetTranslation()
            local aimbotAngles = calcAngle(localPlayer:EyePos(), pos)
            if (bAimbotLOS and !IsShootable(closestEnt)) then return end
            cmd:SetViewAngles( Angle(aimbotAngles.x, aimbotAngles.y, aimbotAngles.z) )
        end
    end

    if (bTriggerbotToggle) then 
        if (IsPlayerInSight() && input.IsButtonDown(MOUSE_5)) then
            timer.Simple(0.075, function() end)
            cmd:SetButtons(IN_ATTACK)
        end
    end

    if (bRecoilToggle) then 
        local wep = localPlayer:GetActiveWeapon()
        if (wep:GetClass()[1] == "m" and wep:GetClass()[2] == "9" and wep:GetClass()[3] == "k") then 
            if (wep.Primary != nil and wep.Primary.KickUp != nil and  wep.Primary.KickDown != nil and wep.Primary.KickHorizontal != nil 
            and wep.Primary.IronAccuracy != nil and wep.Secondary.IronFOV != nil) then 
    
                wep.Primary.KickUp  = 0
                wep.Primary.KickDown = 0      -- Maximum down recoil (skeet)
                wep.Primary.KickHorizontal = 0       --
                wep.Primary.IronAccuracy = 0
                wep.Secondary.IronFOV = 120
    
            end
            wep.ViewModelFOV = 120
        end
    end

end)

hook.Add("Think", "InputCheck", function()
    if (input.IsKeyDown(KEY_INSERT) and !bMenuOpen and !bToggleDelay) then 

        if (IsValid(mainMenuWindow) and !mainMenuWindow:IsVisible()) then
            mainMenuWindow:Show()
        else
            drawMenu()
        end

        bMenuOpen = true

        bToggleDelay = !bToggleDelay

        bToggle = !bToggle

        timer.Simple( 0.5, function() bToggleDelay = !bToggleDelay end)

    elseif (input.IsKeyDown(KEY_INSERT) and bMenuOpen and !bToggleDelay) then

        bMenuOpen = false

        if (IsValid(mainMenuWindow)) then
            mainMenuWindow:Hide()
        end

        bToggleDelay = !bToggleDelay

        bToggle = !bToggle

        timer.Simple( 0.5, function() bToggleDelay = !bToggleDelay end)

    end

end)

hook.Add( "HUDPaint", "DrawHUD", function()
    
    if (bESPToggle) then  
        
        if (bDrawFOVCircle) then surface.DrawCircle( screenMiddleX, screenMiddleY, fAimbotFOV * 10, Color( 255, 120, 0 ) ) end

        for k, players in pairs (getAllPlayers) do 
            if (players == localPlayer or players == nil or players:Health() <= 0) then continue end
            if (bESPdrawVisible) then if (!IsVisible(players)) then continue end end
            if (IsVisible(players)) then ESPColor = ESPColorVisible else ESPColor = ESPColorInvisible end
            if (bCustomESPColor) then ESPColor = ESPCustomColor end
            local right, down, left, up = calcBoundedBoxes(players) -- x = right, y = down, w = left, h = up
            surface.SetDrawColor(ESPColor)
            surface.DrawLine(left, down, left, up)
            surface.DrawLine(left, up, right, up)
            surface.DrawLine(right, up, right, down)
            surface.DrawLine(right, down, left, down)
            if (bDarkRP) then 
                draw.SimpleText("Job: " .. players:getDarkRPVar("job"), "espfont", (left + right) * .5, down + 40, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("RP-NAME: "..players:getDarkRPVar("rpname"), "espfont", (left + right) * .5, up - 25, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            draw.SimpleText("STEAM-NAME: "..players:GetName(), "espfont", (left + right) * .5, up - 10, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("HP: " .. tostring(players:Health()), "espfont", (left + right) * .5, down + 10, CcolWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("weapon: " .. players:GetActiveWeapon():GetPrintName(), "espfont", (left + right) * .5, down + 25, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end    
    end
    
end )

---------------------------- HOOKS ----------------------------------
