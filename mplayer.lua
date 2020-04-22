local socket=require"socket"
local time=socket.gettime
local json=require"dkjson"
local copas=require"copas"
return function(filename)
  local sockname="/tmp/mpc"..time()
  local ctx=io.popen(string.format("mpv -quiet -hr-seek=always --input-ipc-server=%s '%s'",sockname,filename))
  copas.sleep(1)
  local function send(...)
    print(json.encode{command={...}})
    local file=io.popen(string.format("socat - '%s'",sockname),"w")
    file:write(json.encode{command={...}}.."\n")
    file:close()
  end
  local ret={ctx}
  local base=time()
  local pos=0
  local playing=true
  local speed=1
  local function get_time()
    if playing then
      return ((time()-base)/speed)+pos
    else
      return pos
    end
  end
  function ret:set_speed(s)
    speed=s
    pos=get_time()
    base=time()
    send("set_property", "speed",s)
  end
  function ret:pause()
    pos=get_time()
    if playing then
      playing=false
      send("set_property", "pause", true)
    end
  end
  function ret:play()
    if not playing then
      playing=true
      send("set_property", "pause", false)
      base=time()
    end
  end
  function ret:seek(stime)
    if math.abs(stime-get_time())>-1 then
      send("seek",stime,"absolute")
    end
    pos=stime
    base=time()
  end
  return ret
end
