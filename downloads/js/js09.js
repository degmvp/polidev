// ============================================
// JS 09 - Menu Console Simulado
// ============================================

function mostrarMenu() {
    return `
=== MENU JS ===
1 - Somar
2 - Palíndromo
3 - Sair
Opção: `.trim();
}

function main1() {
    console.log(mostrarMenu());
    // Simula input 1
    console.log("Escolheu 1 -> Somar 10+20=30");
    return 'Menu OK';
}

function main2() {
    const opcoes = {1: 'Soma', 2: 'Palíndromo'};
    console.log("Opção 2:", opcoes[2]);
    return 'Switch OK';
}

function main3() {
    console.log("=== Execuções simuladas ===");
    console.log("Exec1: Op1");
    console.log("Exec2: Op2");  
    console.log("Exec3: Op3 - Sai");
    return 'Loop OK';
}