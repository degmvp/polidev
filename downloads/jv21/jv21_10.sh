JV21_10 - Java 21 LTS na prática

Descrição: Como tirar tudo isso do papel no mundo corporativo. Na prática, não se usa tudo ao mesmo tempo. O fluxo ideal de adoção do Java 21 envolve: fazer o upgrade do JDK (geralmente do 11 ou 17), habilitar o Generational ZGC para ganhar performance imediata, utilizar Sequenced Collections e Pattern Matching para pagar o débito técnico de código legado, e, por fim, introduzir Virtual Threads em pontos específicos de I/O (como chamadas HTTP ou de Banco de Dados), sempre atento para não usar features Preview (como String Templates) em ambientes de produção críticos.

Exemplo: (prático simulando uma integração real com Spring Boot 3.2+ que já suporta Virtual Threads nativamente)

// application.properties
// spring.threads.virtual.enabled=true

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.concurrent.Executors;

@RestController
public class ApiPraticaController {

    @GetMapping("/processar-dados")
    public String processar() throws Exception {
        // O Spring Boot 3.2+ roda este método dentro de uma Virtual Thread automaticamente!
        // Não há mais necessidade de anotações @Async ou Returns Mono<>();
        
        var executor = Executors.newVirtualThreadPerTaskExecutor();
        
        // Chamadas I/O paralelas síncronas (o código é fácil de ler e manter)
        String cliente = executor.submit(() -> chamarApiExterna("Cliente")).get();
        String produto = executor.submit(() -> chamarApiExterna("Produto")).get();
        
        return "Resultado: " + cliente + " e " + produto;
    }

    private String chamarApiExterna(String sistema) throws InterruptedException {
        Thread.sleep(1000); // Simula latência de rede
        return "Dados do " + sistema;
    }
}