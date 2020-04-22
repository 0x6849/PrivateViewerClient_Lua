local ws={}
local copas=require"copas"
local socket=require"socket"
function ws.connect(url, port)
  local ws={}
  local conn=copas.wrap(socket.tcp())
  conn:connect(url,port)
  conn:dohandshake({
  mode = "client",
  protocol = "any",
  verify = "none",
  options = {"all", "no_sslv3"}
})
  conn:send("GET / HTTP/1.1\r\n")
  conn:send("Host: "..url.."\r\n")
  conn:send("Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n")
  conn:send("Sec-WebSocket-Version: 13\r\n")
  conn:send("Upgrade: websocket\r\n")
  conn:send("Connection: Upgrade\r\n")
  conn:send("\r\n")
  local buf=""
  while not buf:find("\r\n\r\n") do
    buf=buf..assert(conn:receive()).."\r\n"
  end
  buf=""
  function ws:send(str)
    conn:send(string.char(1+128))
    local len=str:len()
    if str:len()>125 then   
      len=126
    end
    conn:send(string.char(len+128))
    if str:len()>125 then
      len=str:len()
      conn:send(string.char(math.floor(len/256)))
      conn:send(string.char(len%256))
    end
    for i=1,4 do
      conn:send(string.char(0))
    end
    conn:send(str)
  end
  function ws:receive()
    assert(assert(conn:receive(1)):byte()==129)
    local len=conn:receive(1):byte()%128
    if len==126 then
      local l1=conn:receive(1):byte()
      local l2=conn:receive(1):byte()
      len=(l1*256)+l2
    elseif len>126 then
      error("Too long")
    end
    print("RECL",len)
    return conn:receive(len)
  end
  return ws
end
return ws
