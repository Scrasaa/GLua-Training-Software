---------------------------- GLOBAL VARS ----------------------------------
local scrW = ScrW()
local scrH = ScrH()

local localPlayer = LocalPlayer()

local bMenuOpen = false

local mainMenuWindow = {}

local bToggle = false

local bToggleDelay = false

local szMenuTitle = "ScrasaHook - Dev Build [0.0.1]"

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

-----------------------------TEST BUTTON------------------------------

    local testButton = vgui.Create("MenuButtonSidePanel", menuSidePanel)

    local bTestPressed = false

    local testSubMenu = nil
    local testSubMenu2 = nil

    testButton.Paint = function(self, w, h)
        surface.SetDrawColor(55, 55, 55, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 136, 0, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.DrawText("Test1", "fMenuTitle", self:GetWide() / 2, self:GetTall() / 4, Color(255, 136, 0), TEXT_ALIGN_CENTER)
    end

    testButton.DoClick = function()
        if (bTestPressed == false) then
            if (testSubMenu == nil) then
                testSubMenu = vgui.Create("SubMenuPanel", mainMenuWindow)
                testSubMenu:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())   
            end
            bTestPressed = true
            if (IsValid(testSubMenu2) and testSubMenu2 != nil) then 
                testSubMenu2:Hide()
            end
            testSubMenu:Show()
        else
            bTestPressed = false
            if (IsValid(testSubMenu)) then
                testSubMenu:Hide()
            end
        end
    end


    local testButton2 = vgui.Create("MenuButtonSidePanel", menuSidePanel)
    testButton2:SetPos(testButton2:GetX(), testButton:GetTall() + 1)


    local bTestPressed2 = false

    testButton2.DoClick = function()
        if (bTestPressed2 == false) then
            if (testSubMenu2 == nil) then
                testSubMenu2 = vgui.Create("SubMenuPanel", mainMenuWindow)
                testSubMenu2:SetPos(menuSidePanel:GetWide(), menuBar:GetTall())

                testSubMenu2.Paint = function(self, w, h)
                    surface.SetDrawColor(50, 50, 50)
                    surface.DrawRect(0, 0, w, h)
                end
            end
            -- Closes other subMenuPanel so its not drawing over it~ just a little performance
            bTestPressed2 = true
            if (IsValid(testSubMenu) and testSubMenu != nil) then 
                testSubMenu:Hide()
            end
            testSubMenu2:Show()
        else
            bTestPressed2 = false
            if (IsValid(testSubMenu2)) then
                testSubMenu2:Hide()
            end
        end
    end

end -- If Click on a button close all other SubMenuPanels, Need to stay the panel open when its closed, just hide it.

---------------------------- VGUI SHIT ----------------------------------

---------------------------- HOOKS ----------------------------------

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
    
end)

---------------------------- HOOKS ----------------------------------
