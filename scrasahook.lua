---------------------------- GLOBAL VARS ----------------------------------
local bMenuOpen = false
local mainMenuWindow = {}
local bToggle = false
local bToggleDelay = false

local szMenuTitle = "ScrasaHook[0.0.3]"
local colWhite = Color(255,255,255,255)

local settings = {}

settings.bESPToggle = false
settings.bESPDrawBox = false
settings.bESPdrawVisible = false
settings.bESPDrawCustomColor = false
settings.bDrawLinesToPlayers = false 
settings.bDrawSkeleton = false
settings.bDrawFOVCircle = false

local fAimbotFOV = 10
settings.bAimbotToggle = false
settings.bRecoilToggle = false
settings.bAimbotIgnoreJob = false
settings.bAimbotLOS = false

settings.bTriggerbotToggle = false
local iTriggerbotDelay = 75

settings.bBunnyhop = false
settings.bFlashlightSpam = false

local ESPColor = colWhite
local ESPCustomColor = colWhite
local ESPColorVisible = Color(0, 255, 0, 255)
local ESPColorInvisible = Color(255, 0, 0, 255)
local szJobIgnore = ""

local bDarkRP = false 
local jobs = RPExtraTeams or {}
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
    esp = nil,
    misc = nil,
    config = nil,
    feels = nil
}

----------------------- EFFICIENTY -------------------------------------------------
local scrW = ScrW()
local scrH = ScrH()
local localPlayer = LocalPlayer()

local radToDeg = 180 / math.pi
local sqrt = math.sqrt
local tan = math.tan
local atan2 = math.atan2
local asin = math.asin
local rad = math.rad
local currentTime = CurTime()
local getAllPlayers = player.GetAll()

local screenMiddleX = scrW * .5
local screenMiddleY = scrH * .5

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
---------------------------- OTHER FUNCTIONS ----------------------------------
function loadSettings()
    -- Check if the file exists before attempting to read
    if not file.Exists("config.txt", "DATA") then
        return nil, "File does not exist."
    end

    -- Read the content of the file
    local content = file.Read("config.txt", "DATA")
    local lines = string.Split(content, "\n")

    for _, line in ipairs(lines) do
        -- Use string.match to separate each line into key and value
        local key, value = string.match(line, "([^=]+)=([^=]+)")
        if key and value ~= nil then
            -- Attempt to convert value to a number, if it fails, keep it as string
            value = value
            settings[key] = value
        end
    end

    print("Successfully read all settings.")
    -- Set all values of the panels to the loaded values
end

function GetRainbowColor(param)
    local frequency = 0.5
    local phase = 0.6
    local center = 128
    local width = 127

    local red = math.sin(frequency * param + 2 + phase) * width + center
    local green = math.sin(frequency * param + 0 + phase) * width + center
    local blue = math.sin(frequency * param + 4 + phase) * width + center

    return Color(red, green, blue)
end

function centerTxtX(width, szString)
    local strLen = string.len(szString)
    local centerX = (width * .5)  - strLen * 4.5
    return centerX
end
---------------------------- FONT SHIT ----------------------------------
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

------------------- CUSTOM VGUI SHIT ------------------------------------

local ScrasCheckBoxLabel = {}

function ScrasCheckBoxLabel:Init()
    self.color = Color(25, 25, 25)
    self.active = false
    self.sound = "buttons/button14.wav"
    self:SetSize(self:GetParent():GetWide() * .075, self:GetParent():GetTall() * 0.04)

    self.button = vgui.Create("DButton", self)
    self.button:SetSize(self:GetWide() * .35, self:GetTall() * .75)
    self.button:SetText("")

    self.button.OnMousePressed = function()
        surface.PlaySound(self.sound)
        self.active = not self.active
        self:DoClick()
    end

    self.button.Paint = function(btn, w, h)
        if self.active then
            surface.SetDrawColor(50, 205, 50)
        else
            surface.SetDrawColor(Color(25, 25, 25))
        end
        surface.DrawRect(0, 0, w, h)
    end

    -- Create the label
    self.label = vgui.Create("DLabel", self)
    self.label:SetPos(self.button:GetWide() + 5,  self.button:GetTall() * 0.225 - self.label:GetTall() * 0.5)
    self.label:SetSize(self:GetWide() + self.button:GetWide() * 4, self.button:GetTall() * 1.5)
    self.label:SetFont("DermaDefault")
    self.label:SetTextColor(Color(255, 255, 255))

