// ============================================
// JS 10 - Gerador Aleatórios + Sort
// ============================================

function numeroAleatorio(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function gerarArrayAleatorio(n, min, max) {
    return Array(n).fill().map(() => numeroAleatorio(min, max));
}

function main1() {
    console.log("10 nums 1-100:", gerarArrayAleatorio(10, 1, 100));
    return 'Aleatorio OK';
}

function main2() {
    const arr = gerarArrayAleatorio(5, 10, 50);
    console.log("Array:", arr, "Ordenado:", arr.sort((a,b)=>a-b));
    return 'Sort OK';
}

function main3() {
    console.log("Loteria 6/49:", gerarArrayAleatorio(6, 1, 49).sort((a,b)=>a-b));
    return 'Loteria OK';
}