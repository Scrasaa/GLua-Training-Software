---------------------------- GLOBAL VARS ----------------------------------
local scrW = ScrW()
local scrH = ScrH()

local localPlayer = LocalPlayer()

local bMenuOpen = false

local mainMenuWindow = {}

local bToggle = false

local bToggleDelay = false

local szMenuTitle = "ScrasaHook - Dev Build [0.0.1]"

--------------------------------- SETTINGS ------------------------------------------
local bESPToggle = false
local bESPdrawVisible = false
local ESPColorVisible = Color(0, 255, 0, 255)
local ESPColorInvisible = Color(255, 0, 0, 255)
local bDrawFOVCircle = false

local bAimbotToggle = false
local bRecoilToggle = false
local bAimbotIgnoreJob = false
local szJobIgnore = ""
local fAimbotFOV = 10
---------------------------- GLOBAL VARS ----------------------------------
function centerTxtX(width, szString)
    local strLen = string.len(szString)
    local centerX = (width / 2)  - strLen * 4.5
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
        surface.SetTextColor(255,100,0,255)
        surface.SetTextPos(centerTxtX(w, szMenuTitle), h * 0.1)
        surface.DrawText(szMenuTitle)
    end

----------------------------MENU SIDE PANEL-------------------------------

    local menuSidePanel = vgui.Create("DPanel", mainMenuWindow)
    menuSidePanel:SetPos(0, menuBar:GetTall())
    menuSidePanel:SetSize(mainMenuWindow:GetWide() * 0.2, mainMenuWindow:GetTall() - menuBar:GetTall())

    menuSidePanel.Paint = function(self, w, h)
        surface.SetDrawColor(75,75,75)
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
        surface.SetDrawColor(55, 55, 55, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 136, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
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

-----------------------------SETUP MENU------------------------------

    local aimbotButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)

    local bTestPressed = false

    local aimbotSubMenu = nil
    local espSubMenu = nil

    aimbotButton.Paint = function(self, w, h)
        surface.SetDrawColor(55, 55, 55, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 136, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.DrawText("Aimbot", "fMenuTitle", self:GetWide() / 2, self:GetTall() / 5, Color(255, 136, 0), TEXT_ALIGN_CENTER)
    end

    aimbotButton.DoClick = function()
        if (bTestPressed == false) then
            if (aimbotSubMenu == nil) then
                aimbotSubMenu = vgui.Create("SubMenuPanel", mainMenuWindow)
                aimbotSubMenu:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())   


                local aimbotFovSlider = aimbotSubMenu:Add("DNumSlider")
                aimbotFovSlider:SetPos(aimbotSubMenu:GetWide() * 0.05, aimbotSubMenu:GetTall() * 0.05)
                aimbotFovSlider:SetSize(aimbotSubMenu:GetWide() * 0.5, aimbotSubMenu:GetTall() * 0.1)
                aimbotFovSlider:SetText("Aimbot FOV")
                aimbotFovSlider:SetMin(0)
                aimbotFovSlider:SetMax(360)

                aimbotFovSlider.OnValueChanged = function(self, value)
                    fAimbotFOV = value
                end
                bAimbotFovSliderCreated = true
            

                local recoilCheckBox = aimbotSubMenu:Add("DCheckBoxLabel")
                recoilCheckBox:SetPos(aimbotSubMenu:GetWide() * 0.05, aimbotSubMenu:GetTall() * 0.06)
                recoilCheckBox:SetText("Recoil ON/OFF (M9K ONLY)")
                function recoilCheckBox:OnChange(val)
                    if val then 
                        bRecoilToggle = true
                    else
                        bRecoilToggle = false
                    end
                end

                local jobSelectBox = aimbotSubMenu:Add("DComboBox")
                jobSelectBox:SetPos(aimbotSubMenu:GetWide() * 0.6, aimbotSubMenu:GetTall() * 0.025)
                jobSelectBox:SetSize(aimbotSubMenu:GetWide() * 0.125, aimbotSubMenu:GetTall() * 0.025)
                jobSelectBox:SetValue("Ignore Jobs")

                local jobTable = {}

                for _, v in pairs(player.GetAll()) do 
                    if (table.HasValue(jobTable, v:getDarkRPVar("job"))) then continue end
                    table.insert(jobTable, v:getDarkRPVar("job"))
                    jobSelectBox:AddChoice(v:getDarkRPVar("job"))
                end
                jobSelectBox.OnSelect = function(index, value, data)
                    szJobIgnore = data
                    print (value)
                end

                local ignoreJobCheckBox = aimbotSubMenu:Add("DCheckBoxLabel")
                ignoreJobCheckBox:SetPos(aimbotSubMenu:GetWide() * 0.6, aimbotSubMenu:GetTall() * 0.06)
                ignoreJobCheckBox:SetText("Ignore Job ON/OFF")
                function ignoreJobCheckBox:OnChange(val)
                    if val then 
                        bAimbotIgnoreJob = true
                    else
                        bAimbotIgnoreJob = false
                    end
                end
            
                local aimbotCheckBox = aimbotSubMenu:Add("DCheckBoxLabel")
                aimbotCheckBox:SetPos(aimbotSubMenu:GetWide() * 0.05, aimbotSubMenu:GetTall() * 0.025)
                aimbotCheckBox:SetText("Aimbot ON/OFF")
                function aimbotCheckBox:OnChange(val)
                    if val then 
                        bAimbotToggle = true
                    else
                        bAimbotToggle = false
                    end
                end
            end
    
            bTestPressed = true
            if (IsValid(espSubMenu)) then 
                espSubMenu:Hide()
            end
            aimbotSubMenu:Show()
        else
            bTestPressed = false
            if (IsValid(aimbotSubMenu)) then
                aimbotSubMenu:Hide()
            end
        end
    end

    local espButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)
    espButton:SetPos(espButton:GetX(), aimbotButton:GetTall())

    espButton.Paint = function(self, w, h)
        surface.SetDrawColor(55, 55, 55, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 136, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.DrawText("ESP", "fMenuTitle", self:GetWide() / 2, self:GetTall() / 5, Color(255, 136, 0), TEXT_ALIGN_CENTER)
    end

    local bTestPressed2 = false

    espButton.DoClick = function()
        if (bTestPressed2 == false) then
            if (espSubMenu == nil) then
                espSubMenu = vgui.Create("SubMenuPanel", mainMenuWindow)
                espSubMenu:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())

                espSubMenu.Paint = function(self, w, h)
                    surface.SetDrawColor(50, 50, 50)
                    surface.DrawRect(0, 0, w, h)
                end

                
                if (espSubMenu != nil) then 
                    local espCheckBox = espSubMenu:Add("DCheckBoxLabel")
                    espCheckBox:SetPos(espSubMenu:GetWide() * 0.05, espSubMenu:GetTall() * 0.025)
                    espCheckBox:SetText("ESP ON/OFF")
                    function espCheckBox:OnChange(val)
                        if val then 
                            bESPToggle = true
                        else
                            bESPToggle = false
                        end
                    end

                    local espDrawVisibleCheckBox = espSubMenu:Add("DCheckBoxLabel")
                    espDrawVisibleCheckBox:SetPos(espSubMenu:GetWide() * 0.05, espSubMenu:GetTall() * 0.05)
                    espDrawVisibleCheckBox:SetText("Only Visible ON/OFF")
                    function espDrawVisibleCheckBox:OnChange(val)
                        if val then 
                            bESPdrawVisible = true
                        else
                            bESPdrawVisible = false
                        end
                    end


                    local espDrawFOVCircleCheckBox = espSubMenu:Add("DCheckBoxLabel")
                    espDrawFOVCircleCheckBox:SetPos(espSubMenu:GetWide() * 0.05, espSubMenu:GetTall() * 0.075)
                    espDrawFOVCircleCheckBox:SetText("Draw FOV Circle ON/OFF")
                    function espDrawFOVCircleCheckBox:OnChange(val)
                        if val then 
                            bDrawFOVCircle = true
                        else
                            bDrawFOVCircle = false
                        end
                    end
                end

            end
            -- Closes other subMenuPanel so its not drawing over it~ just a little performance
            bTestPressed2 = true
            if (IsValid(aimbotSubMenu) and aimbotSubMenu != nil) then 
                aimbotSubMenu:Hide()
            end
            espSubMenu:Show()
        else
            bTestPressed2 = false
            if (IsValid(espSubMenu)) then
                espSubMenu:Hide()
            end
        end
    end

