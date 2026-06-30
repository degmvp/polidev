from PIL import Image, ImageDraw, ImageFont

imagem = Image.open("mod.jpg").convert("RGBA")

camada = Image.new("RGBA", imagem.size, (255, 255, 255, 0))
draw = ImageDraw.Draw(camada)

texto = "JDK 21"

try:
    fonte = ImageFont.truetype("arial.ttf", 28)
except:
    fonte = ImageFont.load_default()

x = imagem.width - 100
y = imagem.height - 35

draw.text(
    (x, y),
    texto,
    fill=(255, 215, 0, 220),  # dourado
    font=fonte
)

resultado = Image.alpha_composite(imagem, camada)
resultado = resultado.convert("RGB")
resultado.save("java21_marca.jpg")

print("Imagem criada: java21_marca.jpg")