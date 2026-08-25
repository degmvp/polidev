// ════════════════════════════════════════════════════════════════════════════
// wx-cp-016-wxcp.cpp — Caminho Mínimo: Dijkstra
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Calcula a distância mínima de uma origem a todos os vértices de um grafo
//   com pesos não negativos, em O((V + E) log V) usando fila de prioridade.
//   Base para rotas (GPS), redes, jogos e planejamento de trajetos.
//
// EXEMPLO:
//   arestas: 0-1:4, 0-2:1, 2-1:2, 1-3:1, 2-3:5, 3-4:3
//   distâncias a partir de 0 -> {0, 3, 1, 4, 7}
// ════════════════════════════════════════════════════════════════════════════

#include <vector>
#include <queue>
#include <limits>
#include <utility>
#include <iostream>

using Graph = std::vector<std::vector<std::pair<int, long long>>>;

std::vector<long long> dijkstra(const Graph& graph, int source) {
    std::vector<long long> dist(graph.size(), std::numeric_limits<long long>::max());
    using PQItem = std::pair<long long, int>;
    std::priority_queue<PQItem, std::vector<PQItem>, std::greater<PQItem>> pq;
    dist[source] = 0;
    pq.push({0, source});
    while (!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();
        if (d > dist[u]) continue;                     // entrada obsoleta
        for (auto [v, w] : graph[u])
            if (dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
                pq.push({dist[v], v});
            }
    }
    return dist;
}

int main() {
    Graph g(5);
    auto add = [&](int u, int v, long long w) {
        g[u].push_back({v, w});
        g[v].push_back({u, w});
    };
    add(0, 1, 4); add(0, 2, 1); add(2, 1, 2);
    add(1, 3, 1); add(2, 3, 5); add(3, 4, 3);
    for (long long d : dijkstra(g, 0))
        std::cout << d << ' ';        // 0 3 1 4 7
    std::cout << '\n';
}