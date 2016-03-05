function http_match(method, url, req)
    local start = method .. ' ' .. url
    return start == string.sub(req, 1, start:len())
end

function http_url(req)
    local i1 = req:find(' ')
    local i2 = req:find(' ', i1 + 1)
    return req:sub(i1+1, i2-1)
end

function http_body(req)
    local idx = req:find('\r\n\r\n')
    if idx == nil then
        return ''
    else
        return req:sub(idx + 4)
    end
end

function http_header(req, name)
    local _,i = req:find(name..':', 1, true)
    return req:sub(i + 1, req:find('\r', i, true) - 1)
end