end -- If Click on a button close all other SubMenuPanels, Need to stay the panel open when its closed, just hide it.

---------------------------- VGUI SHIT ----------------------------------

---------------------------- Aimbot ----------------------------------

function calcAngle(vFrom, vTo)

    local retAngles = Angle(0, 0, 0)

    local vOrigin = vTo - vFrom

    local hypotenuse = math.sqrt(vOrigin.x * vOrigin.x + vOrigin.y * vOrigin.y + vOrigin.z * vOrigin.z)

    retAngles.y = math.atan2(vOrigin.y, vOrigin.x) * (180 / 3.14)
    retAngles.x = -(math.asin(vOrigin.z / hypotenuse) * (180 / 3.14))
    retAngles.z = 0

    -- x = pitch up down
    -- y = yaw left right

    retAngles:Normalize()

    return retAngles

end

function GetClosestByFov(myAngles)
    local playerList = FindMetaTable("Player")
    local closestDist = 1000000

    local screenMiddleX = ScrW() / 2
    local screenMiddleY = ScrH() / 2

    local retPlayer = nil

    for k, v in pairs(player.GetAll()) do 
        if (v == LocalPlayer() or v == nil or v:Health() <= 0) then
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
---------------------------- MISC ----------------------------------

---------------------------- HOOKS ----------------------------------

