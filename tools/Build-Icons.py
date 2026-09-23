"""Build every Bagception icon file from the source art in art/icons/.

Run from the repository root:  python tools/Build-Icons.py
Requires Pillow, and texconv installed by tools/Install-Texconv.ps1.

The PNGs in art/icons/ are the source; everything this script writes is generated
and is rebuilt from them on every run. docs/containers.md, "Art specification",
describes the art and lists the generated files.

Written each run:
  - the inventory icon sheet (one 64 x 64 cell per bag) and its UV index;
  - the TextureBank entry that registers the sheet with the game;
  - the tooltip (380, 192) and controller (144, 72) icons, which the game looks up
    by icon name under Public/Game;
  - the Icon attribute on each bag's root template.
"""

import glob
import io
import os
import re
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageFilter, ImageStat

MODULE = "Bagception"
ART_DIR = "art/icons"
ROOT_TEMPLATES = "src/Public/Bagception/RootTemplates/_merged.lsx"

# The sheet's resource UUID. Fixed, not generated per run: the GUI index names it, and
# a new one each build would churn both files for nothing.
ATLAS_UUID = "eca91c1b-1fa3-4d74-a69a-2445b7abb704"
ATLAS_NAME = "Bagception_Icons"
ATLAS_PATH = "Assets/Textures/Icons/%s.dds" % ATLAS_NAME
ATLAS_FILE = "src/Public/%s/%s" % (MODULE, ATLAS_PATH)
ATLAS_INDEX = "src/Public/%s/GUI/%s.lsx" % (MODULE, ATLAS_NAME)
TEXTURE_BANK = "src/Public/%s/Content/UI/[PAK]_UI/_merged.lsx" % MODULE

CELL = 64
ATLAS_COLUMNS = 8
ATLAS_SIZE = (512, 256)

# Folder, size and block format all match vanilla's, checked against Game.pak: tooltip
# icons are DXT5 with the legacy header, controller icons BC7.
DXT5 = ["-f", "BC3_UNORM", "-dx9"]
BC7 = ["-f", "BC7_UNORM"]
LOOSE_ICONS = [
    ("src/Public/Game/GUI/Assets/Tooltips/ItemIcons", 380, DXT5),
    ("src/Public/Game/GUI/AssetsLowRes/Tooltips/ItemIcons", 192, DXT5),
    ("src/Public/Game/GUI/Assets/ControllerUIIcons/items_png", 144, BC7),
    ("src/Public/Game/GUI/AssetsLowRes/ControllerUIIcons/items_png", 72, BC7),
]
TEXCONV_GLOB = "tools/external/texconv-*/texconv.exe"

# Art file name -> root template Name. Two templates kept their earlier names when the
# bags were renamed in game, so the mapping is explicit rather than derived.
BAGS = [
    ("Bagception", "BAGCEPTION_CONT_Master"),
    ("WeaponRoll", "BAGCEPTION_CONT_WeaponRoll"),
    ("ShieldRack", "BAGCEPTION_CONT_ShieldRack"),
    ("ArmourTrunk", "BAGCEPTION_CONT_ArmourTrunk"),
    ("JewelryBox", "BAGCEPTION_CONT_JewelBox"),
    ("Quiver", "BAGCEPTION_CONT_Quiver"),
    ("ScrollCase", "BAGCEPTION_CONT_ScrollCase"),
    ("PotionCase", "BAGCEPTION_CONT_PotionCase"),
    ("ElixirRack", "BAGCEPTION_CONT_ElixirRack"),
    ("CoatingKit", "BAGCEPTION_CONT_CoatingKit"),
    ("GrenadeSatchel", "BAGCEPTION_CONT_GrenadeSatchel"),
    ("ReagentPouch", "BAGCEPTION_CONT_ReagentPouch"),
    ("LarderPack", "BAGCEPTION_CONT_LarderSack"),
    ("BookSatchel", "BAGCEPTION_CONT_BookSatchel"),
    ("KeyRing", "BAGCEPTION_CONT_KeyRing"),
    ("ToolRoll", "BAGCEPTION_CONT_ToolRoll"),
    ("DyePouch", "BAGCEPTION_CONT_DyePouch"),
    ("OddsSack", "BAGCEPTION_CONT_OddsSack"),
]


def icon_name(art):
    return "%s_%s" % (MODULE, art)


def fail(message):
    sys.exit("Build-Icons: " + message)


def load_art(art):
    path = os.path.join(ART_DIR, art + ".png")
    if not os.path.isfile(path):
        fail("missing %s. Every bag needs its PNG, named exactly as in docs/containers.md." % path)
    image = Image.open(path)
    if image.width != image.height:
        fail("%s is %d x %d; it must be square." % (path, image.width, image.height))
    if image.width < 512:
        fail("%s is %d pixels wide; the minimum is 512." % (path, image.width))
    if "A" not in image.getbands():
        fail("%s has no alpha channel. Remove its background first." % path)
    return image.convert("RGBA")


