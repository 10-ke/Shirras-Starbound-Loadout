profilerApi = {}

--- Initializes the Profiler and hooks all functions
function profilerApi.init()
  if profilerApi.isInit then return end
  profilerApi.hooks = {}
  profilerApi.start = profilerApi.getTime()
  profilerApi.hookAll("", _ENV)
  profilerApi.isInit = true
end

--- Prints all collected data into the log ordered by total time descending
function profilerApi.logData()
  local time = profilerApi.getTime() - profilerApi.start
  local arr = {}
  local len = 8
  local cnt = 5
  for k,v in pairs(profilerApi.hooks) do
    if v.t > 0 then
      table.insert(arr, k)
      local l = string.len(k)
      if l > len then len = l end
      l = profilerApi.get10pow(profilerApi.hooks[k].c)
      if l > cnt then cnt = l end
    end
  end
  table.sort(arr, profilerApi.sortHelp)
  world.logInfo("Profiler log for EntityID " .. entity.id() .. " (total profiling time: " .. string.format("%.2f", time) .. ")")
  world.logInfo(string.format("%" .. len .. "s |        total time | %" .. cnt .. "s |      average time |         last time", "function", "count"))
  for i,k in ipairs(arr) do
    local hook = profilerApi.hooks[k]
    world.logInfo(string.format("%" .. len .. "s | %.15f | %" .. cnt .. "i | %.15f | %.15f", k, hook.t, hook.c, hook.a, hook.e))
  end
end

function profilerApi.get10pow(n)
  local ret = 1
  while n >= 10 do
    ret = ret + 1
    n = n / 10
  end
  return ret
end

function profilerApi.sortHelp(e1, e2)
  return profilerApi.hooks[e1].a > profilerApi.hooks[e2].a  -- sorted by average
--  return profilerApi.hooks[e1].t > profilerApi.hooks[e2].t  -- sorted by total
end

function profilerApi.canHook(fn)
  local un = { "pairs", "ipairs", "type", "next", "assert", "error", "print", "setmetatable", "select", "rawset", "rawlen", "pcall" }
  for i,v in ipairs(un) do
    if v == fn then return false end
  end
  return true
end

function profilerApi.dontHook(tn)
  local un = {"profilerApi.","table.","coroutine.","os.","math.","string.","world.","entity.","script.","mcontroller.","util.","vec2."}
  for i,v in ipairs(un) do
    if v == tn then return true end
  end
  return false
end

function profilerApi.hookAll(tn, to)
  if profilerApi.dontHook(tn) then return end
  for k,v in pairs(to) do
    if type(v) == "function" then
      if (tn ~= "") or profilerApi.canHook(k) then
        profilerApi.hook(to, tn, v, k)
      end
    elseif type(v) == "table" then
      profilerApi.hookAll(tn .. k .. ".", v)
    end
  end
end

function profilerApi.getTime()
  return os.clock()
end

function profilerApi.hook(to, tn, fo, fn)
  local full = tn .. fn
  profilerApi.hooks[full] = { s = -1, f = fo, e = -1, t = 0, a = 0, c = 0 }
  to[fn] = function(...) return profilerApi.hooked(full, ...) end
end

function profilerApi.hooked(n, ...)
  local hook = profilerApi.hooks[n]
  hook.s = profilerApi.getTime()
  local ret = hook.f(...)
  hook.e = profilerApi.getTime() - hook.s
  hook.t = hook.t + hook.e
  hook.c = hook.c + 1
  hook.a = hook.t / hook.c
  return ret
end