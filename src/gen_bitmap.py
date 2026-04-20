from PIL import Image, ImageDraw, ImageFont
from functools import reduce

GLYPH_W = 40
GLYPH_H = 50
SYMBOLS = "0123456789:.ВСЁ"

COLOR_FG = 0xFFF
COLOR_BG = 0x000

try:
    font = ImageFont.truetype("DejaVuSans-Bold.ttf", 60)
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
    return img;


if __name__ == "__main__":
    f = open("font.hex", "w")
    for ch in SYMBOLS:
        img = render_char(ch)
        for y in range(GLYPH_H):
            line=""
            for x in range(GLYPH_W):
                pix = f"{img.getpixel((x, y)):02x}"
                line+=pix
            f.write(line+'\n')
    print('-'*14)
    print(f"len(SYMBOLS): {len(SYMBOLS)}") # 12
    print(f"word length: {GLYPH_W*8}")     # 320
    print(f"max_address: {GLYPH_H*len(SYMBOLS)-1}") #599
    print('-'*14)