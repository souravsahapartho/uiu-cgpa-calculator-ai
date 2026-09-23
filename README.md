# UIU CGPA Calculator AI 🎓
### *AI-Supported Academic & CGPA Intelligence for United International University (UIU)*

[![Download Direct ZIP](https://img.shields.io/badge/Download-Direct%20ZIP%20(1--Click)-success?style=for-the-badge&logo=github)](https://github.com/souravsahapartho/uiu-cgpa-calculator-ai/archive/refs/heads/main.zip)
[![Cloudflare Worker](https://img.shields.io/badge/Cloudflare%20Worker-Ready-orange?style=for-the-badge&logo=cloudflare)](https://uiucgpacalculator.uiusvs-event.workers.dev/)
[![UIU Official](https://img.shields.io/badge/University-United%20International%20University-blue?style=for-the-badge)](https://www.uiu.ac.bd)

---

## 📥 Direct Download Links

Anyone can download the full project immediately using either of these links:

- 🚀 **[Direct ZIP Download (1-Click)](https://github.com/souravsahapartho/uiu-cgpa-calculator-ai/archive/refs/heads/main.zip)**
- 💻 **Git Clone:**
  ```bash
  git clone https://github.com/souravsahapartho/uiu-cgpa-calculator-ai.git
  ```

---

## 🏛️ Official UIU Grading Scale (Embedded)

| Letter Grade | Marks Range | Grade Point | Remarks |
|---|---|---|---|
| **A** | **90 - 100** | **4.00** | Plain |
| **A-** | **86 - 89** | **3.67** | Minus |
| **B+** | **82 - 85** | **3.33** | Plus |
| **B** | **78 - 81** | **3.00** | Plain |
| **B-** | **74 - 77** | **2.67** | Minus |
| **C+** | **70 - 73** | **2.33** | Plus |
| **C** | **66 - 69** | **2.00** | Plain |
| **C-** | **62 - 65** | **1.67** | Minus |
| **D+** | **58 - 61** | **1.33** | Plus |
| **D** | **55 - 57** | **1.00** | Plain |
| **F** | **0 - 54** | **0.00** | Fail |

---

## ⚡ Features & Capabilities

1. **Target CGPA Planner:** Computes exact required future SGPA per trimester to hit target CGPA with attainability warnings.
2. **AI Academic Advisor (Cloudflare Workers AI):** Analyzes domain mastery, recommends optimal next-term course combinations, and warns against heavy workload conflicts.
3. **Fail-Safe Reliability:** Equipped with a built-in deterministic academic engine ensuring the AI **never fails** even if network bindings are throttled.
4. **Interactive Transcript Records:** Browse past 7 trimesters with expandable course cards.
5. **Modern UI & Ambient Animation:** Smooth floating ambient orbs, UIU warm orange & navy aesthetic, rounded card glassmorphism.

---

## 🌐 Deploy to Cloudflare Workers

1. Copy the contents of [`worker.js`](worker.js).
2. Open your Cloudflare Workers Dashboard (e.g. `https://uiucgpacalculator.uiusvs-event.workers.dev/`).
3. Paste into the editor and click **Deploy**.
4. Enable Workers AI binding (`@cf/meta/llama-3.1-8b-instruct`) in **Settings -> Bindings -> Workers AI** (optional, fallback is automatically active).
