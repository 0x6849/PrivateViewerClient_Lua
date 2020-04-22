local json=require"dkjson"
local copas=require"copas"
local ws=require"ws"
local mplayer=require"mplayer"
copas.addthread(function()
  local w=ws.connect(assert(require"config".url,"Missing URL in config"), assert(require"config".port,"Missing port in config"))
  local inst=mplayer(arg[2])


  w:send(json.encode{action="join", roomID=arg[1], name="chriku-passive"})
  --w:send(json.encode{action="leave"})
  while true do
    local json=assert(json.decode(w:receive()))
    print("======")
    for k,v in pairs(json) do print(k,v) end
    --assert(json.result)
    if json.playSpeed then
      inst:set_speed(json.playSpeed)
    end
    if json.timeStamp then
      inst:seek(json.timeStamp)
    end
    if json.paused then
      inst:pause()
    elseif json.paused==false then
      inst:play()
    end
  end
end)
copas.loop()
