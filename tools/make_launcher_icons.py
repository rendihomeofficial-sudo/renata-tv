"""Buat ikon launcher Android (legacy + adaptive) dan logo splash.

Sumber: assets/icons/app_icon.png (512x512 RGBA, ikon TV retro).
Keluaran:
  android/app/src/main/res/mipmap-*/ic_launcher.png        (ikon legacy)
  android/app/src/main/res/mipmap-*/ic_launcher_foreground.png (adaptive foreground)
  android/app/src/main/res/drawable-nodpi/splash_logo.png  (logo splash native)
"""

import os
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets", "icons", "app_icon.png")
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")

BG_TOP = (27, 34, 49)      # AppColors.surfaceElevated
BG_BOTTOM = (11, 14, 20)   # AppColors.background

# Ukuran ikon legacy (px) dan adaptive foreground (px) per densitas.
DENSITIES = {
    "mdpi": (48, 108),
    "hdpi": (72, 162),
    "xhdpi": (96, 216),
    "xxhdpi": (144, 324),
    "xxxhdpi": (192, 432),
}


def vertical_gradient(size, top, bottom):
    grad = Image.new("RGBA", (1, size), (0, 0, 0, 0))
    px = grad.load()
    for y in range(size):
        t = y / max(size - 1, 1)
        px[0, y] = (
            int(top[0] + (bottom[0] - top[0]) * t),
            int(top[1] + (bottom[1] - top[1]) * t),
            int(top[2] + (bottom[2] - top[2]) * t),
            255,
        )
    return grad.resize((size, size), Image.NEAREST)


def rounded_mask(size, radius_ratio=0.22):
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=int(size * radius_ratio), fill=255
    )
    return mask


def make_legacy(icon, size):
    """Ikon launcher lawas: latar gelap membulat + logo di tengah."""
    canvas = vertical_gradient(size, BG_TOP, BG_BOTTOM)
    canvas.putalpha(rounded_mask(size))
    logo = icon.resize((int(size * 0.82), int(size * 0.82)), Image.LANCZOS)
    canvas.alpha_composite(logo, ((size - logo.width) // 2, (size - logo.height) // 2))
    return canvas


def make_foreground(icon, size):
    """Foreground adaptive: logo di dalam safe zone (66/108)."""
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    logo = icon.resize((int(size * 0.56), int(size * 0.56)), Image.LANCZOS)
    canvas.alpha_composite(logo, ((size - logo.width) // 2, (size - logo.height) // 2))
    return canvas


def main():
    icon = Image.open(SRC).convert("RGBA")

    for density, (legacy_size, adaptive_size) in DENSITIES.items():
        out_dir = os.path.join(RES, "mipmap-" + density)
        os.makedirs(out_dir, exist_ok=True)
        make_legacy(icon, legacy_size).save(
            os.path.join(out_dir, "ic_launcher.png")
        )
        make_foreground(icon, adaptive_size).save(
            os.path.join(out_dir, "ic_launcher_foreground.png")
        )
        print("ikon", density, "legacy", legacy_size, "adaptive", adaptive_size)

    splash_dir = os.path.join(RES, "drawable-nodpi")
    os.makedirs(splash_dir, exist_ok=True)
    splash = icon.resize((288, 288), Image.LANCZOS)
    splash.save(os.path.join(splash_dir, "splash_logo.png"))
    print("splash logo 288x288")


if __name__ == "__main__":
    main()
