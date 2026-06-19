"""
Memory Card 앱 아이콘 생성 스크립트
딥 퍼플 + 골드 테마 - 카드 2장 디자인
"""

import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

SIZE = 1024
RADIUS = 180  # 모서리 둥글기


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def make_gradient_bg(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pixels = img.load()
    top = (18, 5, 51)      # #120533
    mid = (58, 16, 110)    # #3a106e
    bot = (90, 8, 145)     # #5a0891
    for y in range(size):
        t = y / size
        if t < 0.5:
            c = lerp_color(top, mid, t * 2)
        else:
            c = lerp_color(mid, bot, (t - 0.5) * 2)
        for x in range(size):
            tx = x / size
            cr = lerp_color(c, (110, 20, 180), tx * 0.35)
            pixels[x, y] = (*cr, 255)
    return img


def draw_rounded_rect(draw, xy, radius, fill, outline=None, outline_width=0):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill,
                           outline=outline, width=outline_width)


def rotate_point(px, py, cx, cy, angle_deg):
    angle = math.radians(angle_deg)
    dx, dy = px - cx, py - cy
    rx = dx * math.cos(angle) - dy * math.sin(angle)
    ry = dx * math.sin(angle) + dy * math.cos(angle)
    return cx + rx, cy + ry


def draw_card_back(img, cx, cy, w, h, angle_deg):
    """홀로그래픽 카드 뒷면"""
    card = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(card)

    # 카드 영역 좌표 (중심 기준)
    x0, y0 = cx - w // 2, cy - h // 2
    x1, y1 = cx + w // 2, cy + h // 2

    # 카드 그림자
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([x0 + 12, y0 + 14, x1 + 12, y1 + 14],
                          radius=24, fill=(0, 0, 0, 140))
    shadow = shadow.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(shadow)

    # 카드 본체 - 딥 퍼플 그라디언트
    card_body = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bd = ImageDraw.Draw(card_body)
    for row in range(h):
        t = row / h
        c = lerp_color((80, 20, 140), (120, 40, 200), t)
        bd.line([(0, row), (w, row)], fill=(*c, 255))
    # 마스킹으로 둥근 모서리 적용
    mask = Image.new("L", (w, h), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, w - 1, h - 1], radius=24, fill=255)
    card_body.putalpha(mask)

    tmp = Image.new("RGBA", img.size, (0, 0, 0, 0))
    tmp.paste(card_body, (x0, y0))
    tmp = tmp.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(tmp)

    # 골드 테두리
    border_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    bd2 = ImageDraw.Draw(border_layer)
    bd2.rounded_rectangle([x0, y0, x1, y1], radius=24,
                          fill=None, outline=(212, 175, 55, 255), width=5)
    border_layer = border_layer.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(border_layer)

    # 카드 내부 패턴 (다이아몬드)
    pattern_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    pd = ImageDraw.Draw(pattern_layer)

    # 내부 테두리
    pd.rounded_rectangle([x0 + 18, y0 + 18, x1 - 18, y1 - 18],
                          radius=16, fill=None, outline=(180, 120, 255, 100), width=2)

    # 다이아몬드 패턴
    diamond_pts = [
        (cx, cy - 130), (cx + 90, cy), (cx, cy + 130), (cx - 90, cy)
    ]
    pd.polygon(diamond_pts, fill=None, outline=(212, 175, 55, 160), width=3)
    diamond_pts2 = [
        (cx, cy - 70), (cx + 50, cy), (cx, cy + 70), (cx - 50, cy)
    ]
    pd.polygon(diamond_pts2, fill=None, outline=(212, 175, 55, 100), width=2)

    # 중앙 원
    pd.ellipse([cx - 20, cy - 20, cx + 20, cy + 20],
               fill=(180, 100, 255, 150), outline=(212, 175, 55, 200), width=3)

    # 모서리 점
    for (ox, oy) in [(-80, -160), (80, -160), (-80, 160), (80, 160)]:
        pd.ellipse([cx + ox - 8, cy + oy - 8, cx + ox + 8, cy + oy + 8],
                   fill=(212, 175, 55, 180))

    pattern_layer = pattern_layer.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(pattern_layer)


def draw_star(draw, cx, cy, r_outer, r_inner, points, fill, outline=None, outline_width=0):
    pts = []
    for i in range(points * 2):
        angle = math.radians(i * 180 / points - 90)
        r = r_outer if i % 2 == 0 else r_inner
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(pts, fill=fill, outline=outline, width=outline_width)