def bleed(image):
    """Fill the colour of fully transparent pixels from the nearest object colour.

    Their colour is never seen directly, but texture filtering blends it into the
    silhouette's soft edge. Left black, as a premultiplied resize leaves it, every icon
    gets a dark fringe; filled from the object, the edge fades out in its own colour.
    """
    alpha = image.getchannel("A")
    solid = alpha.point(lambda v: 255 if v else 0)
    mean = tuple(int(c) for c in ImageStat.Stat(image.convert("RGB"), solid).mean)
    fill = Image.new("RGB", image.size, mean)
    premultiplied = image.convert("RGBa")
    for radius in (32, 8, 2):
        blurred = premultiplied.filter(ImageFilter.GaussianBlur(radius)).convert("RGBA")
        # Only where the blur carries real weight. At an alpha of 1 or 2, dividing the
        # colour back out amplifies rounding into pure magenta or green, and DXT5 shares
        # each 4 x 4 block's colours, so a stray one tints the visible edge beside it.
        reached = blurred.getchannel("A").point(lambda v: 255 if v >= 24 else 0)
        fill = Image.composite(blurred.convert("RGB"), fill, reached)
    result = Image.composite(image.convert("RGB"), fill, solid)
    result.putalpha(alpha)
    return result


def scaled(image, size):
    # Resize premultiplied, so transparent pixels' colour does not bleed inward.
    small = image.convert("RGBa").resize((size, size), Image.LANCZOS).convert("RGBA")
    return bleed(small)


def find_texconv():
    found = sorted(glob.glob(TEXCONV_GLOB))
    if not found:
        fail("texconv not found. Run .\\tools\\Install-Texconv.ps1 first.")
    return found[-1]


def write_dds(jobs):
    """Block-compress each (image, path, format) job with texconv.

    Images are staged as PNG, compressed a format at a time, and moved into place.
    Moving rather than writing in place keeps each generated name's exact case.
    """
    texconv = find_texconv()
    with tempfile.TemporaryDirectory() as stage:
        for group, fmt in enumerate(sorted({tuple(f) for _, _, f in jobs})):
            folder = os.path.join(stage, str(group))
            os.makedirs(folder)
            batch = [(image, path) for image, path, f in jobs if tuple(f) == fmt]
            sources = []
            for number, (image, _) in enumerate(batch):
                source = os.path.join(folder, "%d.png" % number)
                image.save(source)
                sources.append(source)
            result = subprocess.run(
                [texconv, *fmt, "-m", "1", "-y", "-nologo", "-o", folder, *sources],
                capture_output=True,
                text=True,
            )
            if result.returncode:
                fail("texconv failed:\n" + result.stdout + result.stderr)
            for number, (_, path) in enumerate(batch):
                os.makedirs(os.path.dirname(path), exist_ok=True)
                if os.path.exists(path):
                    os.remove(path)
                shutil.move(os.path.join(folder, "%d.dds" % number), path)


def write_text(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with io.open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


def uv(value):
    return ("%.8f" % value).rstrip("0").rstrip(".")


def atlas_index(cells):
    width, height = ATLAS_SIZE
    entries = []
    for art, (x, y) in cells:
        # Inset half a texel on every side, as vanilla does, so filtering never samples
        # the neighbouring cell.
        entries.append(
            '                <node id="IconUV">\n'
            '                    <attribute id="MapKey" type="FixedString" value="%s"/>\n'
            '                    <attribute id="U1" type="float" value="%s"/>\n'
            '                    <attribute id="U2" type="float" value="%s"/>\n'
            '                    <attribute id="V1" type="float" value="%s"/>\n'
            '                    <attribute id="V2" type="float" value="%s"/>\n'
            '                </node>\n'
            % (
                icon_name(art),
                uv((x + 0.5) / width),
                uv((x + CELL - 0.5) / width),
                uv((y + 0.5) / height),
                uv((y + CELL - 0.5) / height),
            )
        )
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        "<!-- Generated by tools/Build-Icons.py from art/icons/. Do not edit. -->\n"
        "<save>\n"
        '    <version major="4" minor="3" revision="0" build="0"/>\n'
        '    <region id="IconUVList">\n'
        '        <node id="root">\n'
        "            <children>\n"
        "%s"
        "            </children>\n"
        "        </node>\n"
        "    </region>\n"
        '    <region id="TextureAtlasInfo">\n'
        '        <node id="root">\n'
        "            <children>\n"
        '                <node id="TextureAtlasIconSize">\n'
        '                    <attribute id="Height" type="int32" value="%d"/>\n'
        '                    <attribute id="Width" type="int32" value="%d"/>\n'
        "                </node>\n"
        '                <node id="TextureAtlasPath">\n'
        '                    <attribute id="Path" type="string" value="%s"/>\n'
        '                    <attribute id="UUID" type="FixedString" value="%s"/>\n'
        "                </node>\n"
        '                <node id="TextureAtlasTextureSize">\n'
        '                    <attribute id="Height" type="int32" value="%d"/>\n'
        '                    <attribute id="Width" type="int32" value="%d"/>\n'
        "                </node>\n"
        "            </children>\n"
        "        </node>\n"
        "    </region>\n"
        "</save>\n"
        % ("".join(entries), CELL, CELL, ATLAS_PATH, ATLAS_UUID, height, width)
    )


