// ============================================
// JS 07 - Validação Email Avançada
// ============================================

function validarEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}

function validarEmails(lista) {
    return lista.split(';').filter(validarEmail).length;
}

function main1() {
    console.log("joao@email.com:", validarEmail("joao@email.com"));
    console.log("invalido:", validarEmail("invalido"));
    return 'Email OK';
}

function main2() {
    const lista = "joao@email.com;maria@gmail;teste@ok.br";
    console.log("Validos:", validarEmails(lista));
    return 'Lista OK';
}

function main3() {
    const emails = ["user@dom.com", "nao@temponto", "ok@br"];
    emails.forEach(e => console.log(e + ":", validarEmail(e)));
    return 'Array OK';
}