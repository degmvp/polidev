// ============================================
// JS 03 - Primos + Fatorial
// ============================================

// 9 - Primo otimizado
function ehPrimo(n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 === 0 || n % 3 === 0) return false;
    for (let i = 5; i * i <= n; i += 6) {
        if (n % i === 0 || n % (i + 2) === 0) return false;
    }
    return true;
}

// 10 - Fatorial
function fatorial(n) {
    let fat = 1;
    for (let i = 2; i <= n; i++) fat *= i;
    return fat;
}

function main1() {
    console.log("Primos 1-20:", 
        Array.from({length: 20}, (_, i) => i + 1)
             .filter(ehPrimo).join(' '));
    console.log("Fatorial 6:", fatorial(6));
    return 'Primos OK';
}

function main2() {
    console.log("17 primo?", ehPrimo(17));
    console.log("Fatorial 0:", fatorial(0));
    return 'Teste OK';
}

function main3() {
    const primos = Array(101).fill().map((_, i) => i)
        .filter(ehPrimo).slice(10, 15);
    console.log("Primos 10-15:", primos);
    return 'Intervalo OK';
}