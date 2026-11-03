-- キーを押したときだけ、場面ごとにウィンドウを並べて前面に出す（2026-11-03。yashiki の後継）
-- 正本は ~/dotfiles/hammerspoon/（直したら ~/.hammerspoon/ へコピーして hs -c "hs.reload()"）
-- ウィンドウを隠さない。場面に入らないウィンドウは後ろへ回るだけ

require("hs.ipc")
if not hs.ipc.cliStatus("/opt/homebrew") then hs.ipc.cliInstall("/opt/homebrew") end
hs.autoLaunch(true)
hs.window.animationDuration = 0
hs.window.timeout(1)

local GAP = 10
local CLAUDE, OBSIDIAN, CHROME, DAVINCI = "com.anthropic.claudefordesktop", "md.obsidian", "com.google.Chrome", "com.blackmagic-design.DaVinciResolve"
local KINDLE, CMUX, DISCORD, CHATGPT = "com.amazon.Lassen", "com.cmuxterm.app", "com.hnc.Discord", "com.openai.codex"

-- 画面: MAC = 内蔵、DELL = それ以外の外部モニタ。外部モニタが無ければ DELL の場面も内蔵に出す
local function screens()
  local mac, dell
  for _, s in ipairs(hs.screen.allScreens()) do
    if (s:name() or ""):find("Built%-in") then mac = s else dell = dell or s end
  end
  mac = mac or hs.screen.primaryScreen()
  return mac, dell or mac
end

-- そのアプリの普通のウィンドウ。cmux のアップデート案内は数えない。jinsei の cmux は Mac 用なので先頭に置く
local function windowsOf(bundle)
  local app = hs.application.get(bundle)
  if not app then return {} end
  if app:isHidden() then app:unhide() end
  local out = {}
  for _, w in ipairs(app:allWindows()) do
    if w:isStandard() and w:title() ~= "cmux cloud" then table.insert(out, w) end
  end
  table.sort(out, function(a, b)
    local ja, jb = a:title() == "jinsei", b:title() == "jinsei"
    if ja ~= jb then return ja end
    return a:id() < b:id()
  end)
  return out
end

