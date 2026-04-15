from PIL import Image, ImageDraw, ImageFont

GLYPH_W = 40
GLYPH_H = 50

symbols = "0123456789:."

# используем системный шрифт
font = ImageFont.truetype("DejaVuSans-Bold.ttf", 48)

def render_char(ch):
    img = Image.new("L", (GLYPH_W, GLYPH_H), 0)
    draw = ImageDraw.Draw(img)

    w, h = draw.textbbox((0, 0), ch, font=font)[2:]
    x = (GLYPH_W - w) // 2
    y = (GLYPH_H - h) // 2

    draw.text((x, y), ch, fill=255, font=font)

    # бинаризация
    img = img.point(lambda p: 1 if p > 128 else 0)

    return img

# генерируем все глифы
bitstream = []

for ch in symbols:
    img = render_char(ch)

    for y in range(GLYPH_H):
        for x in range(GLYPH_W):
            bit = img.getpixel((x, y))
            bitstream.append(bit)

# запись в hex (по 1 биту → упакуем в hex)
with open("font.hex", "w") as f:
    byte = 0
    count = 0

    for bit in bitstream:
        byte = (byte << 1) | bit
        count += 1

        if count == 8:
            f.write(f"{byte:02x}\n")
            byte = 0
            count = 0

    # остаток
    if count > 0:
        byte <<= (8 - count)
        f.write(f"{byte:02x}\n")

print("font.hex generated!")