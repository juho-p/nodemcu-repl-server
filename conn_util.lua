function sendfile(conn, filename, header)
    function send(sent, amt)
        file.open(filename)
        file.seek('set', sent)
        local s = file.read(amt)
        file.close()
        conn:send(s)
        logmsg('sent ' .. s:len() .. ' bytes')
        return s:len() < amt
    end

    file.open(filename)
    local file_len = file.seek('end', 0)
    file.close()

    local sent = 0
    conn:on('sent', function()
        local done = send(sent, 256)
        if done then
            conn:close()
            conn = nil
        else
            sent = sent + 256
        end
    end)

    conn:send("HTTP/1.1 200 OK\r\nserver: nodemcu\r\n" ..
        "Content-Length: " .. tostring(file_len) .. '\r\n' .. header .. "\r\n")
    logmsg('sending ' .. filename)
end

function sendstring(conn, str, header)
    if header == nil then header = '' end
    conn:on('sent', function()
        conn:send(string.sub(str, 1, 256))
        if str:len() < 257 then
            conn:close()
            conn = nil
        else
            str = string.sub(str, 257)
        end
    end)

    conn:send("HTTP/1.1 200 OK\r\nserver: nodemcu\r\n" ..
        "Content-Length: " .. tostring(str:len()) .. '\r\n' .. header .. "\r\n")
end
