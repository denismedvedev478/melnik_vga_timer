from PIL import Image, ImageDraw, ImageFont

GLYPH_W = 50   # ширина символа
GLYPH_H = 40   # высота символа
symbols = "0123456789:."

# Используйте существующий шрифт, например, "arial.ttf" или укажите полный путь
try:
    font = ImageFont.truetype("DejaVuSans-Bold.ttf", 48)
except:
    font = ImageFont.load_default()  # запасной вариант

def render_char(ch):
    img = Image.new("L", (GLYPH_W, GLYPH_H), 0)
    draw = ImageDraw.Draw(img)
    # Центрирование символа
    bbox = draw.textbbox((0, 0), ch, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (GLYPH_W - w) // 2 - bbox[0]
    y = (GLYPH_H - h) // 2 - bbox[1]
    draw.text((x, y), ch, fill=255, font=font)
    # Бинаризация: порог 128
    img = img.point(lambda p: 1 if p > 128 else 0)
    return img

# Генерация битового потока
bitstream = []
for ch in symbols:
    img = render_char(ch)
    for y in range(GLYPH_H):
        for x in range(GLYPH_W):
            bitstream.append(img.getpixel((x, y)))

# Запись в файл font.hex (8 бит на байт, старший бит байта = первый пиксель)
with open("font.hex", "w") as f:
    byte = 0
    count = 0
    for bit in bitstream:
        byte = (byte << 1) | bit   # первый бит -> старший
        count += 1
        if count == 8:
            f.write(f"{byte:02x}\n")
            byte = 0
            count = 0
    # Остаток (дополняем нулями справа)
    if count > 0:
        byte <<= (8 - count)
        f.write(f"{byte:02x}\n")

print("font.hex generated!")