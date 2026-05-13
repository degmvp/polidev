// ============================================
// JS 14 - Fetch/API Simples
// ============================================

async function fetchJSON(url) {
    const response = await fetch(url);
    return await response.json();
}

function buscarUsuario(id) {
    return fetchJSON(`https://jsonplaceholder.typicode.com/users/${id}`);
}

async function main1() {
    try {
        const user = await buscarUsuario(1);
        console.log("Usuario 1:", user.name);
    } catch(e) {
        console.log("Erro rede");
    }
    return 'Fetch OK';
}

async function main2() {
    console.log("Simulando API...");
    // JSONPlaceholder demo
    return 'API OK';
}

async function main3() {
    // Lista usuários
    console.log("Carregando usuarios...");
    return 'Lista OK';
}