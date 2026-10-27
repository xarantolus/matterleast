#!/usr/bin/env python3
"""Writes the invented PDFs the PDF viewer is tested with.

test/fixtures/pdf/guide.pdf  six pages of text, a web link, a link to a
                             page and an outline
test/fixtures/pdf/locked.pdf one page behind the password "kingfisher"
                             (RC4, 40 bit: the simplest handler PDFium opens)

Standard library only. Run from the repository root:
    python3 tool/make-test-pdfs.py
"""

import hashlib
import os

PAD = bytes.fromhex(
    "28bf4e5e4e758a4164004e56fffa01082e2e00b6d0683e802f0ca9fe6453697a"
)
FILE_ID = hashlib.md5(b"matterleast test pdf").digest()


def rc4(key, data):
    s = list(range(256))
    j = 0
    for i in range(256):
        j = (j + s[i] + key[i % len(key)]) % 256
        s[i], s[j] = s[j], s[i]
    out = bytearray()
    i = j = 0
    for byte in data:
        i = (i + 1) % 256
        j = (j + s[i]) % 256
        s[i], s[j] = s[j], s[i]
        out.append(byte ^ s[(s[i] + s[j]) % 256])
    return bytes(out)


class Security:
    """Standard security handler, revision 2."""

    permissions = -44

    def __init__(self, user, owner):
        padded_user = (user.encode() + PAD)[:32]
        padded_owner = (owner.encode() + PAD)[:32]
        self.owner_entry = rc4(hashlib.md5(padded_owner).digest()[:5], padded_user)
        p = self.permissions.to_bytes(4, "little", signed=True)
        self.key = hashlib.md5(padded_user + self.owner_entry + p + FILE_ID).digest()[:5]
        self.user_entry = rc4(self.key, PAD)

    def encrypt(self, number, data):
        object_key = hashlib.md5(
            self.key + number.to_bytes(3, "little") + (0).to_bytes(2, "little")
        ).digest()[: len(self.key) + 5]
        return rc4(object_key, data)


class Pdf:
    def __init__(self, security=None):
        self.objects = []
        self.security = security

    def reserve(self):
        self.objects.append(None)
        return len(self.objects)

    def set(self, number, body):
        self.objects[number - 1] = body

    def add(self, body):
        number = self.reserve()
        self.set(number, body)
        return number

    def text(self, number, value):
        """A string inside object [number], encrypted when the file is."""
        data = value.encode("latin-1")
        if self.security:
            data = self.security.encrypt(number, data)
        return "<" + data.hex() + ">"

    def stream(self, number, data):
        if self.security:
            data = self.security.encrypt(number, data)
        return b"<< /Length %d >>\nstream\n" % len(data) + data + b"\nendstream"

    def write(self, path, root):
        out = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
        offsets = []
        encrypt = None
        if self.security:
            encrypt = self.add(
                "<< /Filter /Standard /V 1 /R 2 /Length 40 /P %d /O <%s> /U <%s> >>"
                % (
                    self.security.permissions,
                    self.security.owner_entry.hex(),
                    self.security.user_entry.hex(),
                )
            )
        for number, body in enumerate(self.objects, 1):
            offsets.append(len(out))
            if isinstance(body, str):
                body = body.encode("latin-1")
            out += b"%d 0 obj\n" % number + body + b"\nendobj\n"
        xref = len(out)
        out += b"xref\n0 %d\n0000000000 65535 f \n" % (len(self.objects) + 1)
        for offset in offsets:
            out += b"%010d 00000 n \n" % offset
        trailer = "<< /Size %d /Root %d 0 R /ID [<%s> <%s>]" % (
            len(self.objects) + 1,
            root,
            FILE_ID.hex(),
            FILE_ID.hex(),
        )
        if encrypt:
            trailer += " /Encrypt %d 0 R" % encrypt
        out += b"trailer\n" + trailer.encode() + b" >>\nstartxref\n%d\n%%%%EOF\n" % xref
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "wb") as f:
            f.write(out)


def escape(line):
    return line.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def page_content(heading, lines):
    ops = ["BT /F1 22 Tf 72 740 Td (%s) Tj ET" % escape(heading)]
    y = 700
    for line in lines:
        ops.append("BT /F1 12 Tf 72 %d Td (%s) Tj ET" % (y, escape(line)))
        y -= 20
    return ("\n".join(ops)).encode("latin-1")


