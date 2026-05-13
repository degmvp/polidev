// ============================================
// JS 06 - MDC + Frações
// ============================================

// 14 - MDC Euclides
function mdc(a, b) {
    return b === 0 ? a : mdc(b, a % b);
}

function simplificarFracao(num, den) {
    const d = mdc(num, den);
    return [num / d, den / d];
}

function main1() {
    console.log("MDC(48,18):", mdc(48, 18));
    console.log("MDC(100,25):", mdc(100, 25));
    return 'MDC OK';
}

function main2() {
    const [n, d] = simplificarFracao(12, 18);
    console.log("12/18 = ", n, "/", d);
    return 'Fração OK';
}

function main3() {
    const testes = [[36,24], [45,60], [1001,1001]];
    testes.forEach(([a,b]) => {
        console.log(`MDC(${a},${b}) = ${mdc(a,b)}`);
    });
    return 'Testes OK';
}