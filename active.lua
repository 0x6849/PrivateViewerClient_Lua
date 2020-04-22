local json=require"dkjson"
local copas=require"copas"
local ws=require"ws"
local mplayer=require"mplayer"
local function choose(query, list)
  while true do
    for i=1,#list do print(i,list[i]) end
    io.write(query..": ")
    local at=tonumber(io.read())
    if list[at] then return list[at] end
  end
end
local app_name="chriku-active"
copas.addthread(function()
  local w=ws.connect(assert(require"config".url,"Missing URL in config"), assert(require"config".port,"Missing port in config"))
  local inst=mplayer(arg[2])

  local room_list
  do
    w:send(json.encode{action="listRooms", name = app_name})
    local json=assert(json.decode(w:receive()))
    room_list=json.rooms
  end
  table.insert(room_list,1, "new")
  local room_name=choose("Choose room", room_list)

  if room_name=="new" then
    io.write("room name: ")
    room_name=io.read()
    w:send(json.encode{action="createRoom", roomID = room_name, name = app_name})
  end

  w:send(json.encode{action="join", roomID=room_name, name = app_name})
  --w:send(json.encode{action="leave"})
  while true do
    --print("======")
    --assert(json.result)
    local act=choose("Action",{"play", "pause", "set speed", "jump +10", "jump -10", "jump absolute", "jump relative"})
    if act=="play" then
      w:send(json.encode{action="change", paused=false})
    elseif act=="pause" then
      w:send(json.encode{action="change", paused=true})
    elseif act=="set speed" then
      io.write("new speed: ")
      local speed=tonumber(io.read())
      if speed then
        w:send(json.encode{action="change", playSpeed=speed})
      else
        print("no change")
      end
    elseif act=="jump +10" then
      w:send(json.encode{action="change", jump = 10})
    elseif act=="jump -10" then
      w:send(json.encode{action="change", jump = -10})
    elseif act=="jump absolute" then
    elseif act=="jump relative" then
    end
  end

  --inst:set_speed(2)
  --local int=1
  --for i=0,100,int do
    --copas.sleep(1)
    --inst:seek((i%10)+20)
    --copas.sleep(1)
    --copas.sleep(int)
  --end
end)
copas.loop()
