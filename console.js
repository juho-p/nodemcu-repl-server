console.log('startup');

con = {
    history:['']
};

con.output = document.getElementById('output');
con.input = document.getElementById('input');

function post(url, data, f) {
    var req = new XMLHttpRequest();
    req.open('POST', url);
    req.onreadystatechange = function() {
        if (req.readyState == 4) {
            f(req);
        }
    }
    req.send(data);
}

con.out = function(s) {
    con.output.innerHTML += s + '<br>';
    con.output.scrollTop = con.output.scrollTopMax;
};

con.input.addEventListener('keypress', function(e){
    if (e.keyCode == 13){
        var val = con.input.value;
        if (con.history[con.history.length-1] != val) {
            con.history.push(val);
        }
        con.historyidx = -1;
        post('/eval', val, function(r) {
            con.out(val + ' -> ' + r.responseText);
        });
        con.input.value = '';
    }
});

con.input.addEventListener('keydown', function(e){
    var keycode = e.keyCode;
    if (keycode == 38) {
        con.loadhistory(1);
    } else if (keycode == 40) {
        con.loadhistory(-1);
    }
});

con.loadhistory = function(n) {
    var idx = con.historyidx + n;
    if (idx < 0) {
        idx = 0;
    } else if (idx >= con.history.length) {
        idx = con.history.length;
    }
    con.input.value = con.history[con.history.length - 1 - idx];
    con.historyidx = idx;
};

con.get_output = function() {
    post('/output', '', function(r) {
        if (r.responseText != '') {
            con.out('== ' + r.responseText.replace(/\n/g, '<br>== '));
        }

        setTimeout(con.get_output, 10);
    });
};

setTimeout(con.get_output, 1000);
