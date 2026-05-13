// ============================================
// JS 08 - Calculadora com Objeto
// ============================================

const Calculadora = {
    somar: (a, b) => a + b,
    subtrair: (a, b) => a - b,
    multiplicar: (a, b) => a * b,
    dividir: (a, b) => b !== 0 ? a / b : NaN
};

function main1() {
    console.log("10+5:", Calculadora.somar(10, 5));
    console.log("10/0:", Calculadora.dividir(10, 0));
    return 'Calc OK';
}

function main2() {
    const ops = { '+': Calculadora.somar, '-': Calculadora.subtrair };
    console.log("15-5:", ops['-'](15, 5));
    return 'Objeto OK';
}

function main3() {
    const resultado = {
        soma: Calculadora.somar(20, 30),
        produto: Calculadora.multiplicar(4, 5)
    };
    console.log(resultado);
    return 'Objeto completo OK';
}