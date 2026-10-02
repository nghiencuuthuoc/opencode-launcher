# OpenCode Launcher + Cập nhật Model Free (Bản tiếng Việt)

Bộ launcher OpenCode cho Windows kèm script tự động cập nhật danh sách model free và bản phân tích model nào dev code tốt nhất.

## Có gì trong thư mục này?

| File | Mô tả |
|------|-------|
| `opencode_launcher.bat` | Launcher chính. Nhấn Enter dùng thư mục launcher; chế độ quyền thường (non-auto) là mặc định; model mặc định là Muse Spark 1.3 Contributor Free |
| `update_opencode_models.py` | Lấy danh sách model mới nhất từ API chính thức của OpenCode và ghi danh sách free ra file Markdown |
| `opencode_model.md` | Danh sách model free, vừa đọc được vừa để file BAT parse |
| `opencode_launcher_original.bat` | Bản backup launcher gốc trước khi cập nhật |
| `phan-tich-model-dev-code-best.md` | Phân tích sâu 14 model free: model nào dev code tốt nhất (bản Markdown) |
| `phan-tich-model-dev-code-best.html` | Cùng nội dung trên, bản web đẹp, có nút Copy từng đoạn code |
| `phan-tich-model-dev-code-best.pdf` | Cùng nội dung trên, bản PDF A4 |
| `make_pdf.py` | Script tái tạo file PDF khi bạn sửa file MD |

## Cách dùng

1. Để tất cả file trong cùng một thư mục.
2. Chạy `opencode_launcher.bat`.
3. Ở menu chọn model:
   - Nhấn **Enter** để dùng Muse Spark 1.3 Contributor Free (khuyên dùng cho task khó);
   - Nhập **số thứ tự** để chọn model free khác;
   - Nhập **`U`** để refresh danh sách từ API chính thức của OpenCode;
   - Nhập **`C`** để gõ tay ID provider/model bất kỳ.
4. Chế độ quyền mặc định là **không tự động**. Chọn mục 2 trong menu để thêm `--auto` khi cần.

## Cập nhật từ dòng lệnh

Chạy:

```bat
python update_opencode_models.py
```

Không cần cài thêm package nào (chỉ dùng thư viện chuẩn Python 3.8+).

## Nếu mạng/API lỗi thì sao?

Script cập nhật dùng cơ chế **ghi file nguyên tử (atomic)**. Nếu mạng, API hoặc parse lỗi, file `opencode_model.md` cũ vẫn được giữ nguyên nên launcher BAT vẫn chạy tiếp bằng danh sách đã lưu — không bị trắng menu.

## Kết luận nhanh từ bản phân tích

| Hạng | Model | Chốt |
|------|-------|------|
| #1 | `opencode/muse-spark-1.3-contributor-free` | Mạnh nhất cho code khó, multi-file, agent dài hơi |
| #2 | `opencode/deepseek-v4-flash-free` | Mạnh và ổn định nhất nhóm open-weight |
| #3 | `opencode/big-pickle` | Dùng hàng ngày ngon nhất, **không dùng cho code private** |
| Loại | `opencode/jev-1.13-free` | Không phải model code, chỉ trả quyết định có cấu trúc |

Quy trình gợi ý:

```text
Task khó / repo lớn / agent dài  -> muse-spark-1.3 (lỗi -> muse-spark-1.2)
Việc hàng ngày (không private)   -> big-pickle trước, lỗi 2 lần -> deepseek-v4-flash
Repo private / khách hàng        -> longcat-2.5-preview-free hoặc space-bunny-free
Edit nhỏ, cần tốc độ             -> ling-3.1-flash / nemotron-3.5-lightning
```

Chi tiết đầy đủ xem 3 file `phan-tich-model-dev-code-best.*` trong cùng thư mục.

## Nguồn

- Docs OpenCode Zen: <https://opencode.ai/docs/zen>
- API models: <https://opencode.ai/zen/v1/models>
- Bench: SWE-bench Verified / SWE-bench Pro (Scale) / Terminal-Bench 2.x / LiveCodeBench