end
-- work around to call DoClick for the button
function ScrasCheckBoxLabel:DoClick()
    baseclass.Get("DButton"):DoClick()
end

function ScrasCheckBoxLabel:PerformLayout()
    self:SetWide(self.button:GetWide() + 5 + self.label:GetWide())
end

function ScrasCheckBoxLabel:SetText(text)
    self.label:SetText(text)
end

function ScrasCheckBoxLabel:Paint(w, h)

end

vgui.Register("ScrasCheckBoxLabel", ScrasCheckBoxLabel, "DPanel")
---------------------------- MAIN FRAME --------------------------------

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
        surface.SetTextColor(GetRainbowColor(CurTime() - currentTime))
        
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
            if not self.soundPlayed then
                surface.PlaySound("common/wpn_select.wav")
                self.soundPlayed = true -- Set a flag indicating that the sound has been played
            end
        else
            self.animProgress = math.max(self.animProgress - FrameTime() * 3, 0)
            self.soundPlayed = false -- Reset the flag when the button is not hovered
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

        local aimbotLOSCheckBox = subMenus.aimbot:Add("ScrasCheckBoxLabel")
        aimbotLOSCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.05, subMenus.aimbot:GetTall() * 0.125)
        aimbotLOSCheckBox:SetText("Visibility Check")
        aimbotLOSCheckBox.DoClick = function() 
            settings.bAimbotLOS = not settings.bAimbotLOS
        end

        local recoilCheckBox = subMenus.aimbot:Add("ScrasCheckBoxLabel")
        recoilCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.05, subMenus.aimbot:GetTall() * 0.06)
        recoilCheckBox:SetText("Toggle Recoil (M9K & more)")
        recoilCheckBox.DoClick = function()
            settings.bRecoilToggle = not settings.bRecoilToggle
        end

        local jobSelectBox = subMenus.aimbot:Add("DComboBox")
        jobSelectBox:SetPos(subMenus.aimbot:GetWide() * 0.6, subMenus.aimbot:GetTall() * 0.025)
        jobSelectBox:SetSize(subMenus.aimbot:GetWide() * 0.125, subMenus.aimbot:GetTall() * 0.025)
        jobSelectBox:SetValue("Ignore Jobs")

        local jobTable = {}
        if (bDarkRP) then 
        for _, v in pairs(jobs) do
            jobSelectBox:AddChoice(v.name)
        end
        jobSelectBox.OnSelect = function(index, value, data)
            szJobIgnore = data
        end 
        end

        local ignoreJobCheckBox = subMenus.aimbot:Add("ScrasCheckBoxLabel")
        ignoreJobCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.6, subMenus.aimbot:GetTall() * 0.06)
        ignoreJobCheckBox:SetText("Ignore Job")
        ignoreJobCheckBox.DoClick = function()
            settings.bAimbotIgnoreJob = not settings.bAimbotIgnoreJob
        end
    
        local aimbotCheckBox = subMenus.aimbot:Add("ScrasCheckBoxLabel")
        aimbotCheckBox:SetPos(subMenus.aimbot:GetWide() * 0.05, subMenus.aimbot:GetTall() * 0.025)
        aimbotCheckBox:SetText("Toggle Aimbot")
        aimbotCheckBox.DoClick = function()
            settings.bAimbotToggle = not settings.bAimbotToggle
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
            local triggerbotCheckBox = subMenus.triggerbot:Add("ScrasCheckBoxLabel")
            triggerbotCheckBox:SetPos(subMenus.triggerbot:GetWide() * 0.05, subMenus.triggerbot:GetTall() * 0.025)
            triggerbotCheckBox:SetText("Toggle Triggerbot")
            triggerbotCheckBox.DoClick = function()
                settings.bTriggerbot = not settings.bTriggerbot
            end

            local triggerbotDelaySlider = subMenus.triggerbot:Add("DNumSlider")
            triggerbotDelaySlider:SetPos(subMenus.triggerbot:GetWide() * 0.05, subMenus.triggerbot:GetTall() * 0.06)
            triggerbotDelaySlider:SetSize(subMenus.triggerbot:GetWide() * 0.525, subMenus.triggerbot:GetTall() * 0.035)
            triggerbotDelaySlider:SetMinMax(0, 1000)
            triggerbotDelaySlider:SetText("Triggerbot Delay in ms")
            triggerbotDelaySlider:SetValue(0)
            triggerbotDelaySlider:SetDecimals(0)
            triggerbotDelaySlider.OnValueChanged = function(self ,val)
                iTriggerbotDelay = val * 0.001
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
            local espCheckBox = subMenus.esp:Add("ScrasCheckBoxLabel")
            espCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.025)
            espCheckBox:SetText("Toggle Visuals")
            espCheckBox.DoClick = function()
                settings.bESPToggle = not settings.bESPToggle
            end

            local espDrawBoxCheckBox = subMenus.esp:Add("ScrasCheckBoxLabel")
            espDrawBoxCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.075)
            espDrawBoxCheckBox:SetText("Draw 2D ESP Box")
            espDrawBoxCheckBox.DoClick = function()
                settings.bESPDrawBox = not settings.bESPDrawBox
            end

            local espDrawVisibleCheckBox = subMenus.esp:Add("ScrasCheckBoxLabel")
            espDrawVisibleCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.125)
            espDrawVisibleCheckBox:SetText("Only Visible")
            espDrawVisibleCheckBox.DoClick = function()
                settings.bESPdrawVisible = not settings.bESPdrawVisible
            end

            local espColorPalette = subMenus.esp:Add("DColorMixer")
            espColorPalette:SetPos(subMenus.esp:GetWide() * 0.25, subMenus.esp:GetTall() * 0.02)
            espColorPalette:SetSize(subMenus.esp:GetWide() * 0.25, subMenus.esp:GetTall() * 0.25)
            function espColorPalette:ValueChanged(col) 
                ESPCustomColor = col
            end

            espColorPalette:Hide()

            local espDrawFOVCircleCheckBox = subMenus.esp:Add("ScrasCheckBoxLabel")
            espDrawFOVCircleCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.175)
            espDrawFOVCircleCheckBox:SetText("Draw FOV Circle")
            espDrawFOVCircleCheckBox.DoClick = function()
                settings.bDrawFOVCircle = not settings.bDrawFOVCircle
            end

            local espCustomESPColorCheckBox = subMenus.esp:Add("ScrasCheckBoxLabel")
            espCustomESPColorCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.225)
            espCustomESPColorCheckBox:SetText("Use Custom ESP Box Color")
            espCustomESPColorCheckBox.DoClick = function()
                settings.bESPDrawCustomColor = not settings.bESPDrawCustomColor
                if (settings.bESPDrawCustomColor and IsValid(espColorPalette)) then
                    espColorPalette:Show()
                else 
                    espColorPalette:Hide()
                end
            end

            local espDrawLinesToPlayersCheckBox = subMenus.esp:Add("ScrasCheckBoxLabel")
            espDrawLinesToPlayersCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.275)
            espDrawLinesToPlayersCheckBox:SetText("Draw Snaplines")
            espDrawLinesToPlayersCheckBox.DoClick = function()
                settings.bDrawLinesToPlayers = not settings.bDrawLinesToPlayers
            end

            local espDrawSkeletonCheckBox = subMenus.esp:Add("ScrasCheckBoxLabel")
            espDrawSkeletonCheckBox:SetPos(subMenus.esp:GetWide() * 0.05, subMenus.esp:GetTall() * 0.325)
            espDrawSkeletonCheckBox:SetText("Draw Skeleton")
            espDrawSkeletonCheckBox.DoClick = function()
                settings.bDrawSkeleton = not settings.bDrawSkeleton
            end

        end

    end

    espButton.DoClick = function()
        ShowOnlySubMenu("esp")
    end

    local miscButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)
    miscButton:SetPos(miscButton:GetX(), aimbotButton:GetTall() * 3)

    miscButton.Paint = function(self, w, h)
        menuButtons.Paint(self, w, h)
        draw.DrawText("Misc", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
    end

    if (subMenus.misc == nil) then 
        subMenus.misc = vgui.Create("SubMenuPanel", mainMenuWindow)
        subMenus.misc:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())

        if (subMenus.misc != nil) then 
            local miscBunnyHopCheckBox = subMenus.misc:Add("ScrasCheckBoxLabel")
            miscBunnyHopCheckBox:SetPos(subMenus.misc:GetWide() * 0.05, subMenus.misc:GetTall() * 0.025)
            miscBunnyHopCheckBox:SetText("Toggle Bunnyhop")
            miscBunnyHopCheckBox.DoClick = function()
                settings.bBunnyhop = not settings.bBunnyhop
            end

            local miscFlashLightSpamCheckBox = subMenus.misc:Add("ScrasCheckBoxLabel")
            miscFlashLightSpamCheckBox:SetPos(subMenus.misc:GetWide() * 0.05, subMenus.misc:GetTall() * 0.075)
            miscFlashLightSpamCheckBox:SetText("Flashlight Spam")
            miscFlashLightSpamCheckBox.DoClick = function()
                settings.bFlashlightSpam = not settings.bFlashlightSpam
            end
        end
    end

    miscButton.DoClick = function()
        ShowOnlySubMenu("misc")
    end

    local configButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)
    configButton:SetPos(configButton:GetX(), aimbotButton:GetTall() * 4)

    configButton.Paint = function(self, w, h)
        menuButtons.Paint(self, w, h)
        draw.DrawText("Config", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
    end

    if (subMenus.config == nil) then 
        subMenus.config = vgui.Create("SubMenuPanel", mainMenuWindow)
        subMenus.config:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())

        if (subMenus.config != nil) then 
            local configSaveButton = vgui.Create("MenuButtonSidePanel", subMenus.config) 
            configSaveButton:SetPos(subMenus.config:GetWide() * .375, subMenus.config:GetTall() * 0.025)
            configSaveButton:SetSize(subMenus.config:GetWide() * 0.25, subMenus.config:GetTall() * 0.05)

            configSaveButton.DoClick = function()
                saveSettings(settings)
            end

            configSaveButton.Paint = function(self, w, h)
                menuButtons.Paint(self, w, h)
                draw.DrawText("Save Config", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
            end

            local configLoadButton = vgui.Create("MenuButtonSidePanel", subMenus.config)
            configLoadButton:SetPos(subMenus.config:GetWide() * .375, subMenus.config:GetTall() * 0.1)
            configLoadButton:SetSize(subMenus.config:GetWide() * 0.25, subMenus.config:GetTall() * 0.05)

            configLoadButton.Paint = function(self, w, h)
                menuButtons.Paint(self, w, h)
                draw.DrawText("Load Config", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
            end

            configLoadButton.DoClick = function()
                loadSettings()
            end
        end

    end

    configButton.DoClick = function()
        ShowOnlySubMenu("config")
    end

    local feelsButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)
    feelsButton:SetPos(feelsButton:GetX(), aimbotButton:GetTall() * 5)

    feelsButton.Paint = function(self, w, h)
        menuButtons.Paint(self, w, h)
        draw.DrawText("Feels", "fMenuTitle", self:GetWide() * .5, self:GetTall() * .2, subMenuButtonTextColor, TEXT_ALIGN_CENTER)
    end

    if (subMenus.feels == nil) then 
        subMenus.feels = vgui.Create("SubMenuPanel", mainMenuWindow)
        subMenus.feels:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())

        if (subMenus.feels != nil) then 
            local html = vgui.Create("DHTML", subMenus.feels)
            html:SetSize(subMenus.feels:GetWide(), subMenus.feels:GetTall())
            html:OpenURL("https://www.youtube.com/embed/IJs81BcpvFY?autoplay=0&controls=1")
        end
    end

    feelsButton.DoClick = function()
        ShowOnlySubMenu("feels")
    end

