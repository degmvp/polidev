// ============================================
// JS 01 - Leitura/Parse CSV
// ============================================

// 1 - Parse linha CSV simples
function parseCSV(linha) {
    return linha.split(',').map(campo => campo.trim());
}

// 2 - Lê arquivo CSV (File API)
function lerCSV(arquivo) {
    return new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = (e) => {
            const linhas = e.target.result.split('\n');
            resolve(linhas.map(l => parseCSV(l)));
        };
        reader.readAsText(arquivo);
    });
}

// Exemplo 1: Parse direto
function main1() {
    const csv = "nome,idade\nJoao,25";
    console.log("Ex1:", parseCSV(csv.split('\n')[1]));
}

// Exemplo 2: Simula arquivo
async function main2() {
    const dados = "produto,preco\nCaneta,2.50";
    const linhas = dados.split('\n');
    console.log("Ex2:", linhas.map(l => parseCSV(l)));
}

// Exemplo 3: Valida CSV
function main3() {
    const csv = "email,status\nuser@test.com,ativo";
    const parsed = parseCSV(csv.split('\n')[1]);
    console.log("Ex3:", parsed[0], parsed[1] === 'ativo' ? 'OK' : 'Erro');
}