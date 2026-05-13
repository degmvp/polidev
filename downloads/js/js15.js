// ============================================
// JS 15 - Data/Hora + Formatação
// ============================================

function formatarData(data) {
    return data.toLocaleDateString('pt-BR');
}

function diasNoMes(mes, ano) {
    const data = new Date(ano, mes, 0);
    return data.getDate();
}

function main1() {
    const hoje = new Date();
    console.log("Hoje:", formatarData(hoje));
    console.log("Dias maio 2026:", diasNoMes(4, 2026)); // mes 0-index
    return 'Data OK';
}

function main2() {
    const bissexto = new Date(2024, 1, 29); // 29/fev/2024
    console.log("2024 bissexto?", bissexto.getMonth() === 1);
    return 'Bisexto OK';
}

function main3() {
    const datas = [
        new Date(2026, 0, 1),
        new Date(2024, 1, 29),
        new Date(2025, 11, 31)
    ];
    datas.forEach((d, i) => console.log(`Data ${i+1}:`, formatarData(d)));
    return 'Datas OK';
}