end
---------------------------- Aimbot  STUFF ----------------------------------
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

---------------------------- ESP STUFF ----------------------------------
function GetHealthColor(entity)
    if not entity or not entity:IsValid() or not entity:Health() or not entity:IsPlayer() then
        return Color(255, 0, 0) -- Return red if the entity is invalid or has no health method
    end

    local maxHealth = entity:GetMaxHealth() or 100 -- Fallback to 100 if GetMaxHealth is not defined
    local health = math.Clamp(entity:Health(), 0, maxHealth) -- Ensure health is within the range
    local healthFraction = health / maxHealth

    -- Interpolate between green and red based on the health fraction
    local red = 255 * (1 - healthFraction)
    local green = 255 * healthFraction
    local blue = 0 -- No blue component

    return Color(red, green, blue)
end

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

function DrawSkeleton(player)
    local boneCount = player:GetBoneCount()
    surface.SetDrawColor(255, 255, 255, 255)

    for boneIndex = 0, boneCount - 1 do
        local boneName = player:GetBoneName(boneIndex)
        local bonePos, boneAng = player:GetBonePosition(boneIndex)
        local parentIndex = player:GetBoneParent(boneIndex)

        if bonePos and bonePos ~= player:GetPos() and parentIndex ~= -1 then
            local parentPos, parentAng = player:GetBonePosition(parentIndex)

            local boneScreenPos = bonePos:ToScreen()
            local parentScreenPos = parentPos:ToScreen()

            if boneScreenPos.visible and parentScreenPos.visible then
                surface.DrawLine(boneScreenPos.x, boneScreenPos.y, parentScreenPos.x, parentScreenPos.y)
            end
        end
    end
