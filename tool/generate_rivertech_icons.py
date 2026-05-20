from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE_LOGO = ROOT / "assets/brand/source/logo_rivertech.png"

DEEP_BLUE = "#102870"
RIVER_BLUE = "#1038B0"
SIGNAL_BLUE = "#3860D8"
ICE = "#F7FAFF"
PALE_BLUE = "#EAF1FF"
WHITE = "#FFFFFF"

IOS_ICON_SIZES = [
    20,
    29,
    40,
    50,
    57,
    58,
    60,
    72,
    76,
    80,
    87,
    100,
    114,
    120,
    144,
    152,
    167,
    180,
    1024,
]

ANDROID_ICONS = {
    "mipmap-mdpi/ic_launcher.png": 48,
    "mipmap-hdpi/ic_launcher.png": 72,
    "mipmap-xhdpi/ic_launcher.png": 96,
    "mipmap-xxhdpi/ic_launcher.png": 144,
    "mipmap-xxxhdpi/ic_launcher.png": 192,
}


def cubic(points, steps):
    p0, p1, p2, p3 = points
    for i in range(steps + 1):
        t = i / steps
        mt = 1 - t
        x = (
            mt**3 * p0[0]
            + 3 * mt**2 * t * p1[0]
            + 3 * mt * t**2 * p2[0]
            + t**3 * p3[0]
        )
        y = (
            mt**3 * p0[1]
            + 3 * mt**2 * t * p1[1]
            + 3 * mt * t**2 * p2[1]
            + t**3 * p3[1]
        )
        yield x, y


def remove_white_background(image):
    image = image.convert("RGBA")
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if r > 246 and g > 246 and b > 246:
                pixels[x, y] = (255, 255, 255, 0)
            elif r > 230 and g > 230 and b > 235:
                fade = max(0, min(255, int((246 - max(r, g, b)) * 8)))
                pixels[x, y] = (r, g, b, min(a, fade))
    return image


def content_bbox(image):
    alpha = Image.new("L", image.size, 0)
    source = image.convert("RGBA")
    ap = alpha.load()
    sp = source.load()
    for y in range(source.height):
        for x in range(source.width):
            r, g, b, a = sp[x, y]
            if a and not (r > 245 and g > 245 and b > 245):
                ap[x, y] = 255
    return alpha.getbbox()


def crop_logo_assets():
    source = Image.open(SOURCE_LOGO).convert("RGBA")
    bbox = content_bbox(source)
    if bbox is None:
        raise RuntimeError("RiverTech source logo has no visible content")

    logo = remove_white_background(source.crop(bbox))
    logo.save(ROOT / "assets/brand/rivertech_logo.png")

    x0, y0, _x1, y1 = bbox
    mark_width = int((y1 - y0) * 0.45)
    mark_box = (x0, y0, x0 + mark_width, y1)
    mark = remove_white_background(source.crop(mark_box))
    mark.save(ROOT / "assets/brand/rivertech_mark.png")
    return mark


def fit(image, box, contain=True):
    bw, bh = box
    iw, ih = image.size
    scale = min(bw / iw, bh / ih) if contain else max(bw / iw, bh / ih)
    size = (max(1, int(iw * scale)), max(1, int(ih * scale)))
    return image.resize(size, Image.Resampling.LANCZOS)


def paste_center(base, layer, center):
    x = int(center[0] - layer.width / 2)
    y = int(center[1] - layer.height / 2)
    base.alpha_composite(layer, (x, y))


def draw_gradient(draw, size):
    width = height = size
    top = (255, 255, 255)
    bottom = (234, 241, 255)
    for y in range(height):
        t = y / max(1, height - 1)
        color = tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(3))
        draw.line([(0, y), (width, y)], fill=color)


def render_icon(size, mark):
    scale = 4
    canvas_size = size * scale
    image = Image.new("RGBA", (canvas_size, canvas_size), WHITE)
    draw = ImageDraw.Draw(image)
    draw_gradient(draw, canvas_size)

    def xy(point):
        return point[0] * canvas_size, point[1] * canvas_size

    # Soft blue depth, kept minimal so the icon still reads like an iOS mark.
    glow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse(
        (
            canvas_size * 0.14,
            canvas_size * 0.62,
            canvas_size * 0.86,
            canvas_size * 1.08,
        ),
        fill=(56, 96, 216, 26),
    )
    image.alpha_composite(glow.filter(ImageFilter.GaussianBlur(canvas_size * 0.06)))

    river_points = list(
        cubic(
            (
                xy((0.16, 0.68)),
                xy((0.34, 0.47)),
                xy((0.53, 0.82)),
                xy((0.84, 0.53)),
            ),
            100,
        )
    )
    stroke_width = max(5, int(canvas_size * 0.095))
    radius = stroke_width / 2
    draw.line(river_points, fill=SIGNAL_BLUE, width=stroke_width)
    for x, y in river_points[::2]:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=SIGNAL_BLUE)

    route_points = list(
        cubic(
            (
                xy((0.24, 0.68)),
                xy((0.40, 0.54)),
                xy((0.52, 0.74)),
                xy((0.76, 0.55)),
            ),
            70,
        )
    )
    route_width = max(3, int(canvas_size * 0.035))
    draw.line(route_points, fill=WHITE, width=route_width)
    rr = route_width / 2
    for x, y in route_points[::3]:
        draw.ellipse((x - rr, y - rr, x + rr, y + rr), fill=WHITE)

    for center, color, point_radius in [
        ((0.30, 0.63), RIVER_BLUE, 0.055),
        ((0.72, 0.57), DEEP_BLUE, 0.050),
    ]:
        cx, cy = xy(center)
        r = point_radius * canvas_size
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color)
        inner = r * 0.42
        draw.ellipse((cx - inner, cy - inner, cx + inner, cy + inner), fill=WHITE)

    horizon = (
        canvas_size * 0.32,
        canvas_size * 0.82,
        canvas_size * 0.68,
        canvas_size * 0.86,
    )
    draw.rounded_rectangle(horizon, radius=int(canvas_size * 0.02), fill=DEEP_BLUE)

    mark_target = fit(mark, (int(canvas_size * 0.25), int(canvas_size * 0.25)))
    paste_center(image, mark_target, xy((0.50, 0.25)))

    return image.convert("RGB").resize((size, size), Image.Resampling.LANCZOS)


def main():
    mark = crop_logo_assets()

    preview = render_icon(1024, mark)
    preview.save(ROOT / "assets/brand/rivertech_app_icon.png")

    ios_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for size in IOS_ICON_SIZES:
        render_icon(size, mark).save(ios_dir / f"{size}.png")

    android_dir = ROOT / "android/app/src/main/res"
    for relative_path, size in ANDROID_ICONS.items():
        render_icon(size, mark).save(android_dir / relative_path)


if __name__ == "__main__":
    main()
