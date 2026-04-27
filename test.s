```html
<!DOCTYPE html>
<html>
<body>

<button onclick="testar()">TESTAR SUPABASE</button>

<script>
async function testar(){

    const resp = await fetch("https://vdpucrilxzlnxxnaohdh.supabase.co/rest/v1/downloads", {
        method: "POST",
        headers: {
            "apikey": "sb_publishable_iCOZMw9xc0QZaGQWTHdxMQ_O33nfE42",
            "Authorization": "Bearer sb_publishable_iCOZMw9xc0QZaGQWTHdxMQ_O33nfE42",
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            conteudo_id: 999,
            programa: "teste"
        })
    });

    const txt = await resp.text();

    alert("STATUS: " + resp.status + "\n\n" + txt);
}
</script>

</body>
</html>
```
```html
<!DOCTYPE html>
<html>
<body>

<button onclick="testar()">TESTAR SUPABASE</button>

<script>
async function testar(){

    const resp = await fetch("https://vdpucrilxzlnxxnaohdh.supabase.co/rest/v1/downloads", {
        method: "POST",
        headers: {
            "apikey": "sb_publishable_iCOZMw9xc0QZaGQWTHdxMQ_O33nfE42",
            "Authorization": "Bearer sb_publishable_iCOZMw9xc0QZaGQWTHdxMQ_O33nfE42",
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            conteudo_id: 999,
            programa: "teste"
        })
    });

    const txt = await resp.text();

    alert("STATUS: " + resp.status + "\n\n" + txt);
}
</script>

</body>
</html>
```
