local itermHotkeyMappings = {
  -- Use control + dash to split panes horizontally
  {
    from = {{'ctrl'}, '-'},
    to   = {{'cmd', 'shift'}, 'd'}
  },

  -- Use control + pipe to split panes vertically
  {
    from = {{'ctrl', 'shift'}, '\\'},
    to   = {{'cmd'}, 'd'}
  },

  -- Use control + h/j/k/l to move left/down/up/right by one pane
  {
    from = {{'ctrl'}, 'h'},
    to   = {{'cmd', 'alt'}, 'left'}
  },
  {
    from = {{'ctrl'}, 'j'},
    to   = {{'cmd', 'alt'}, 'down'}
  },
  {
    from = {{'ctrl'}, 'k'},
    to   = {{'cmd', 'alt'}, 'up'}
  },
  {
    from = {{'ctrl'}, 'l'},
    to   = {{'cmd', 'alt'}, 'right'}
  },
}

local terminalWindowFilter = hs.window.filter.new('iTerm2')
local itermHotkeys = hs.fnutils.each(itermHotkeyMappings, function(mapping)
  local fromMods = mapping['from'][1]
  local fromKey = mapping['from'][2]
  local toMods = mapping['to'][1]
  local toKey = mapping['to'][2]
  local hotkey = hs.hotkey.new(fromMods, fromKey, function()
    keyUpDown(toMods, toKey)
  end)
  enableHotkeyForWindowsMatchingFilter(terminalWindowFilter, hotkey)
end)

hs.window.animationDuration = 0
--[ window dragging ]----------------------------------------------------------
function moveWindow(x, y, w, h)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w*x)
	f.y = max.y + (max.h*y)
	f.w = max.w*w
	f.h = max.h*h
	win:setFrame(f)
end
dragging_window = nil
click_event = hs.eventtap.new({hs.eventtap.event.types.leftMouseDragged}, function(e)
	if dragging_window == nil  then
		-- check mouse is in titlebar
		local m = hs.mouse.getAbsolutePosition()
		local f = hs.window:focusedWindow():frame()
		local screen = hs.window:focusedWindow():screen()
		local max = screen:frame()
		if m.x > f.x and m.x < (f.x + f.w) then
			if m.y > f.y and m.y < (f.y + 21) then
				dragging_window = hs.window.focusedWindow()
				dragging_window_time = hs.timer.localTime()
			end
		end
	end
end)
unclick_event = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(e)
	if dragging_window ~= nil then
		local m = hs.mouse.getAbsolutePosition()
		local f = hs.window:focusedWindow():frame()
		local screen = hs.window:focusedWindow():screen()
		local max = screen:frame()
		if m.x < 50 then
			if m.y < 200 then
				moveWindow(0.0,0.0,0.5,0.5)
			elseif m.y > (max.h-200) then
				moveWindow(0.0,0.5,0.5,0.5)
			else
				moveWindow(0.0,0.0,0.5,1.0)
			end
		elseif m.x > (max.w-50) then
			if m.y < 200 then
				moveWindow(0.5,0.0,0.5,0.5)
			elseif m.y > (max.h-200) then
				moveWindow(0.5,0.5,0.5,0.5)
			else
				moveWindow(0.5,0.0,0.5,1.0)
			end
		elseif m.y < 25 and m.x>200 and m.x < (max.w-200) then
				moveWindow(0.0,0.0,1.0,1.0)
		end
	end
	dragging_window = nil
end)
click_event:start()
unclick_event:start()
