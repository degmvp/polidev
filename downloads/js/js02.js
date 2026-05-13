// ============================================
// JS 02 - Decimal/Binário + Bitwise
// ============================================

// 3 - Decimal para binário
function decimalBinario(num) {
    return num === 0 ? '0' : decimalBinario(Math.floor(num / 2)) + (num % 2);
}

// 4-8 - Operações bitwise
function bitwiseAND(a, b) { return a & b; }
function bitwiseOR(a, b) { return a | b; }
function bitwiseXOR(a, b) { return a ^ b; }
function bitwiseNOT(a) { return ~a; }
function shiftLeft(a, n) { return a << n; }

function main1() {
    console.log("13 binario:", decimalBinario(13));
    console.log("12 & 10:", bitwiseAND(12, 10));
    return 'JS Bitwise OK';
}

function main2() {
    console.log("12 | 10:", bitwiseOR(12, 10));
    console.log("~12:", bitwiseNOT(12));
    console.log("5 << 2:", shiftLeft(5, 2));
    return 'Shift OK';
}

function main3() {
    let flags = 0;
    flags |= 1;  // Flag1
    flags |= 4;  // Flag3
    console.log("Flags:", flags, (flags & 1) ? 'Flag1 ativa' : '');
    return 'Flags OK';
}