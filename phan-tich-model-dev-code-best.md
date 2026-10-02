# Phân tích sâu: Model Free nào dev code tốt nhất hiện nay?

> **Ngày phân tích:** 2026-10-03 (UTC) | **Nguồn bench:** SWE-bench Verified, SWE-bench Pro (Scale standardized), Terminal-Bench 2.x, LiveCodeBench, BenchLM / llm-stats / Vals.ai | **Docs:** `https://opencode.ai/docs/zen`, `https://opencode.ai/zen/v1/models`
> **Scope:** 14 ID `opencode/*-free` trong `opencode_model.md`.

## Kết luận nhanh (TL;DR)

| Rank | Model | Điểm chốt |
|------|-------|------------|
| **#1** | `opencode/muse-spark-1.3-contributor-free` (Meta Muse Spark 1.3) | Mạnh nhất cho code khó, multi-file, agent dài hơi |
| **#2** | `opencode/deepseek-v4-flash-free` (DeepSeek V4 Flash) | Mạnh + ổn định nhất nhóm open-weight |
| **#3** | `opencode/big-pickle` (stealth ~ GLM-4.6) | Daily-driver free ngon nhất, **không dùng cho code private** |
| Loại | `opencode/jev-1.13-free` | **Không phải model code** — chỉ trả quyết định có cấu trúc |

```text
Task khó / repo lớn / agent dài  -> muse-spark-1.3 (fail -> muse-spark-1.2)
Feature / fix / refactor hàng ngày (không private) -> big-pickle trước,
  fail 2 lần -> deepseek-v4-flash-free hoặc mimo-v2.6-flash-free
Repo private / khách hàng / zero-retention -> longcat-2.5-preview-free
  hoặc space-bunny-free (TUYỆT ĐỐI KHÔNG dùng big-pickle / nemotron-free)
Edit nhỏ, cần tốc độ -> ling-3.1-flash / nemotron-3.5-lightning
```

---

## 1. Giải mã 14 ID free là gì?

| # | Model ID | Bản chất thật | Context / Output | Privacy (theo docs Zen) |
|---|----------|---------------|------------------|--------------------------|
| 1 | `opencode/muse-spark-1.3-contributor-free` | **Meta Muse Spark 1.3**, proprietary, đời mới nhất | 1M / 131K | Free có thời hạn, collect feedback |
| 5 | `opencode/muse-spark-1.2-contributor-free` | Meta Muse Spark 1.2, đời trước của 1.3 | 1M | Free có thời hạn, collect feedback |
| 2 | `opencode/big-pickle` | **Stealth, cộng đồng xác định ~ GLM-4.6 (Zhipu)**, ~Claude Sonnet 4.5/4.6-class | 200K / 32K | **Free + dùng data để train** |
| 4 | `opencode/deepseek-v4-flash-free` | **DeepSeek V4 Flash**, open-weight | 1M | Free có thời hạn, collect feedback |
| 6 | `opencode/mimo-v2.6-flash-free` | **Xiaomi MiMo V2.6 Flash**, 309B/15B active, tool-call 97% | 1M (pro) / 56K (flash) | Free có thời hạn |
| 9 | `opencode/mimo-v2.5-free` | Xiaomi MiMo V2.5, đời trước của 2.6 | 1M (pro) | Free có thời hạn |
| 8 | `opencode/longcat-2.5-preview-free` | **Meituan LongCat 2.5 Preview**, ~1.6T/48B active, multimodal | 1M | **Zero-retention, không dùng data train** |
| 7 | `opencode/space-bunny-free` | **Stealth, 1M, multimodal** (danh tính chưa lộ) | 1M | **Zero-retention** |
| 10 | `opencode/ling-3.0-flash-fin-free` | **InclusionAI Ling 3.0 Flash**, 124B/5.1B active, MoE hybrid-linear | 262K | Free có thời hạn |
| 14 | `opencode/ling-3.1-flash-free` | Ling 3.1, bản mới hơn của 3.0 | 262K | Free có thời hạn |
| 11 | `opencode/nemotron-3-ultra-free` | **NVIDIA Nemotron 3 Ultra 550B/A55B**, open-weight | 262K | **Trial only, bị log** |
| 12 | `opencode/nemotron-3.5-lightning-free` | **NVIDIA Nemotron 3.5 Lightning 30B/A3B**, hybrid Mamba-2 + MoE | 262K–1M | **Trial only, bị log** |
| 3 | `opencode/jev-1.13-free` | **Không phải LLM code.** Endpoint `zen/v1/systemone`, chỉ trả `noul / choice / score` | — | Free |
| 13 | `opencode/fledge-alpha-free` | Không còn trong docs Zen hiện tại, stealth đã thay thế/hạ | Không rõ | Tránh dùng việc quan trọng |