def draw_card_front(img, cx, cy, w, h, angle_deg):
    """앞면 카드 (별 아이콘)"""
    x0, y0 = cx - w // 2, cy - h // 2
    x1, y1 = cx + w // 2, cy + h // 2

    # 그림자
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([x0 + 15, y0 + 18, x1 + 15, y1 + 18],
                          radius=24, fill=(0, 0, 0, 160))
    shadow = shadow.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(shadow)

    # 카드 본체 - 밝은 라벤더/화이트
    front_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(front_layer)
    fd.rounded_rectangle([x0, y0, x1, y1], radius=24, fill=(245, 235, 255, 255))
    front_layer = front_layer.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(front_layer)

    # 골드 테두리
    border_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    bd = ImageDraw.Draw(border_layer)
    bd.rounded_rectangle([x0, y0, x1, y1], radius=24,
                          fill=None, outline=(212, 175, 55, 255), width=6)
    bd.rounded_rectangle([x0 + 14, y0 + 14, x1 - 14, y1 - 14], radius=16,
                          fill=None, outline=(212, 175, 55, 120), width=2)
    border_layer = border_layer.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(border_layer)

    # 별 아이콘 (중앙) - 골드 글로우 효과
    star_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd2 = ImageDraw.Draw(star_layer)

    # 별 글로우 (크고 투명)
    for glow_r in [95, 80, 68]:
        alpha = [30, 60, 90][([95, 80, 68].index(glow_r))]
        draw_star(sd2, cx, cy, glow_r, glow_r * 0.45, 5,
                  fill=(255, 215, 0, alpha))

    # 별 본체
    draw_star(sd2, cx, cy, 88, 38, 5, fill=(255, 215, 0, 255))
    # 별 하이라이트
    draw_star(sd2, cx, cy, 86, 36, 5, fill=None,
              outline=(255, 255, 200, 200), outline_width=3)

    # 모서리 "?" 표시
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 52)
    except Exception:
        font = ImageFont.load_default()

    sd2.text((x0 + 22, y0 + 16), "?", font=font, fill=(212, 175, 55, 220))

    # 하단 "?" (180도 회전)
    q_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    qd = ImageDraw.Draw(q_layer)
    qd.text((x1 - 54, y1 - 70), "?", font=font, fill=(212, 175, 55, 220))
    q_layer = q_layer.rotate(180, center=(x1 - 28, y1 - 44))
    star_layer.alpha_composite(q_layer)

    star_layer = star_layer.rotate(-angle_deg, center=(cx, cy), resample=Image.BICUBIC)
    img.alpha_composite(star_layer)


def draw_sparkle(draw, cx, cy, size, alpha=220):
    """4방향 반짝이"""
    gold = (255, 215, 0, alpha)
    for angle in [0, 90]:
        r = math.radians(angle)
        pts = [
            (cx + size * math.cos(r), cy + size * math.sin(r)),
            (cx + size * 0.15 * math.cos(r + math.pi / 2), cy + size * 0.15 * math.sin(r + math.pi / 2)),
            (cx - size * math.cos(r), cy - size * math.sin(r)),
            (cx + size * 0.15 * math.cos(r - math.pi / 2), cy + size * 0.15 * math.sin(r - math.pi / 2)),
        ]
        draw.polygon(pts, fill=gold)


def add_vignette(img):
    vig = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vig)
    for i in range(120):
        alpha = int((i / 120) ** 1.5 * 130)
        vd.rounded_rectangle([i, i, SIZE - i, SIZE - i], radius=max(0, RADIUS - i),
                              fill=None, outline=(0, 0, 0, alpha), width=1)
    img.alpha_composite(vig)


def generate_icon():
    # 배경
    img = make_gradient_bg(SIZE)

    # 미묘한 원형 빛 효과 (상단)
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow_layer)
    for r in range(280, 0, -10):
        alpha = int((1 - r / 280) ** 2 * 40)
        gd.ellipse([SIZE // 2 - r, 80 - r // 2, SIZE // 2 + r, 80 + r // 2 + r],
                   fill=(160, 80, 255, alpha))
    img.alpha_composite(glow_layer)

    # 카드 뒷면 (왼쪽, -12도 기울기)
    draw_card_back(img, 460, 480, 310, 430, 12)

    # 카드 앞면 (오른쪽, +10도 기울기)
    draw_card_front(img, 540, 505, 310, 430, -10)

    # 반짝이 효과
    sparkle_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sparkle_layer)
    draw_sparkle(sd, 185, 195, 28, 200)
    draw_sparkle(sd, 835, 215, 22, 180)
    draw_sparkle(sd, 145, 795, 18, 160)
    draw_sparkle(sd, 875, 760, 24, 190)
    draw_sparkle(sd, 310, 100, 14, 140)
    draw_sparkle(sd, 720, 88, 16, 150)
    img.alpha_composite(sparkle_layer)

    # 하단 텍스트
    text_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    td = ImageDraw.Draw(text_layer)

    try:
        font_big = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 84)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 54)
    except Exception:
        font_big = ImageFont.load_default()
        font_small = font_big

    # 텍스트 그림자
    for dx, dy in [(3, 3), (4, 4)]:
        td.text((SIZE // 2 + dx, 870 + dy), "MEMORY", font=font_big,
                fill=(60, 0, 100, 120), anchor="mm")
        td.text((SIZE // 2 + dx, 948 + dy), "CARD", font=font_small,
                fill=(60, 0, 100, 120), anchor="mm")

    # 골드 텍스트
    td.text((SIZE // 2, 870), "MEMORY", font=font_big,
            fill=(255, 215, 0, 255), anchor="mm")
    td.text((SIZE // 2, 948), "CARD", font=font_small,
            fill=(255, 200, 50, 220), anchor="mm")

    img.alpha_composite(text_layer)

    # 비네트 효과
    add_vignette(img)

    # 둥근 모서리 마스킹
    mask = Image.new("L", (SIZE, SIZE), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=RADIUS, fill=255)
    result = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    result.paste(img, mask=mask)

    # PNG로 저장
    out_path = "/home/herks/projects/memory_card/assets/icon/app_icon.png"
    result.save(out_path, "PNG")
    print(f"아이콘 생성 완료: {out_path}")

    # iOS 1024×1024 (모서리 없음 - App Store용)
    ios_result = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ios_result.paste(img)
    ios_path = "/home/herks/projects/memory_card/assets/icon/app_icon_ios.png"
    ios_result.save(ios_path, "PNG")
    print(f"iOS 아이콘 생성 완료: {ios_path}")

    return result


if __name__ == "__main__":
    generate_icon()
