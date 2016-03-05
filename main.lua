require('replserver')

visit_count = 0

function serve_index(conn)
    visit_count = visit_count + 1
    s = '<html><head><title>Hello, World</title></head><body>' ..
    '<h1>Simple nodemcu page</h1>' ..
    '<br>visits: ' .. visit_count ..
    '<br>heap: ' .. node.heap() ..
    '<br>time: ' .. tmr.time() ..
    '</body></html>'
    sendstring(conn, s)
end

start_server(function(conn, payload)
    if http_match('GET', '/', payload) then
        serve_index(conn)
    else
        basic_response(conn, 'Not much here...')
    end
end)