Chi tiết endpoint (từ docs Zen):

```bash
# Coding models (chat/completions hoặc responses) — dùng được cho dev code
# big-pickle, mimo-*, ling-*, nemotron-*, space-bunny-free, longcat-2.5-preview-free
curl https://opencode.ai/zen/v1/chat/completions \
  -H "Authorization: Bearer $OPENCODE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "deepseek-v4-flash-free", "messages": [{"role": "user", "content": "Fix bug..."}]}'

# Muse Spark 1.3 dùng responses endpoint
# model: muse-spark-1.3-contributor-free -> https://opencode.ai/zen/v1/responses

# Jev KHÔNG sinh code — chỉ trả quyết định có cấu trúc
curl https://opencode.ai/zen/v1/systemone \
  -H "Authorization: Bearer $OPENCODE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "jev-1.13", "state": "My payments have failed for three days..."}'
```

---

## 2. Benchmark code — ai thực sự mạnh?

> Lưu ý phương pháp: **SWE-bench Verified đã bão hòa** (top 8–15 chỉ cách nhau ~0.6%, quanh 80%). Muốn phân biệt phải nhìn **SWE-bench Pro + Terminal-Bench 2.1** — 2 bench khó cho agent thực tế.

### 2.1. Muse Spark — trùm SWE-Pro + Terminal

| Model | SWE-bench Pro (Scale standardized, Pass@1) | Terminal-Bench 2.1 | Khác |
|-------|---------------------------------------------|--------------------|------|
| Muse Spark 1.1 (Meta) | **61.5% ±3.1 — #1**, bản commercial private 51.5% (#1) | 80.0% | LiveCodeBench Vals 85.9% |
| Muse Spark 1.2 (Meta) | Kế thừa 1.1 | **82.9%** | SWE Vals 86.6%, DeepSWE 59.3% |
| Muse Spark 1.3 (Meta) | Chưa có số public độc lập, kỳ vọng ≥ 1.2 | — | Model card so với Opus 5 / GPT-5.6 Sol ở max reasoning |

Đối thủ để tham chiếu: GPT-5.4 xHigh 59.1% Pro, Opus 4.6 thinking 51.9% Pro, Gemini 3.1 Pro 46.1% Pro. Muse Spark 1.1 hơn 2.4–9.6 điểm — khoảng cách lớn ở bench khó.

**Đọc:** model duy nhất trong list free đứng top cả 2 bench khó nhất cho agent dài hơi, multi-file, multi-repo. Chọn cho task kiến trúc, migration, bug multi-file.

### 2.2. DeepSeek V4 Flash

| Benchmark | Điểm |
|-----------|------|
| SWE-bench Verified (Flash-Max) | **79.0%** (Pro-Max 80.6%) |
| BenchLM coding avg | **64.2** (vs Nemotron 58.3) |
| Terminal-Bench 2.0 | 56.9% |
| BrowseComp (agentic) | 73.2% |

**Đọc:** open-weight, 1M context, giá rẻ, ổn định. Mạnh nhất nhóm open-weight trong list.

### 2.3. MiMo (Xiaomi)

