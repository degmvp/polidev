// ============================================
// JS 04 - Strings: Inverter + Palíndromo
// ============================================

// 11 - Inverter string
function inverterString(str) {
    return str.split('').reverse().join('');
}

// 15 - Palíndromo
function ehPalindromo(str) {
    const limpa = str.toLowerCase().replace(/[^a-z0-9]/g, '');
    return limpa === inverterString(limpa);
}

function main1() {
    console.log("radar palindromo?", ehPalindromo("radar"));
    console.log("Inverter abc:", inverterString("abc"));
    return 'Strings OK';
}

function main2() {
    console.log("A man a plan palindromo?", 
        ehPalindromo("A man a plan a canal Panama"));
    return 'Complexo OK';
}

function main3() {
    const palavras = ["ana", "bob", "xyz"];
    palavras.forEach(p => {
        console.log(`${p}: ${ehPalindromo(p)}`);
    });
    return 'Lista OK';
}