-- 同じアプリの複数枚は、いま置いてある画面で見分ける
-- 足りなければもう片方の画面から借りる。ただし向こうに1枚は残す（required のときだけ、最後の1枚でも連れてくる）
local function pick(bundle, screen, n, required)
  local here, there = {}, {}
  for _, w in ipairs(windowsOf(bundle)) do
    table.insert(w:screen():id() == screen:id() and here or there, w)
  end
  while #here < n and #there > 1 do table.insert(here, table.remove(there)) end
  if required and #here == 0 and #there > 0 then table.insert(here, table.remove(there)) end
  local out = {}
  for i = 1, math.min(n, #here) do
    if here[i]:isMinimized() then here[i]:unminimize() end
    out[i] = here[i]
  end
  return out
end

local function area(s)
  local f = s:frame()
  return { x = f.x + GAP, y = f.y + GAP, w = f.w - GAP * 2, h = f.h - GAP * 2 }
end

-- 横に n 等分
local function row(wins, a, out)
  local n = #wins
  if n == 0 then return end
  local cw = math.floor((a.w - GAP * (n - 1)) / n)
  for i, w in ipairs(wins) do
    table.insert(out, { w, { x = a.x + (i - 1) * (cw + GAP), y = a.y, w = cw, h = a.h } })
  end
end

-- 左右に分ける。片方しか無ければ全面
local function split(a, ratio)
  local lw = math.floor((a.w - GAP) * ratio)
  return { x = a.x, y = a.y, w = lw, h = a.h }, { x = a.x + lw + GAP, y = a.y, w = a.w - lw - GAP, h = a.h }
end

local function sideBySide(left, right, ratio, a, out)
  if left and right then
    local l, r = split(a, ratio)
    table.insert(out, { left, l })
    table.insert(out, { right, r })
  elseif left or right then
    table.insert(out, { left or right, a })
  end
end

-- 場面。out の先頭が最後に手前へ来て、選択された状態になる
local SCENES = {
  { name = "Claude＋Obsidian", on = "dell", build = function(s, out)
    sideBySide(pick(CLAUDE, s, 1, true)[1], pick(OBSIDIAN, s, 1, true)[1], 2 / 3, area(s), out)
  end },
  { name = "Chrome", on = "dell", build = function(s, out)
    row(pick(CHROME, s, 2, true), area(s), out)
  end },
  { name = "DaVinci＋Obsidian", on = "dell", build = function(s, out)
    sideBySide(pick(DAVINCI, s, 1, true)[1], pick(OBSIDIAN, s, 1, true)[1], 3 / 4, area(s), out)
  end },
  { name = "勉強", on = "dell", build = function(s, out)
    local a = area(s)
    local claude = pick(CLAUDE, s, 1, true)[1]
    local top = {}
    local obsidian = pick(OBSIDIAN, s, 1, true)[1]
    if obsidian then table.insert(top, obsidian) end
    local cmux = pick(CMUX, s, 1, false)[1]
    if cmux then table.insert(top, cmux) end
    local kindle = pick(KINDLE, s, 1, true)[1]
    local right = a
    if claude and (#top > 0 or kindle) then
      local l, r = split(a, 1 / 2)
      table.insert(out, { claude, l })
      right = r
    elseif claude then
      table.insert(out, { claude, a })
      return
    end
    if #top > 0 and kindle then
      local th = math.floor((right.h - GAP) / 2)
      row(top, { x = right.x, y = right.y, w = right.w, h = th }, out)
      table.insert(out, { kindle, { x = right.x, y = right.y + th + GAP, w = right.w, h = right.h - th - GAP } })
    elseif #top > 0 then
      row(top, right, out)
    elseif kindle then
      table.insert(out, { kindle, right })
    end
  end },
  { name = "Discord", on = "mac", build = function(s, out) row(pick(DISCORD, s, 1, true), area(s), out) end },
  { name = "Chrome", on = "mac", build = function(s, out) row(pick(CHROME, s, 1, true), area(s), out) end },
  { name = "cmux", on = "mac", build = function(s, out) row(pick(CMUX, s, 1, true), area(s), out) end },
  { name = "ChatGPT", on = "mac", build = function(s, out) row(pick(CHATGPT, s, 1, true), area(s), out) end },
}

local current, previous

local function warp(w)
  if w then hs.mouse.absolutePosition(hs.geometry(w:frame()).center) end
end

function showScene(i)
  local mac, dell = screens()
  local scene = SCENES[i]
  local out = {}
  scene.build(scene.on == "dell" and dell or mac, out)
  if #out == 0 then
    hs.alert.show(scene.name .. " は開いていません")
    return
  end
  if current ~= i then previous, current = current, i end
  for _, p in ipairs(out) do p[1]:setFrame(p[2], 0) end
  for k = #out, 1, -1 do out[k][1]:focus() end
  warp(out[1][1])
end

-- 手前のウィンドウの操作
local function focused() return hs.window.focusedWindow() end

-- hs.window.orderedWindows は裏のプロセスにも問い合わせて数秒固まるので、Dock に出るアプリだけ見る
local function allWindowsFrontFirst()
  local byId = {}
  for _, a in ipairs(hs.application.runningApplications()) do
    if a:kind() == 1 then
      for _, w in ipairs(a:allWindows()) do
        if w:isStandard() then byId[w:id()] = w end
      end
    end
  end
  local out = {}
  for _, id in ipairs(hs.window._orderedwinids()) do
    if byId[id] then table.insert(out, byId[id]) end
  end
  return out
end

local function otherScreen(s)
  local next = s and s:next()
  return next and next:id() ~= s:id() and next or nil
end

local function focusOtherScreen()
  local w = focused()
  local other = otherScreen(w and w:screen() or hs.mouse.getCurrentScreen())
  if not other then return end
  for _, c in ipairs(allWindowsFrontFirst()) do
    if c:screen():id() == other:id() then
      c:focus()
      warp(c)
      return
    end
  end
  hs.mouse.absolutePosition(hs.geometry(other:frame()).center)
end

local function sendToOtherScreen()
  local w = focused()
  local other = w and otherScreen(w:screen())
  if not other then return end
  w:moveToScreen(other, false, true, 0)
  warp(w)
end

local fullBefore = {}
local function toggleFull()
  local w = focused()
  if not w then return end
  local id = w:id()
  if fullBefore[id] then
    w:setFrame(fullBefore[id], 0)
    fullBefore[id] = nil
  else
    fullBefore[id] = w:frame()
    local a = area(w:screen())
    w:setFrame(a, 0)
  end
end

local function cycle(step)
  local w = focused()
  if not w then return end
  local list = {}
  for _, c in ipairs(allWindowsFrontFirst()) do
    if c:screen():id() == w:screen():id() then table.insert(list, c) end
  end
  table.sort(list, function(a, b) return a:id() < b:id() end)
  for i, c in ipairs(list) do
    if c:id() == w:id() then
      list[(i - 1 + step) % #list + 1]:focus()
      return
    end
  end
end

local function directional(method)
  return function()
    local w = focused()
    if w then w[method](w, nil, true, true) end
  end
end

local function closeWindow()
  local w = focused()
  if w then w:close() end
end

local function replay()
  if current then showScene(current) end
end

local function back()
  if previous then showScene(previous) end
end

-- キー。Option は MacBook のキーボード、HYPER は Conductor の W／O 長押し（Layer 9・10）が送る
local HYPER = { "cmd", "ctrl", "alt", "shift" }
local ALT, ALT_SHIFT = { "alt" }, { "alt", "shift" }
local function bind(mods, key, fn) hs.hotkey.bind(mods, key, fn) end

for i = 1, #SCENES do
  local fn = function() showScene(i) end
  bind(ALT, tostring(i), fn)
  bind(HYPER, tostring(i), fn)
end
for _, mods in ipairs({ ALT, HYPER }) do
  bind(mods, "0", back)
  bind(mods, "r", replay)
  bind(mods, "f", toggleFull)
end
bind(ALT, "o", focusOtherScreen)
bind(HYPER, "g", focusOtherScreen)
bind(ALT_SHIFT, "o", sendToOtherScreen)
bind(ALT_SHIFT, "p", sendToOtherScreen)
bind(HYPER, "v", sendToOtherScreen)
bind(ALT_SHIFT, "c", closeWindow)
bind(HYPER, "q", closeWindow)
bind(ALT, "j", function() cycle(1) end)
bind(ALT, "k", function() cycle(-1) end)
bind(HYPER, "e", function() cycle(1) end)
bind(HYPER, "w", function() cycle(-1) end)
bind(HYPER, "a", directional("focusWindowWest"))
bind(HYPER, "s", directional("focusWindowSouth"))
bind(HYPER, "d", directional("focusWindowNorth"))