| Benchmark | Điểm |
|-----------|------|
| MiMo-V2-Flash Thinking, SWE Verified | **78.6%** (non-thinking 73.7%) |
| MiMo-V2-Pro, SWE Verified | 78.0% |
| Tool-call accuracy (Thinking) | **97.0%** (từ 64%) |
| Tốc độ V2-Flash | ~150 tok/s |

**Đọc:** rất hợp OpenCode agent loop vì tool-use ổn định, ít gãy giữa chừng.

### 2.4. LongCat (Meituan)

| Benchmark | Điểm |
|-----------|------|
| LongCat 2.0, Terminal-Bench 2.1 | **70.8%** (ngang Gemini 3.1 Pro 70.7) |
| LongCat 2.0, SWE-Pro | **59.5%** (rank 13/46) |
| Flash-Lite-Sparse, SWE Verified | 68.2% |
| 2.5 Preview | ~1.6T/48B active, 1M, multimodal, retool cho long-horizon agent |

**Đọc:** yếu hơn Muse Spark nhưng hơn Nemotron/Ling. Bù lại **zero-retention** — lựa chọn #1 cho code private trong nhóm free.

### 2.5. Nemotron (NVIDIA)

| Model | SWE Verified | Điểm khác |
|-------|--------------|------------|
| 3 Ultra 550B | **71.9%** | AIBenchy coding 8.4/10 (2/3 pass, attempt 88.9%) |
| 3.5 Lightning 30B | **52.8%** | SciCode 31.4%, Terminal 2.1 chỉ 23.5%, **nhanh ~4x, Pareto frontier model nhỏ** |

**Đọc:** Ultra dùng được cho reasoning nặng; Lightning chỉ dùng khi cần tốc độ cho edit lặt vặt.

### 2.6. Ling (InclusionAI)

| Benchmark | Ling 3.0 Flash |
|-----------|----------------|
| SciCode | **40.4%** (hơn Lightning 31.4%) |
| GPQA / GPQA-D | 84% |
| IFBench | 73.4% |
| Kiến trúc | 124B total / 5.1B active, hybrid-linear, thiên efficiency |

**Đọc:** mạnh instruction-following và tiết kiệm token, không phải top code thuần.

### 2.7. Big Pickle (stealth ~ GLM-4.6)

* Không có số official vì stealth. Cộng đồng đánh giá ~Sonnet 4.5/4.6-class. Tham chiếu cùng họ: GLM-5.2 đạt 62.1% SWE-Pro, band 80% Verified.
* Thực tế OpenCode: compile rate cao, refactor tốt.
* Giới hạn: **200K context / 32K max output** — thua xa nhóm 1M khi làm whole-repo.

---

## 3. Xếp hạng cuối cho dev code

### Tier S — việc khó, agent dài

1. `muse-spark-1.3-contributor-free`
2. `muse-spark-1.2-contributor-free`

### Tier A — daily free chất lượng cao

3. `deepseek-v4-flash-free`
4. `mimo-v2.6-flash-free` > `mimo-v2.5-free`
5. `big-pickle`
6. `longcat-2.5-preview-free`

### Tier B — tùy case

7. `nemotron-3-ultra-free` — code enterprise, reasoning nặng, chấp nhận bị log
8. `ling-3.1-flash-free` ≥ `ling-3.0-flash-fin-free` — task vừa, cần rẻ/nhanh
9. `space-bunny-free` — chưa có benchmark, đáng thử vì zero-retention + 1M

### Tier C — không dùng để code chính

10. `nemotron-3.5-lightning-free` — chỉ sửa lặt vặt, cần tốc độ
11. `fledge-alpha-free` — không rõ nguồn, tránh
12. `jev-1.13-free` — loại hẳn (không sinh code)

---

## 4. Workflow khuyến nghị (copy được)

