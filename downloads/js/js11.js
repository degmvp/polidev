// ============================================
// JS 11 - Manipulação String Avançada
// ============================================

function contarPalavras(str) {
    return str.trim().split(/\s+/).length;
}

function contarVogais(str) {
    const vogais = /[aeiou]/gi;
    return (str.match(vogais) || []).length;
}

function main1() {
    const texto = "Ola mundo JavaScript";
    console.log("Palavras:", contarPalavras(texto));
    console.log("Vogais:", contarVogais(texto));
    return 'Texto OK';
}

function main2() {
    console.log("JS tem", contarPalavras("JavaScript"), "palavras");
    return 'Curto OK';
}

function main3() {
    const frases = ["abc", "aeiou", "xyz"];
    frases.forEach(f => console.log(f, "vogais:", contarVogais(f)));
    return 'Frases OK';
}