def texture_bank():
    # The same fields as vanilla's own entry for its item icon sheet.
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<!-- Generated by tools/Build-Icons.py. Do not edit. -->\n"
        "<save>\n"
        '\t<version major="4" minor="0" revision="9" build="0" />\n'
        '\t<region id="TextureBank">\n'
        '\t\t<node id="TextureBank">\n'
        "\t\t\t<children>\n"
        '\t\t\t\t<node id="Resource">\n'
        '\t\t\t\t\t<attribute id="ID" type="FixedString" value="%s" />\n'
        '\t\t\t\t\t<attribute id="Localized" type="bool" value="False" />\n'
        '\t\t\t\t\t<attribute id="Name" type="LSString" value="%s" />\n'
        '\t\t\t\t\t<attribute id="SRGB" type="bool" value="True" />\n'
        '\t\t\t\t\t<attribute id="SourceFile" type="LSString" value="Public/%s/%s" />\n'
        '\t\t\t\t\t<attribute id="Streaming" type="bool" value="True" />\n'
        '\t\t\t\t\t<attribute id="Template" type="FixedString" value="%s" />\n'
        '\t\t\t\t\t<attribute id="Type" type="int32" value="0" />\n'
        '\t\t\t\t\t<attribute id="_OriginalFileVersion_" type="int64" value="144115188075855873" />\n'
        "\t\t\t\t</node>\n"
        "\t\t\t</children>\n"
        "\t\t</node>\n"
        "\t</region>\n"
        "</save>\n"
        % (ATLAS_UUID, ATLAS_NAME, MODULE, ATLAS_PATH, ATLAS_NAME)
    )


def set_template_icons(text):
    """Give each bag's root template an Icon attribute, replacing any earlier one.

    Edited as text rather than through an XML library so the file's formatting,
    comments and entity escaping are left exactly as they are.
    """
    for art, template in BAGS:
        name_line = '<attribute id="Name" type="LSString" value="%s" />' % template
        name_at = text.find(name_line)
        if name_at < 0 or text.find(name_line, name_at + 1) >= 0:
            fail("expected exactly one root template named %s." % template)
        start = text.rfind('<node id="GameObjects">', 0, name_at)
        block = text[start:name_at]
        block = re.sub(r'\r?\n\t*<attribute id="Icon" type="FixedString" value="[^"]*" />', "", block)
        # Attributes are kept in alphabetical order; Icon sorts just before LevelName.
        # The new line takes the file's own line ending and indentation.
        anchor = re.search(r'(\r?\n)(\t*)<attribute id="LevelName"', block)
        if not anchor:
            fail("template %s has no LevelName attribute to place Icon before." % template)
        icon_line = '%s%s<attribute id="Icon" type="FixedString" value="%s" />' % (
            anchor.group(1),
            anchor.group(2),
            icon_name(art),
        )
        block = block[: anchor.start()] + icon_line + block[anchor.start():]
        text = text[:start] + block + text[name_at:]
    return text


def main():
    if not os.path.isdir(ART_DIR):
        fail("run from the repository root; %s not found." % ART_DIR)

    art = [(name, load_art(name)) for name, _ in BAGS]

    atlas = Image.new("RGBA", ATLAS_SIZE, (0, 0, 0, 0))
    cells = []
    jobs = []
    for index, (name, image) in enumerate(art):
        x = (index % ATLAS_COLUMNS) * CELL
        y = (index // ATLAS_COLUMNS) * CELL
        atlas.paste(scaled(image, CELL), (x, y))
        cells.append((name, (x, y)))
        for folder, size, fmt in LOOSE_ICONS:
            jobs.append((scaled(image, size), os.path.join(folder, icon_name(name) + ".DDS"), fmt))

    jobs.append((atlas, ATLAS_FILE, DXT5))
    write_dds(jobs)
    write_text(ATLAS_INDEX, atlas_index(cells))
    write_text(TEXTURE_BANK, texture_bank())

    with io.open(ROOT_TEMPLATES, encoding="utf-8", newline="") as handle:
        templates = handle.read()
    updated = set_template_icons(templates)
    if updated != templates:
        with io.open(ROOT_TEMPLATES, "w", encoding="utf-8", newline="") as handle:
            handle.write(updated)

    print("Built %d icons: sheet %s, %d loose icons, %d template Icon attributes"
          % (len(art), ATLAS_FILE, len(art) * len(LOOSE_ICONS), len(BAGS)))


if __name__ == "__main__":
    main()