hook.Add("CreateMove", "CreateMoveHook", function(cmd)

    if (input.IsShiftDown()) then 
        if (bAimbotToggle) then
            local closestEnt = GetClosestByFov(cmd:GetViewAngles())
            if (closestEnt == nil) then return end
            if (bAimbotIgnoreJob and closestEnt:getDarkRPVar("job") == szJobIgnore) then return end
            -- Aimbot Code Goes Here
            local matrix = closestEnt:GetBoneMatrix(closestEnt:LookupBone("ValveBiped.Bip01_Head1")) -- head
            local pos = matrix:GetTranslation()
            local aimbotAngles = calcAngle(localPlayer:EyePos(), pos)
            cmd:SetViewAngles( Angle(aimbotAngles.x, aimbotAngles.y, aimbotAngles.z) )
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

hook.Add("Tick", "InputCheck", function()

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

    --("Ent is visible: " .. tostring(IsVisible(Entity(2))) .. " Ent Name: " .. Entity(2):GetName())
    

end)

hook.Add( "HUDPaint", "DrawHUD", function()
    
    if (bESPToggle) then  
        
        if (bDrawFOVCircle) then surface.DrawCircle( ScrW()/2, ScrH()/2, fAimbotFOV * 10, Color( 255, 120, 0 ) ) end

        local color = Color(255, 255, 255, 255)

        for k, players in pairs (player.GetAll()) do 
            if (players == localPlayer or players == nil or players:Health() <= 0) then continue end
            if (bESPdrawVisible) then if (!IsVisible(players)) then continue end end
            if (IsVisible(players)) then  color = ESPColorVisible else color = ESPColorInvisible end
            local right, down, left, up = calcBoundedBoxes(players) -- x = right, y = down, w = left, h = up
            surface.SetDrawColor(color)
            surface.DrawLine(left, down, left, up)
            surface.DrawLine(left, up, right, up)
            surface.DrawLine(right, up, right, down)
            surface.DrawLine(right, down, left, down)
            draw.SimpleText("STEAM-NAME: "..players:GetName(), "espfont", (left + right) / 2, up - 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("RP-NAME: "..players:getDarkRPVar("rpname"), "espfont", (left + right) / 2, up - 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("HP: " .. tostring(players:Health()), "espfont", (left + right) / 2, down + 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("weapon: " .. players:GetActiveWeapon():GetPrintName(), "espfont", (left + right) / 2, down + 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Job: " .. players:getDarkRPVar("job"), "espfont", (left + right) / 2, down + 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end    
    end
    
end )

---------------------------- HOOKS ----------------------------------