```text
[1] Task khó / repo lớn / agent chạy dài:
    muse-spark-1.3-contributor-free
    └─ fail → muse-spark-1.2-contributor-free

[2] Feature / fix / refactor hàng ngày (KHÔNG private):
    big-pickle trước (free, nhanh)
    └─ fail 2 lần có feedback → deepseek-v4-flash-free
    └─ agent gãy tool-call → mimo-v2.6-flash-free

[3] Repo private / khách hàng / zero-retention bắt buộc:
    longcat-2.5-preview-free hoặc space-bunny-free
    ✗ TUYỆT ĐỐI KHÔNG: big-pickle / nemotron-free / muse-spark-free

[4] Edit nhỏ, cần tốc độ, có test bắt lỗi:
    ling-3.1-flash-free / nemotron-3.5-lightning-free
```

```bash
# Ví dụ cấu hình OpenCode — đổi model nhanh
# File: opencode.json (minh họa, copy và sửa model theo nhu cầu)
{
  "model": "opencode/muse-spark-1.3-contributor-free"
}
# Task khó xong, về daily để tiết kiệm quota:
# "model": "opencode/big-pickle"
# Task private:
# "model": "opencode/longcat-2.5-preview-free"
```

---

## 5. 3 lưu ý khi dùng free lane

1. **Free = có thể bị swap model ngầm**, nhất là `big-pickle`, `space-bunny-free`, `fledge-alpha-free`. Thấy behavior đổi đột ngột (verbosity, tool-call format, chất lượng) thì đổi lane ngay.
2. **Context chênh lệch lớn:** Big Pickle 200K/32K out vs nhóm 1M (Muse/DeepSeek/MiMo/LongCat/Space Bunny). Job whole-repo bắt buộc dùng nhóm 1M, chunk output nhỏ nếu dùng Big Pickle.
3. **Quy tắc 2-fail-escalate:** 2 lần fail có feedback mà vẫn dùng free để grind là đốt thời gian. Escalate lên paid frontier (GLM-5.2, MiniMax M3, Claude/GPT).

---

## 6. Nguồn tham chiếu chính

* OpenCode Zen docs — `https://opencode.ai/docs/zen` (pricing, endpoint, privacy free lane)
* OpenCode models endpoint — `https://opencode.ai/zen/v1/models`
* Steel.dev SWE-bench Verified leaderboard (09/2026): DeepSeek-V4-Pro-Max 80.6%, Flash-Max 79.0%, MiMo-V2-Pro 78.0%
* BenchLM SWE-bench Verified: Nemotron 3 Ultra 71.9%
* Morph / Scale AI SWE-bench Pro standardized (09/2026): Muse Spark 1.1 61.5% (#1), GPT-5.4 xHigh 59.1%, Opus 4.6 thinking 51.9%
* BenchLM model pages: Muse Spark 1.1 TB 2.1 80.0%, 1.2 TB 2.1 82.9%; MiMo-V2-Pro 78% Verified; LongCat-2.0 TB 2.1 70.8%
* Xiaomi MiMo release notes: V2-Flash Thinking 78.6% Verified, tool-call 97%
* Meituan LongCat-2.0 README + ExplainX 09/2026: 1.6T/48B active, 1M, 2.5 Preview live API
* InclusionAI Ling-3.0-flash HF README + apxml: 124B/5.1B, 262K
* BenchLM compare Ling 3.0 FP8 vs Nemotron 3.5 Lightning: SciCode 40.4 vs 31.4, Verified Lightning 52.8%
* AIBenchy compare: Nemotron 3 Ultra medium 7.6 vs DeepSeek V4 Pro 6.8, coding 8.4 vs 5.6
* OpenCode Data: Nemotron 3.5 Lightning 30B A3B, Ling 3.0 Flash Fin usage rank
* Community skill docs: Big Pickle = stealth GLM-4.6, Sonnet-class, 200K/32K

*Ghi chú trung thực: một số ID stealth (space-bunny, fledge-alpha, big-pickle) không có benchmark official; đánh giá dựa trên docs Zen + consensus cộng đồng + họ model liên quan. Nên smoke-test trên repo của bạn trước khi chốt.*
