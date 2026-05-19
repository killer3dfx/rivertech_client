from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
BACKGROUND = "#082F3A"
WAVE = "#7FE3D7"
NODE = "#FFFFFF"
ACCENT = "#1FB6A6"

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


def render_icon(size):
    scale = 4
    canvas_size = size * scale
    image = Image.new("RGB", (canvas_size, canvas_size), BACKGROUND)
    draw = ImageDraw.Draw(image)

    def xy(point):
        return point[0] * canvas_size, point[1] * canvas_size

    wave_points = list(
        cubic(
            (
                xy((0.18, 0.64)),
                xy((0.36, 0.36)),
                xy((0.56, 0.75)),
                xy((0.82, 0.42)),
            ),
            80,
        )
    )
    stroke_width = max(4, int(canvas_size * 0.09))
    radius = stroke_width / 2
    draw.line(wave_points, fill=WAVE, width=stroke_width)
    for x, y in wave_points[::2]:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=WAVE)

    for center, radius in [((0.34, 0.42), 0.085), ((0.68, 0.57), 0.075)]:
        cx, cy = xy(center)
        r = radius * canvas_size
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=NODE)

    x0, y0 = xy((0.28, 0.76))
    x1, y1 = xy((0.72, 0.81))
    draw.rounded_rectangle(
        (x0, y0, x1, y1),
        radius=int(canvas_size * 0.025),
        fill=ACCENT,
    )

    return image.resize((size, size), Image.Resampling.LANCZOS)


def main():
    ios_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for size in IOS_ICON_SIZES:
        render_icon(size).save(ios_dir / f"{size}.png")

    android_dir = ROOT / "android/app/src/main/res"
    for relative_path, size in ANDROID_ICONS.items():
        render_icon(size).save(android_dir / relative_path)


if __name__ == "__main__":
    main()