def line_rect(index):
    """The box around body line [index], for a link over it."""
    y = 700 - 20 * index
    return "[70 %d 400 %d]" % (y - 4, y + 14)


def document(path, pages, outline=False, security=None):
    """[pages] is a list of (heading, lines, links); a link is
    (line index, "https://..." or a page index)."""
    pdf = Pdf(security)
    catalog = pdf.reserve()
    tree = pdf.reserve()
    font = pdf.add(
        "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica "
        "/Encoding /WinAnsiEncoding >>"
    )
    page_numbers = [pdf.reserve() for _ in pages]
    for number, (heading, lines, links) in zip(page_numbers, pages):
        content = pdf.reserve()
        pdf.set(content, pdf.stream(content, page_content(heading, lines)))
        annots = []
        for index, target in links:
            annot = pdf.reserve()
            if isinstance(target, str):
                action = "/A << /S /URI /URI %s >>" % pdf.text(annot, target)
            else:
                action = "/Dest [%d 0 R /XYZ 0 792 0]" % page_numbers[target]
            pdf.set(
                annot,
                "<< /Type /Annot /Subtype /Link /Rect %s /Border [0 0 0] %s >>"
                % (line_rect(index), action),
            )
            annots.append("%d 0 R" % annot)
        pdf.set(
            number,
            "<< /Type /Page /Parent %d 0 R /MediaBox [0 0 612 792] "
            "/Resources << /Font << /F1 %d 0 R >> >> /Contents %d 0 R "
            "/Annots [%s] >>" % (tree, font, content, " ".join(annots)),
        )
    pdf.set(
        tree,
        "<< /Type /Pages /Kids [%s] /Count %d >>"
        % (" ".join("%d 0 R" % n for n in page_numbers), len(pages)),
    )
    extra = ""
    if outline:
        root = pdf.reserve()
        items = [pdf.reserve() for _ in pages]
        for i, (item, page) in enumerate(zip(items, page_numbers)):
            links = ["/Parent %d 0 R" % root]
            if i > 0:
                links.append("/Prev %d 0 R" % items[i - 1])
            if i + 1 < len(items):
                links.append("/Next %d 0 R" % items[i + 1])
            pdf.set(
                item,
                "<< /Title %s %s /Dest [%d 0 R /Fit] >>"
                % (pdf.text(item, pages[i][0]), " ".join(links), page),
            )
        pdf.set(
            root,
            "<< /Type /Outlines /First %d 0 R /Last %d 0 R /Count %d >>"
            % (items[0], items[-1], len(items)),
        )
        extra = " /Outlines %d 0 R /PageMode /UseOutlines" % root
    pdf.set(catalog, "<< /Type /Catalog /Pages %d 0 R%s >>" % (tree, extra))
    pdf.write(path, catalog)


GUIDE = [
    (
        "A field guide to invented birds",
        [
            "Every bird in this guide was made up for testing.",
            "See the herons on page 3.",
            "More about made-up birds: https://example.org/birds",
            "Each chapter has a picture-free description and a call.",
        ],
        [(1, 2), (2, "https://example.org/birds")],
    ),
    (
        "Marsh wrens",
        [
            "Small, brown and loud, the marsh wren sings at night.",
            "It builds three nests and lives in one of them.",
        ],
        [],
    ),
    (
        "Herons",
        [
            "The grey heron waits by the reed bed for hours.",
            "Every heron here is invented, down to its long neck.",
            "Back to the first page.",
        ],
        [(2, 0)],
    ),
    (
        "Owls",
        ["The paper owl hoots twice before rain.", "It never blinks."],
        [],
    ),
    (
        "Swifts",
        ["The ribbon swift sleeps while it flies.", "It lands once a year."],
        [],
    ),
    (
        "Index",
        ["Marsh wrens, 2", "Owls, 4", "Swifts, 5"],
        [],
    ),
]

LOCKED = [
    (
        "Locked notes",
        [
            "This page was behind a password.",
            "The password is not written anywhere in it.",
        ],
        [],
    )
]

if __name__ == "__main__":
    document("test/fixtures/pdf/guide.pdf", GUIDE, outline=True)
    document(
        "test/fixtures/pdf/locked.pdf",
        LOCKED,
        security=Security(user="kingfisher", owner="owner of the notes"),
    )
