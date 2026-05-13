// ============================================
// JS 12 - Objetos/Maps Simples
// ============================================

const Aluno = {
    nome: "Joao",
    idade: 25,
    nota: 8.5,
    aprovado() { return this.nota >= 7; }
};

function mediaAlunos(alunos) {
    return alunos.reduce((sum, a) => sum + a.nota, 0) / alunos.length;
}

function main1() {
    console.log(Aluno.nome, Aluno.aprovado() ? "Aprovado" : "Reprovado");
    return 'Objeto OK';
}

function main2() {
    const turma = [
        {nome: "Ana", nota: 9.0},
        {nome: "Carlos", nota: 6.5},
        {nome: "Beatriz", nota: 8.0}
    ];
    console.log("Media:", mediaAlunos(turma));
    return 'Turma OK';
}

function main3() {
    const notas = new Map();
    notas.set("Joao", 8.5).set("Maria", 9.2);
    console.log("Maria:", notas.get("Maria"));
    return 'Map OK';
}