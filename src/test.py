from PIL import Image, ImageDraw, ImageFont

GLYPH_W = 4
GLYPH_H = 5
SYMBOLS = "0123456789:."

COLOR_FG = 0xFFF
COLOR_BG = 0x000

try:
    font = ImageFont.truetype("DejaVuSans-Bold.ttf", 6)
except:
    font = ImageFont.load_default()

def render_char(ch):
    img = Image.new("L", (GLYPH_W, GLYPH_H), 0)
    draw = ImageDraw.Draw(img)
    bbox = draw.textbbox((0, 0), ch, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (GLYPH_W - w) // 2 - bbox[0]
    y = (GLYPH_H - h) // 2 - bbox[1]
    draw.text((x, y), ch, fill=255, font=font)
    #img.save(f"pngs/P_{ch}_br.png")
    mask = img.point(lambda p: 1 if p > 128 else 0)
    #mask.save(f"pngs/mask_{ch}_br.png")
    return mask;

# Генерация 16-битных цветных значений для каждого пикселя
pixel_data = []   # список 16-битных слов
mask = render_char("0");
    
# Запись в файл font.hex (по одному 16-битному слову на строку в hex)
with open("font.hex", "w") as f:
    for value in pixel_data:
        f.write(f"{value:03x}\n")   # 3 hex цифры = 12 бит, но для 16-бит используем 4 цифры
        # Для 16-бит: f.write(f"{value:04x}\n") – но значение у нас 0xFFF, будет "0fff"