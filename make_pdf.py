# -*- coding: utf-8 -*-
"""Generate beautiful Vietnamese PDF from analysis using fpdf2 + Arial."""
from fpdf import FPDF

OUT = r"E:\PharmAppDev\PharmPortable\opencode_launcher\phan-tich-model-dev-code-best.pdf"
FONT = r"C:\Windows\Fonts\arial.ttf"
FONTB = r"C:\Windows\Fonts\arialbd.ttf"

class PDF(FPDF):
    def header(self):
        if self.page_no() == 1:
            return
        self.set_font("ArialVN", "B", 8)
        self.set_text_color(120, 130, 150)
        self.cell(0, 8, "OpenCode Free Models  |  Model Free nao dev code tot nhat? (2026-10-03)", align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(43, 55, 82)
        self.line(self.l_margin, self.get_y(), self.w - self.r_margin, self.get_y())
        self.ln(3)

    def footer(self):
        self.set_y(-15)
        self.set_font("ArialVN", "", 8)
        self.set_text_color(130, 140, 160)
        self.cell(0, 10, f"Trang {self.page_no()}/{{nb}}  |  MD + HTML + PDF cung noi dung", align="C")

pdf = PDF(orientation="P", unit="mm", format="A4")
pdf.alias_nb_pages("{nb}")
pdf.set_auto_page_break(True, margin=18)
pdf.set_margins(16, 14, 16)
pdf.add_font("ArialVN", "", FONT)
pdf.add_font("ArialVN", "B", FONTB)
pdf.add_page()

def title(t, size=20):
    pdf.set_font("ArialVN", "B", size)
    pdf.set_text_color(20, 30, 60)
    pdf.multi_cell(0, 8, t)
    pdf.ln(1)

def subtitle(t):
    pdf.set_font("ArialVN", "", 10)
    pdf.set_text_color(90, 100, 120)
    pdf.multi_cell(0, 5.5, t)
    pdf.ln(2)

def h2(t):
    pdf.ln(3)
    pdf.set_fill_color(28, 42, 82)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font("ArialVN", "B", 13)
    pdf.multi_cell(0, 8, "  " + t, fill=True)
    pdf.ln(2)

def h3(t):
    pdf.set_font("ArialVN", "B", 11)
    pdf.set_text_color(23, 61, 58)
    pdf.multi_cell(0, 6.5, t)
    pdf.ln(1)

def body(t):
    pdf.set_x(pdf.l_margin)
    pdf.set_font("ArialVN", "", 10)
    pdf.set_text_color(30, 35, 50)
    pdf.multi_cell(0, 5.8, t)
    pdf.ln(1)

def bullet(t):
    pdf.set_x(pdf.l_margin)
    pdf.set_font("ArialVN", "", 10)
    pdf.set_text_color(30, 35, 50)
    pdf.multi_cell(0, 5.8, " - " + t)

def code_block(t):
    pdf.set_x(pdf.l_margin)
    pdf.set_fill_color(11, 15, 26)
    pdf.set_text_color(215, 227, 255)
    pdf.set_font("Courier", "", 8.5)
    # fpdf core Courier lacks Vietnamese; transliterate critical lines to ASCII-safe
    safe = t.replace("\u2514", "+").replace("\u2500", "-").replace("\u2717", "X")
    pdf.multi_cell(0, 5.2, safe, fill=True)
    pdf.ln(2)
    pdf.set_font("ArialVN", "", 10)

def table(rows, widths, header=True):
    pdf.set_x(pdf.l_margin)
    pdf.set_font("ArialVN", "B" if header else "", 8.5)
    # header row
    pdf.set_fill_color(28, 42, 82)
    pdf.set_text_color(255, 255, 255)
    for i, c in enumerate(rows[0]):
        last = (i == len(rows[0]) - 1)
        pdf.cell(widths[i], 7, c, border=1, fill=True,
                 new_x="LMARGIN" if last else "RIGHT",
                 new_y="NEXT" if last else "TOP")
    pdf.ln(0)
    pdf.set_font("ArialVN", "", 8.5)
    pdf.set_text_color(25, 30, 45)
    fill = False
    for r in rows[1:]:
        if pdf.get_y() > 265:
            pdf.add_page()
        max_lines = 1
        # simple row
        h = 7 if sum(len(x) for x in r) < 120 else 12
        x0 = pdf.get_x(); y0 = pdf.get_y()
        for i, c in enumerate(r):
            pdf.set_fill_color(240, 244, 255) if fill else pdf.set_fill_color(255, 255, 255)
            last = (i == len(r) - 1)
            pdf.cell(widths[i], h, c[:60], border=1, fill=True,
                     new_x="LMARGIN" if last else "RIGHT",
                     new_y="NEXT" if last else "TOP")
        fill = not fill
    pdf.ln(2)

# ---------- CONTENT ----------
title("Model Free nao dev code tot nhat hien nay?")
subtitle("Phan tich 14 ID opencode/*-free  |  Ngay: 2026-10-03 (UTC)\nBench: SWE-bench Verified / SWE-bench Pro (Scale) / Terminal-Bench 2.x / LiveCodeBench\nDocs: opencode.ai/docs/zen  +  zen/v1/models")

h2("Ket luan nhanh (TL;DR)")
table([
    ["Rank", "Model", "Chot"],
    ["#1", "muse-spark-1.3", "Manh nhat: code kho, multi-file, agent dai"],
    ["#2", "deepseek-v4-flash-free", "Manh + on dinh nhat nhom open-weight"],
    ["#3", "big-pickle (~GLM-4.6)", "Daily-driver free ngon nhat; KHONG dung code private"],
    ["Loai", "jev-1.13-free", "KHONG phai model code (noul/choice/score)"],
], [18, 62, 98])

h2("1. Giai ma 14 ID free")
table([
    ["Model ID", "Ban chat", "Ctx", "Privacy"],
    ["muse-spark-1.3", "Meta Muse Spark 1.3, proprietary", "1M/131K", "Free co thoi han"],
    ["muse-spark-1.2", "Meta Muse Spark 1.2", "1M", "Free co thoi han"],
    ["big-pickle", "Stealth ~GLM-4.6, ~Sonnet-class", "200K/32K", "Dung data train"],
    ["deepseek-v4-flash", "DeepSeek V4 Flash, open", "1M", "Free co thoi han"],
    ["mimo-v2.6-flash", "Xiaomi MiMo V2.6, tool-call 97%", "1M", "Free co thoi han"],
    ["mimo-v2.5", "Xiaomi MiMo V2.5", "1M", "Free co thoi han"],
    ["longcat-2.5-prev", "Meituan LongCat 2.5, 1.6T/48B", "1M", "Zero-retention"],
    ["space-bunny", "Stealth 1M multimodal", "1M", "Zero-retention"],
    ["ling-3.0-fin", "InclusionAI Ling 3.0, 124B/5.1B", "262K", "Free co thoi han"],
    ["ling-3.1", "Ling 3.1 (moi hon 3.0)", "262K", "Free co thoi han"],
    ["nemotron-3-ultra", "NVIDIA 550B/A55B", "262K", "Trial, bi log"],
    ["nemotron-3.5-light", "NVIDIA 30B, Mamba-2+MoE", "262K-1M", "Trial, bi log"],
    ["jev-1.13-free", "KHONG sinh code", "--", "Free"],
    ["fledge-alpha", "Khong con trong docs Zen", "?", "Tranh"],
], [42, 62, 28, 46])

h2("2. Benchmark - ai thuc su manh?")
body("SWE-bench Verified da bao hoa (top quanh 80%, cach nhau ~0.6%). Muon phan biet phai nhin SWE-bench Pro + Terminal-Bench 2.1.")
table([
    ["Model", "SWE-Pro (Scale)", "Terminal", "Verified"],
    ["Muse Spark 1.1", "61.5% #1 (priv 51.5% #1)", "80.0% (2.1)", "--"],
    ["Muse Spark 1.2", "Ke thua 1.1", "82.9% (2.1)", "Vals 86.6%"],
    ["DeepSeek Flash", "--", "56.9% (2.0)", "79.0%"],
    ["MiMo V2 Thinking", "--", "--", "78.6% (Pro 78.0%)"],
    ["LongCat 2.0", "59.5% (#13)", "70.8% (2.1)", "68.2% (Lite)"],
    ["Nemotron Ultra", "--", "--", "71.9%"],
    ["Lightning 30B", "--", "23.5% (2.1)", "52.8%"],
    ["Ling 3.0", "Manh Pro/Multi (OpenHands)", "--", "SciCode 40.4%"],
], [42, 52, 40, 44])
body("Tham chieu: GPT-5.4 xHigh 59.1% Pro, Opus 4.6 thinking 51.9% Pro, Gemini 3.1 Pro 46.1% Pro. Muse Spark 1.1 hon 2.4-9.6 diem o bench kho.")

h3("Nhan xet tung model")
bullet("Muse Spark: duy nhat trong list free dung top ca 2 bench kho nhat cho agent dai hoi, multi-file.")
bullet("DeepSeek Flash: open-weight, 1M context, re, on dinh. Manh nhat nhom open trong list.")
bullet("MiMo: tool-call 97%, 150 tok/s - hop agent loop OpenCode, it gay giua chung.")
bullet("LongCat 2.5: yeu hon Muse nhung hon Nemotron/Ling; zero-retention -> so 1 cho code private free.")
bullet("Nemotron Ultra: dung duoc reasoning nang; Lightning chi dung khi can toc do.")
bullet("Ling: manh instruction-following, tiet kiem token (5.1B active), khong phai top code thuan.")
bullet("Big Pickle: compile rate cao, refactor tot; gioi han 200K/32K out, thua nhom 1M o whole-repo.")

h2("3. Xep hang cuoi")
bullet("Tier S (viec kho, agent dai): muse-spark-1.3 > muse-spark-1.2")
bullet("Tier A (daily free): deepseek-v4-flash > mimo-v2.6 > mimo-v2.5 > big-pickle > longcat-2.5")
bullet("Tier B (tuy case): nemotron-3-ultra; ling-3.1 >= 3.0; space-bunny (thu vi zero-retention)")
bullet("Tier C (khong dung code chinh): lightning (speed only); fledge (tranh); jev (loai)")

h2("4. Workflow khuyen nghi (copy tu file HTML)")
code_block("[1] Task kho / repo lon / agent dai:\n    muse-spark-1.3-contributor-free\n    +-- fail -> muse-spark-1.2-contributor-free\n[2] Feature/fix hang ngay (KHONG private):\n    big-pickle truoc\n    +-- fail 2 lan -> deepseek-v4-flash-free\n    +-- gay tool-call -> mimo-v2.6-flash-free\n[3] Repo private / zero-retention:\n    longcat-2.5-preview-free hoac space-bunny-free\n    X KHONG: big-pickle / nemotron-free / muse-spark-free\n[4] Edit nho, can toc do: ling-3.1 / nemotron-3.5-lightning")
code_block('{\n  "model": "opencode/muse-spark-1.3-contributor-free"\n}\n// daily: opencode/big-pickle\n// private: opencode/longcat-2.5-preview-free')

h2("5. 3 luu y free lane")
bullet("(1) Stealth (big-pickle/space-bunny/fledge) co the bi swap ngam - thay behavior doi thi doi lane.")
bullet("(2) Big Pickle chi 200K/32K out vs nhom 1M - job whole-repo bat buoc dung nhom 1M, chunk output.")
bullet("(3) Quy tac 2-fail-escalate: fail 2 lan co feedback thi len paid frontier, dung grind free.")

h2("6. Nguon")
body("opencode.ai/docs/zen; zen/v1/models; Steel.dev SWE Verified 09/2026; BenchLM; Scale/Morph SWE-Pro (Muse 1.1 61.5% #1); Xiaomi MiMo notes; Meituan LongCat-2.0 README; InclusionAI Ling HF; AIBenchy; OpenCode Data.\nLuu y: ID stealth khong co benchmark official; danh gia dua tren docs Zen + consensus + ho model lien quan. Nen smoke-test tren repo cua ban.")

pdf.output(OUT)
print("PDF OK:", OUT)
