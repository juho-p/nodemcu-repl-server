require('util')
require('http_util')
require('conn_util')

_output = {}

_sendoutput = nil

function putoutput(line)
    if table.getn(_output) > 40 then
        table.remove(_output, 1)
        table[1] = '** [skipped data] **'
    end
    table.insert(_output, line)
    logmsg('out: ' .. line)

    if _sendoutput ~= nil then
        _sendoutput(readoutput())
    end
end

function istable(o)
    local t = type(o)
    return t == 'table' or t == 'romtable'
end

function p(...)
    function maketab(key)
        local tab = 20
        local k = tostring(key)
        if k:len() > tab-1 then
            return k .. ' '
        else
            return k .. string.rep(' ', tab - k:len())
        end
    end
    for i = 1, arg.n do
        local v = arg[i]
        if istable(v) then
            for i,vv in pairs(v) do
                putoutput(maketab(i) .. tostring(vv))
            end
        else
            putoutput(tostring(v))
        end
    end
end

function readoutput()
    local result = table.concat(_output, "\n")
    _output = {}
    return result
end

function basic_response(conn, content)
    conn:send("HTTP/1.1 200 OK\r\nserver: nodemcu\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n" .. content)
    conn:close()
end

function start_server(conn_callback)
    srv=net.createServer(net.TCP)
    srv:listen(80, function(conn)
        local uploading = false
        local file_name = nil
        local file_left = 0

        conn:on("receive", function(conn,payload)

            if uploading then
                logmsg('save next chunk for ' .. file_name)
                logmsg('chunk size: ' .. payload:len())
                file.open(file_name, 'a')
                file.write(payload)
                file.close()
                file_left = file_left - payload:len()
                logmsg('file left: ' .. file_left)
            elseif http_match('POST', '/output', payload) then
                local s = readoutput()
                if _sendoutput ~= nil then
                    _sendoutput('')
                end
                _sendoutput = function(s)
                    _sendoutput = nil
                    basic_response(conn, s)
                end
                if s ~= '' then
                    _sendoutput(s)
                else
                    tmr.alarm(0, 20000, tmr.ALARM_SINGLE, function()
                        if _sendoutput ~= nil then
                            _sendoutput('')
                        end
                    end)
                end
            elseif http_match('POST', '/eval', payload) then
                local res = evaluate(http_body(payload))
                if res == nil then
                    res = 'nil'
                end
                basic_response(conn, tostring(res))
            elseif http_match('POST', '/upload/', payload) then
                file_name = string.sub(http_url(payload), 9)
                logmsg('upload ' .. file_name)
                local filedata = http_body(payload)
                file_left = tonumber(http_header(payload, 'Content-Length'))
                file_left = file_left - filedata:len()
                logmsg('chunk size ' .. filedata:len())
                file.remove(file_name)
                file.open(file_name, 'w')
                file.write(filedata)
                file.close()
                filedata = nil
                uploading = true
            elseif http_match('GET', '/download/', payload) then
                file_name = string.sub(http_url(payload), 11)
                logmsg('download ' .. file_name)
                sendfile(conn, file_name, 'Content-Type: text/plain\r\n')
                file_name = nil
            elseif http_match('GET', '/console', payload) then
                sendfile(conn, 'console.html', 'Content-Type: text/html; charset=UTF-8\r\n')
            else
                conn_callback(conn, payload)
            end

            if file_name ~= nil and file_left == 0 then
                logmsg('finished uploading ' .. file_name)
                file_name = nil
                basic_response(conn, 'ok\n')
            end
        end)
    end)
    print('server started')
end
