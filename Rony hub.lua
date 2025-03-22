-- Script Mobile-Friendly RONY HUB
-- Certifique-se de que seu executor suporte HTTP requests

-- Funções de manipulação de strings e decriptação (mantidas do original)
local char = string.char
local byte = string.byte
local sub = string.sub
local bit_lib = bit32 or bit
local bxor = bit_lib.bxor
local concat = table.concat
local insert = table.insert

local function decrypt(encrypted, key)
    local result = {}
    for i = 1, #encrypted do
        insert(result, char(bxor(byte(sub(encrypted, i, i)), byte(sub(key, 1 + (i % #key), 1 + (i % #key))) ) % 256))
    end
    return concat(result)
end

-- Carrega a biblioteca de UI (use a mesma referência se funcionar no mobile)
local ui = loadstring(game:HttpGet('https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua'))()

-- Detecta se está em dispositivo móvel para ajustar tamanho e escala
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled

local windowSize = isMobile and UDim2.new(0.9,0,0.8,0) or UDim2.new(0,700,0,350)
local mainWindow = ui.new({
    text = 'RONY HUB',
    size = windowSize
})
mainWindow.open()

-- Aba Principal
local mainTab = mainWindow.new({
    text = 'Main',
    padding = Vector2.new(10, 10)
})

-- KillAura
local killAuraEnabled = false
local function toggleKillAura(enabled)
    killAuraEnabled = enabled
    if killAuraEnabled then
        print('KillAura enabled')
        spawn(function()
            while killAuraEnabled do
                pcall(function()
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('Combat')
                        :WaitForChild('M1')
                        :FireServer()
                end)
                task.wait(0.1)
            end
        end)
    else
        print('KillAura disabled')
    end
end

local killAuraSwitch = mainTab.new('switch', { text = 'KillAura' })
killAuraSwitch.set(false)
killAuraSwitch.event:Connect(toggleKillAura)

-- Seleção de Boss
local bossList = {
    ['Boss 1'] = 1, ['Boss 2'] = 2, ['Boss 3'] = 3, ['Boss 4'] = 4, ['Boss 5'] = 5,
    ['Boss 6'] = 6, ['Boss 7'] = 7, ['Boss 8'] = 8, ['Boss 9'] = 9, ['Boss 10'] = 10,
    ['Boss 11'] = 11, ['Boss 12'] = 12, ['Boss 13'] = 13, ['Boss 14'] = 14, ['Boss 15'] = 15,
    ['Boss 16'] = 16, ['Boss 17'] = 17, ['Boss 18'] = 18, ['Boss 19'] = 19
}
local selectedBoss = bossList['Boss 1']
local bossDropdown = mainTab.new('dropdown', {
    text = 'Select Boss',
    tooltip = 'Escolha qual boss desafiar automaticamente.'
})

local sortedBossList = {}
for name in pairs(bossList) do table.insert(sortedBossList, name) end
table.sort(sortedBossList, function(a, b) return bossList[a] < bossList[b] end)
for _, name in ipairs(sortedBossList) do bossDropdown.new(name) end

bossDropdown.event:Connect(function(selected)
    selectedBoss = bossList[selected]
    print('Selected boss:', selected)
end)

-- Auto Boss
local autoBossEnabled = false
local function toggleAutoBoss(enabled)
    autoBossEnabled = enabled
    if autoBossEnabled then
        spawn(function()
            while autoBossEnabled do
                pcall(function()
                    print('Challenging boss:', selectedBoss)
                    local args = { selectedBoss }
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('Combat')
                        :WaitForChild('[C-S]TryChallengeRoom')
                        :FireServer(unpack(args))
                end)
                task.wait(30)
            end
        end)
    end
end

local autoBossSwitch = mainTab.new('switch', {
    text = 'Auto Boss',
    tooltip = 'Desafia automaticamente o boss selecionado a cada 30 segundos.'
})
autoBossSwitch.set(false)
autoBossSwitch.event:Connect(toggleAutoBoss)
mainTab.new('label', { text = 'Certifique-se de estar preparado antes de habilitar Auto Boss!', color = Color3.new(1,0,0) })

-- Seleção de Raid
local raidList = {
    ['Raid 1'] = 1, ['Raid 2'] = 2, ['Raid 3'] = 3,
    ['Raid 4'] = 4, ['Raid 5'] = 5, ['Raid 6'] = 6
}
local selectedRaid = raidList['Raid 1']
local raidDropdown = mainTab.new('dropdown', {
    text = 'Select Raid',
    tooltip = 'Escolha qual raid auto-farmar.'
})

local sortedRaidList = {}
for name in pairs(raidList) do table.insert(sortedRaidList, name) end
table.sort(sortedRaidList, function(a, b) return raidList[a] < raidList[b] end)
for _, name in ipairs(sortedRaidList) do raidDropdown.new(name) end

raidDropdown.event:Connect(function(selected)
    selectedRaid = raidList[selected]
    print('Selected raid:', selected)
end)

-- Auto Raid
local autoRaidEnabled = false
local tweenService = game:GetService('TweenService')
local function moveToTarget(character, target)
    local targetCFrame = target.CFrame * CFrame.new(0, 0, 5)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = tweenService:Create(character, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
end

local function toggleAutoRaid(enabled)
    autoRaidEnabled = enabled
    if autoRaidEnabled then
        print('Auto Raid enabled')
        spawn(function()
            while autoRaidEnabled do
                pcall(function()
                    print('Joining raid:', selectedRaid)
                    local args = { selectedRaid }
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('Raid')
                        :WaitForChild('[C-S]TryStartRaid')
                        :FireServer(unpack(args))
                    task.wait(6)
                    
                    local player = game.Players.LocalPlayer
                    local mobsFolder = workspace.Combats.Mobs:FindFirstChild(player.Name)
                    local playerRoot = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
                    
                    if mobsFolder and playerRoot then
                        while autoRaidEnabled and mobsFolder:FindFirstChildOfClass('Model') do
                            local boss = mobsFolder:FindFirstChildOfClass('Model')
                            if boss and boss:FindFirstChild('HumanoidRootPart') then
                                print('Boss detectado. Movendo...')
                                moveToTarget(playerRoot, boss.HumanoidRootPart)
                            end
                            task.wait(1)
                        end
                        print('Boss derrotado. Abrindo chest drop.')
                        game:GetService('ReplicatedStorage')
                            :WaitForChild('Remote')
                            :WaitForChild('Event')
                            :WaitForChild('Raid')
                            :WaitForChild('[C-S]TryOpenChestDrop')
                            :FireServer()
                        task.wait(2)
                        print('Saindo da raid.')
                        game:GetService('ReplicatedStorage')
                            :WaitForChild('Remote')
                            :WaitForChild('Event')
                            :WaitForChild('Raid')
                            :WaitForChild('[C-S]TryLeaveRaid')
                            :FireServer()
                        task.wait(1)
                    else
                        print('Pasta de combate ou HumanoidRootPart não encontrado. Tentando novamente...')
                    end
                end)
                task.wait(2)
            end
        end)
    else
        print('Auto Raid disabled')
    end
end

local autoRaidSwitch = mainTab.new('switch', {
    text = 'Auto Raid',
    tooltip = 'Faz o farm automático da raid selecionada, juntando, combatendo e coletando recompensas.'
})
autoRaidSwitch.set(false)
autoRaidSwitch.event:Connect(toggleAutoRaid)
mainTab.new('label', { text = 'Você pode burlar os requisitos de ascensão com esta função!', color = Color3.new(1,0,0) })

-- Auto Dungeon
local autoDungeonEnabled = false
local doorSequence = { "0", "1", "Boss" }
local currentDoorIndex = 1
local function getPlayerName() return game.Players.LocalPlayer.Name end
local function isDungeonAvailable()
    local dungeonsFolder = workspace:FindFirstChild('Dungeons')
    return dungeonsFolder and dungeonsFolder:FindFirstChild(getPlayerName())
end
local function hasEnemiesInCombat()
    local combatsFolder = workspace:FindFirstChild('Combats')
    local playerFolder = combatsFolder and combatsFolder[getPlayerName()]
    if playerFolder then
        for _, enemy in pairs(playerFolder:GetChildren()) do
            if enemy:IsA('Model') and enemy:FindFirstChild('Humanoid') and enemy.Humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end
local function moveToNextDoor()
    local dungeonsFolder = workspace:FindFirstChild('Dungeons')
    local playerDungeon = dungeonsFolder and dungeonsFolder:FindFirstChild(getPlayerName())
    if not playerDungeon then
        warn('Dungeon do jogador não encontrado!')
        return
    end
    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
    local targetDoorName = doorSequence[currentDoorIndex]
    local targetDoor = playerDungeon.Door:FindFirstChild(targetDoorName) or playerDungeon:FindFirstChild('Boss')
    if targetDoor and targetDoor:FindFirstChild('Part') then
        humanoidRootPart.CFrame = targetDoor.Part.CFrame
        currentDoorIndex = (currentDoorIndex % #doorSequence) + 1
    else
        warn('Porta alvo não encontrada: ' .. targetDoorName)
    end
end
local function autoDungeonLoop()
    while autoDungeonEnabled do
        if isDungeonAvailable() then
            while hasEnemiesInCombat() and autoDungeonEnabled do
                task.wait(1)
            end
            task.wait(3)
            pcall(moveToNextDoor)
        end
        task.wait(1)
    end
end
local function enterDungeon()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
    if not humanoidRootPart then warn('HumanoidRootPart não encontrado!') return end
    humanoidRootPart.CFrame = CFrame.new(428.6, 148.61, 88.82)
    while autoDungeonEnabled and not isDungeonAvailable() do
        task.wait(5)
        local virtualInputManager = game:GetService('VirtualInputManager')
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        if isDungeonAvailable() then break end
    end
end
local function toggleAutoDungeon(enabled)
    autoDungeonEnabled = enabled
    if autoDungeonEnabled then
        print('Auto Dungeon enabled')
        if not isDungeonAvailable() then
            spawn(enterDungeon)
        end
        spawn(autoDungeonLoop)
    else
        print('Auto Dungeon disabled')
    end
end

local autoDungeonSwitch = mainTab.new('switch', {
    text = 'Auto Dungeon',
    tooltip = 'Completa automaticamente os dungeons, aguardando cooldown se necessário.'
})
autoDungeonSwitch.set(false)
autoDungeonSwitch.event:Connect(toggleAutoDungeon)
mainTab.new('label', { text = 'Use KillAura. Paciência é fundamental!', color = Color3.new(1,0,0) })

-- Aba Equipment
local equipmentTab = mainWindow.new({
    text = 'Equipment',
    padding = Vector2.new(10, 10)
})

-- Auto Luck Roll
local autoLuckRollEnabled = false
local function autoLuckRollLoop()
    while autoLuckRollEnabled do
        task.wait(3)
        local success, err = pcall(function()
            game:GetService('ReplicatedStorage')
                :WaitForChild('Remote')
                :WaitForChild('Event')
                :WaitForChild('LuckRoll')
                :WaitForChild('[C-S]ConfirmLuckRoll')
                :FireServer()
        end)
        if not success then
            warn('Erro no Luck Roll:', err)
            task.wait(10)
        end
    end
end
local function toggleAutoLuckRoll(enabled)
    autoLuckRollEnabled = enabled
    if autoLuckRollEnabled then
        spawn(autoLuckRollLoop)
    end
end
local autoLuckRollSwitch = equipmentTab.new('switch', {
    text = 'Auto Luck Roll',
    tooltip = 'Confirma automaticamente o Luck Roll a cada 3 segundos.'
})
autoLuckRollSwitch.set(false)
autoLuckRollSwitch.event:Connect(toggleAutoLuckRoll)
equipmentTab.new('label', { text = 'Reivindique qualquer recompensa para que o Luck Roll funcione!', color = Color3.new(1,0,0) })
equipmentTab.new('label', { text = 'Combina com o último roll de recompensa.', color = Color3.new(0,1,0) })
equipmentTab.new('label', { text = 'Use uma ou ambas para baixo risco.', color = Color3.new(1,1,0) })

-- Normal Auto Roll
local normalAutoRollEnabled = false
local function toggleNormalAutoRoll(enabled)
    normalAutoRollEnabled = enabled
    if normalAutoRollEnabled then
        print('Normal Auto Roll enabled')
        spawn(function()
            while normalAutoRollEnabled do
                pcall(function()
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Function')
                        :WaitForChild('Roll')
                        :WaitForChild('[C-S]Roll')
                        :InvokeServer()
                end)
                task.wait(3)
            end
        end)
    else
        print('Normal Auto Roll disabled')
    end
end
local normalAutoRollSwitch = equipmentTab.new('switch', {
    text = 'Normal Auto Roll',
    tooltip = 'Rola automaticamente a cada 3 segundos.'
})
normalAutoRollSwitch.set(false)
normalAutoRollSwitch.event:Connect(toggleNormalAutoRoll)

-- Equip Best
local equipBestEnabled = false
local function toggleEquipBest(enabled)
    equipBestEnabled = enabled
    if equipBestEnabled then
        print('Equip Best enabled')
        spawn(function()
            while equipBestEnabled do
                pcall(function()
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('Backpack')
                        :WaitForChild('[C-S]TryEquipBest')
                        :FireServer()
                end)
                task.wait(1)
            end
        end)
    else
        print('Equip Best disabled')
    end
end
local equipBestSwitch = equipmentTab.new('switch', {
    text = 'Equip Best'
})
equipBestSwitch.set(false)
equipBestSwitch.event:Connect(toggleEquipBest)

-- Auto Sell All
local autoSellAllEnabled = false
local function performAutoSell()
    print('Auto Sell All iniciado')
    local backpackData = game:GetService('ReplicatedStorage')
        :WaitForChild('Remote')
        :WaitForChild('Function')
        :WaitForChild('Backpack')
        :WaitForChild('[C-S]GetBackpackData')
        :InvokeServer()
    if type(backpackData) ~= 'table' then
        print('Dados inválidos do backpack.')
        return
    end
    local itemsToSell = {}
    for itemId, itemData in pairs(backpackData) do
        if not itemData.locked then
            itemsToSell[itemId] = true
        else
            print('Item bloqueado, ignorando:', itemId)
        end
    end
    if next(itemsToSell) then
        game:GetService('ReplicatedStorage')
            :WaitForChild('Remote')
            :WaitForChild('Event')
            :WaitForChild('Backpack')
            :WaitForChild('[C-S]TryDeleteListItem')
            :FireServer(itemsToSell)
        print('Auto Sell All executado para os itens.')
    else
        print('Nenhum item encontrado para vender.')
    end
end
local function toggleAutoSellAll(enabled)
    autoSellAllEnabled = enabled
    if autoSellAllEnabled then
        print('Auto Sell All enabled')
        spawn(function()
            while autoSellAllEnabled do
                pcall(performAutoSell)
                task.wait(7)
            end
        end)
    else
        print('Auto Sell All disabled')
    end
end
local autoSellAllSwitch = equipmentTab.new('switch', {
    text = 'Auto Sell All',
    tooltip = 'Vende automaticamente todos os itens não bloqueados do backpack.'
})
autoSellAllSwitch.set(false)
autoSellAllSwitch.event:Connect(toggleAutoSellAll)
equipmentTab.new('label', { text = 'Isto venderá automaticamente todos, exceto os itens bloqueados!', color = Color3.new(1,0,0) })

-- Aba Auto
local autoTab = mainWindow.new({
    text = 'Auto',
    padding = Vector2.new(10, 10)
})

-- Auto Use Luck Potion
local autoUseLuckPotionEnabled = false
local function toggleAutoUseLuckPotion(enabled)
    autoUseLuckPotionEnabled = enabled
    if autoUseLuckPotionEnabled then
        print('Auto Use Luck Potion enabled')
        spawn(function()
            while autoUseLuckPotionEnabled do
                pcall(function()
                    local args = { 'Luck1.2x' }
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('BoostInv')
                        :WaitForChild('[C-S]TryUseBoostRE')
                        :FireServer(unpack(args))
                end)
                task.wait(0.1)
            end
        end)
    else
        print('Auto Use Luck Potion disabled')
    end
end
local autoUseLuckPotionSwitch = autoTab.new('switch', {
    text = 'Auto Use Luck Potion'
})
autoUseLuckPotionSwitch.set(false)
autoUseLuckPotionSwitch.event:Connect(toggleAutoUseLuckPotion)

-- Auto Use Cooldown Potion
local autoUseCooldownPotionEnabled = false
local function toggleAutoUseCooldownPotion(enabled)
    autoUseCooldownPotionEnabled = enabled
    if autoUseCooldownPotionEnabled then
        print('Auto Use Cooldown Potion enabled')
        spawn(function()
            while autoUseCooldownPotionEnabled do
                pcall(function()
                    local args = { 'Roll1.1x' }
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('BoostInv')
                        :WaitForChild('[C-S]TryUseBoostRE')
                        :FireServer(unpack(args))
                end)
                task.wait(0.1)
            end
        end)
    else
        print('Auto Use Cooldown Potion disabled')
    end
end
local autoUseCooldownPotionSwitch = autoTab.new('switch', {
    text = 'Auto Use Cooldown Potion'
})
autoUseCooldownPotionSwitch.set(false)
autoUseCooldownPotionSwitch.event:Connect(toggleAutoUseCooldownPotion)

-- Auto Use Coin Potion
local autoUseCoinPotionEnabled = false
local function toggleAutoUseCoinPotion(enabled)
    autoUseCoinPotionEnabled = enabled
    if autoUseCoinPotionEnabled then
        print('Auto Use Coin Potion enabled')
        spawn(function()
            while autoUseCoinPotionEnabled do
                pcall(function()
                    local args = { 'Coin1.2x' }
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('BoostInv')
                        :WaitForChild('[C-S]TryUseBoostRE')
                        :FireServer(unpack(args))
                end)
                task.wait(0.1)
            end
        end)
    else
        print('Auto Use Coin Potion disabled')
    end
end
local autoUseCoinPotionSwitch = autoTab.new('switch', {
    text = 'Auto Use Coin Potion'
})
autoUseCoinPotionSwitch.set(false)
autoUseCoinPotionSwitch.event:Connect(toggleAutoUseCoinPotion)

-- Aba Misc
local miscTab = mainWindow.new({
    text = 'Misc',
    padding = Vector2.new(10, 10)
})

-- Safe Auto Potion
local boostTypes = { ['Luck Boost'] = 'Luck1.2x', ['Roll Speed Boost'] = 'Roll1.1x', ['Coin Boost'] = 'Coin1.2x' }
local selectedBoost = boostTypes['Luck Boost']
local function getRandomDelay() return math.random(15, 40) end
local function pickUpBoost()
    local success = pcall(function()
        game.ReplicatedStorage.Remote.Event.Boost['[C-S]PickUpBoost']:FireServer(selectedBoost)
    end)
    if success then
        task.wait(getRandomDelay())
    else
        task.wait(60)
    end
end
local safeAutoPotionEnabled = false
local function toggleSafeAutoPotion(enabled)
    safeAutoPotionEnabled = enabled
    if safeAutoPotionEnabled then
        spawn(function()
            while safeAutoPotionEnabled do
                pickUpBoost()
            end
        end)
    end
end
local boostDropdown = miscTab.new('dropdown', {
    text = 'Select Boost',
    tooltip = 'Escolha qual boost ativar.'
})
for boostName, _ in pairs(boostTypes) do boostDropdown.new(boostName) end
boostDropdown.event:Connect(function(selected) selectedBoost = boostTypes[selected] end)
local safeAutoPotionSwitch = miscTab.new('switch', {
    text = 'Safe Auto Potion',
    tooltip = 'Pega automaticamente o boost selecionado com intervalos seguros.'
})
safeAutoPotionSwitch.set(false)
safeAutoPotionSwitch.event:Connect(toggleSafeAutoPotion)
miscTab.new('label', { text = 'Evita uso rápido para prevenir detecção! (pode ser lento)', color = Color3.new(1,0,0) })

-- Auto Ascend
local autoAscendEnabled = false
local function toggleAutoAscend(enabled)
    autoAscendEnabled = enabled
    if autoAscendEnabled then
        print('Auto Ascend enabled')
        spawn(function()
            while autoAscendEnabled do
                pcall(function()
                    game:GetService('ReplicatedStorage')
                        :WaitForChild('Remote')
                        :WaitForChild('Event')
                        :WaitForChild('Upgrade')
                        :WaitForChild('[C-S]TryUpgradeLevel')
                        :FireServer()
                end)
                task.wait(5)
            end
        end)
    else
        print('Auto Ascend disabled')
    end
end
local autoAscendSwitch = miscTab.new('switch', {
    text = 'Auto Ascend',
    tooltip = 'Ascende automaticamente a cada 5 segundos.'
})
autoAscendSwitch.set(false)
autoAscendSwitch.event:Connect(toggleAutoAscend)
miscTab.new('label', { text = "Evite ativar muitas funções simultaneamente para não ser kickado.", color = Color3.new(1,0,0) })

-- Auto Hide UI (para esconder elementos de UI internos do jogo)
local playerGui = game:GetService('Players').LocalPlayer:FindFirstChild('PlayerGui')
local openChestGui = playerGui and playerGui:FindFirstChild('OpenChest')
local tipGui = playerGui and playerGui:FindFirstChild('Tip')
local function toggleGuiVisibility(visible)
    if openChestGui then openChestGui.Enabled = visible end
    if tipGui then tipGui.Enabled = visible end
end
local autoHideUiEnabled = false
local autoHideUiTask
local function toggleAutoHideUi(enabled)
    autoHideUiEnabled = enabled
    if autoHideUiEnabled then
        autoHideUiTask = spawn(function()
            while autoHideUiEnabled do
                toggleGuiVisibility(false)
                task.wait(0.5)
            end
        end)
    else
        if autoHideUiTask then
            task.cancel(autoHideUiTask)
            autoHideUiTask = nil
        end
        toggleGuiVisibility(true)
    end
end
local autoHideUiSwitch = miscTab.new('switch', {
    text = 'Auto Hide UI',
    tooltip = 'Oculta automaticamente as UIs internas (OpenChest e Tip).'
})
autoHideUiSwitch.set(false)
autoHideUiSwitch.event:Connect(toggleAutoHideUi)
miscTab.new('label', { text = 'Ative para esconder elementos de UI!', color = Color3.new(1,0,0) })

-- Aba Info
local infoTab = mainWindow.new({
    text = 'Info',
    padding = Vector2.new(10, 10)
})
infoTab.new('label', { text = 'Contact', color = Color3.new(1,1,1) })
infoTab.new('label', { text = "Contact\n------------\nDiscord: RONY HUB\nhttps://discord.gg/34EPkFFSeM", color = Color3.new(1,1,1) })
infoTab.new('label', { text = 'Por favor, mantenha seus DMs abertos.', color = Color3.new(1,0,0) })

print('Script Mobile-Friendly RONY HUB carregado com sucesso!')