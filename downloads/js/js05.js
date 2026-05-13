// ============================================
// JS 05 - Arrays: Sort + Busca Binária
// ============================================

// 12 - Bubble sort (didático)
function bubbleSort(arr) {
    let n = arr.length;
    for (let i = 0; i < n - 1; i++)
        for (let j = 0; j < n - i - 1; j++)
            if (arr[j] > arr[j + 1]) [arr[j], arr[j + 1]] = [arr[j + 1], arr[j]];
    return arr;
}

// 13 - Busca binária
function buscaBinaria(arr, x) {
    let left = 0, right = arr.length - 1;
    while (left <= right) {
        let mid = Math.floor((left + right) / 2);
        if (arr[mid] === x) return mid;
        if (arr[mid] < x) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}

function main1() {
    let arr = [64, 34, 25, 12, 22, 11, 90];
    console.log("Ordenado:", bubbleSort([...arr]));
    console.log("Busca 22:", buscaBinaria(bubbleSort([...arr]), 22));
    return 'Array OK';
}

function main2() {
    console.log("Busca 99:", buscaBinaria([1,2,3,4,5], 99));
    return 'Não encontrado OK';
}

function main3() {
    const notas = [10,20,30,40,50,60,70];
    console.log("Pos 40:", buscaBinaria(notas, 40));
    return 'Notas OK';
}