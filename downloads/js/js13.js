// ============================================
// JS 13 - LocalStorage Simples
// ============================================

function salvarLocal(chave, valor) {
    localStorage.setItem(chave, JSON.stringify(valor));
}

function lerLocal(chave) {
    try {
        return JSON.parse(localStorage.getItem(chave));
    } catch {
        return null;
    }
}

function main1() {
    salvarLocal("usuario", {nome: "Joao", idade: 25});
    console.log("Salvo:", lerLocal("usuario"));
    return 'LocalStorage OK';
}

function main2() {
    const config = {tema: "dark", idioma: "pt"};
    salvarLocal("config", config);
    console.log("Config:", lerLocal("config"));
    return 'Config OK';
}

function main3() {
    localStorage.clear();
    console.log("Limpo:", Object.keys(localStorage).length);
    return 'Limpeza OK';
}