end
---------------------------- MISC ----------------------------------
function FlashLightSpam() 
    if settings.bFlashlightSpam then
        if input.IsKeyDown(KEY_F) then
            RunConsoleCommand("impulse", "100")
            return
        end
    end
end

hook.Add("Think", "FlashLightSpam", FlashLightSpam)

function Bunnyhop()
    if settings.bBunnyhop then
        if input.IsKeyDown(KEY_SPACE) and localPlayer:IsOnGround() then 
            RunConsoleCommand("+jump")
            timer.Simple(0.01, function() RunConsoleCommand("-jump") end)
        end 
    end
end

hook.Add("CreateMove", "Bhop", Bunnyhop)

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
---------------------------- HOOKS ----------------------------------

local lastShotTime = 0
hook.Add("CreateMove", "CreateMoveHook", function(cmd)

    if (settings.bAimbotToggle) then 
        if (input.IsButtonDown(MOUSE_5)) then
            local closestEnt, aimbotTarget = GetClosestByFov(cmd:GetViewAngles())
            if (closestEnt == nil) then return end
            if (settings.bAimbotIgnoreJob and bDarkRP and closestEnt:getDarkRPVar("job") == szJobIgnore) then return end
            local matrix = closestEnt:GetBoneMatrix(closestEnt:LookupBone("ValveBiped.Bip01_Head1")) -- head
            local pos = matrix:GetTranslation()
            local aimbotAngles = calcAngle(localPlayer:EyePos(), pos)
            local oldAngles = cmd:GetViewAngles()
            if (settings.bAimbotLOS and !IsShootable(closestEnt)) then return end
            cmd:SetViewAngles( Angle(aimbotAngles.x, aimbotAngles.y, aimbotAngles.z) )
        end
    end

    if (settings.bTriggerbot and input.IsButtonDown(MOUSE_5)) then
        if (IsPlayerInSight()) then 
            cmd:SetButtons( bit.bor(cmd:GetButtons(), IN_ATTACK))
            timer.Simple( iTriggerbotDelay, function() RunConsoleCommand( "-attack" ) end )
        end
    end

    if (settings.bRecoilToggle) then 
        local wep = localPlayer:GetActiveWeapon()
        if (not IsValid(wep)) then return end
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
    
    if (settings.bESPToggle) then  
        if (settings.bDrawFOVCircle) then
            local X1 = tan( rad(fAimbotFOV ) * .8 )
            local X2 = tan( rad( localPlayer:GetFOV() * .5 ) )
            local r = X1 / X2
            local pxR = r * ( screenMiddleX )
            surface.DrawCircle(screenMiddleX, screenMiddleY, pxR, Color( 255, 120, 0 ))
        end

        for k, players in pairs (getAllPlayers) do 
            if (players == localPlayer or players == nil or players:Health() <= 0) then continue end
            if (settings.bESPdrawVisible) then if (!IsVisible(players)) then continue end end
            if (IsVisible(players)) then ESPColor = ESPColorVisible else ESPColor = ESPColorInvisible end
            if (settings.bDrawSkeleton) then DrawSkeleton(players) end
            if (settings.bESPDrawCustomColor) then ESPColor = ESPCustomColor end
            surface.SetDrawColor(ESPColor)
            local right, down, left, up = calcBoundedBoxes(players) -- x = right, y = down, w = left, h = up
            if (settings.bDrawLinesToPlayers) then surface.DrawLine(screenMiddleX, scrH, (left + right) * .5, down) end
            if (settings.bESPDrawBox) then 
                surface.DrawLine(left, down, left, up)
                surface.DrawLine(left, up, right, up)
                surface.DrawLine(right, up, right, down)
                surface.DrawLine(right, down, left, down)
                if (bDarkRP) then 
                    draw.SimpleText("Job: " .. players:getDarkRPVar("job"), "espfont", (left + right) * .5, down + 40, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("RP-NAME: "..players:getDarkRPVar("rpname"), "espfont", (left + right) * .5, up - 25, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                draw.SimpleText("STEAM-NAME: "..players:GetName(), "espfont", (left + right) * .5, up - 10, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("HP: " .. tostring(players:Health()), "espfont", (left + right) * .5, down + 10, GetHealthColor(players), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("weapon: " .. players:GetActiveWeapon():GetPrintName(), "espfont", (left + right) * .5, down + 25, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end    
    end
    
end )
