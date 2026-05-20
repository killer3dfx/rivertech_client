from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE_LOGO = ROOT / "assets/brand/source/logo_rivertech.png"
SOURCE_APP_ICON = ROOT / "assets/brand/rivertech_app_icon_source.png"

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


def render_app_icon(size):
    source = Image.open(SOURCE_APP_ICON).convert("RGB")
    icon = ImageOps.fit(source, (size, size), Image.Resampling.LANCZOS)
    return icon


def main():
    crop_logo_assets()

    preview = render_app_icon(1024)
    preview.save(ROOT / "assets/brand/rivertech_app_icon.png")

    ios_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for size in IOS_ICON_SIZES:
        render_app_icon(size).save(ios_dir / f"{size}.png")

    android_dir = ROOT / "android/app/src/main/res"
    for relative_path, size in ANDROID_ICONS.items():
        render_app_icon(size).save(android_dir / relative_path)


if __name__ == "__main__":
    main()
