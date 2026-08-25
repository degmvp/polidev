// ════════════════════════════════════════════════════════════════════════════
// wx-cp-013-wxcp.cpp — Codificação/Decodificação Base64
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Codifica dados binários em texto ASCII seguro (64 caracteres) e decodifica
//   de volta. Padrão em APIs REST (autenticação Basic), e-mail (MIME),
//   transferência de arquivos e armazenamento de blobs em JSON.
//
// EXEMPLO:
//   base64Encode("hello") -> "aGVsbG8="
//   base64Decode("aGVsbG8=") -> "hello"
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <array>
#include <stdexcept>
#include <iostream>

namespace base64 {
    constexpr const char* chars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    std::string encode(const std::string& in) {
        std::string out;
        int val = 0, bits = -6;
        for (unsigned char c : in) {
            val = (val << 8) + c;
            bits += 8;
            while (bits >= 0) {
                out.push_back(chars[(val >> bits) & 0x3F]);
                bits -= 6;
            }
        }
        if (bits > -6) out.push_back(chars[((val << 8) >> (bits + 8)) & 0x3F]);
        while (out.size() % 4) out.push_back('=');
        return out;
    }

    std::string decode(const std::string& in) {
        std::array<int, 256> table{};
        table.fill(-1);
        for (int i = 0; i < 64; ++i)
            table[static_cast<unsigned char>(chars[i])] = i;
        std::string out;
        int val = 0, bits = -8;
        for (unsigned char c : in) {
            if (c == '=' || c == '\n' || c == '\r') continue;
            int d = table[c];
            if (d < 0) throw std::invalid_argument("Base64 inválido");
            val = (val << 6) + d;
            bits += 6;
            if (bits >= 0) {
                out.push_back(static_cast<char>((val >> bits) & 0xFF));
                bits -= 8;
            }
        }
        return out;
    }
}

int main() {
    std::string enc = base64::encode("hello");
    std::cout << enc << '\n';                       // aGVsbG8=
    std::cout << base64::decode(enc) << '\n';       // hello
}