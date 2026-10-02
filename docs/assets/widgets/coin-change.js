// Interactive coin change DP: step through dp[i] = min(dp[i - c] + 1) one cell at a time.
const CoinChange = (() => {
    function solve(coins, n) {
        const dp = [0];
        const pick = [0];
        for (let i = 1; i <= n; i++) {
            dp[i] = Infinity;
            pick[i] = 0;
            for (const c of coins) {
                if (c <= i && dp[i - c] + 1 < dp[i]) {
                    dp[i] = dp[i - c] + 1;
                    pick[i] = c;
                }
            }
        }
        return { dp, pick };
    }

    function rebuild(pick, n) {
        const used = [];
        for (let i = n; i > 0 && pick[i]; i -= pick[i]) used.push(pick[i]);
        return used;
    }

    // Largest coin first; returns null when greedy gets stuck.
    function greedy(coins, n) {
        const used = [];
        const sorted = [...coins].sort((a, b) => b - a);
        let left = n;
        for (const c of sorted) {
            while (left >= c) {
                used.push(c);
                left -= c;
            }
        }
        return left === 0 ? used : null;
    }

    function parseCoins(text) {
        const coins = text.split(/[\s,]+/).filter(Boolean).map(Number);
        if (coins.length === 0 || coins.some((c) => !Number.isInteger(c) || c < 1 || c > 50)) {
            return null;
        }
        return [...new Set(coins)].sort((a, b) => a - b);
    }

    const show = (v) => (v === Infinity ? '∞' : String(v));

    function explain(coins, dp, i) {
        const parts = coins
            .filter((c) => c <= i)
            .map((c) => `เหรียญ ${c}: dp[${i - c}] + 1 = ${show(dp[i - c] + 1)}`);
        if (parts.length === 0) return `dp[${i}]: ไม่มีเหรียญที่ใช้ได้ จึงเป็น ∞ (ทอนไม่ได้)`;
        return `dp[${i}] = min(${parts.join(', ')}) = ${show(dp[i])}`;
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>เหรียญ <input name="coins" value="1, 3, 4" size="10"></label>
                <label>เป้าหมาย n <input name="n" type="number" min="1" max="40" value="10"></label>
                <label><input name="guess-mode" type="checkbox"> ให้ฉันทายก่อน</label>
            </div>
            <div class="widget-table" tabindex="0" role="region" aria-label="ตาราง dp"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls guess-row" hidden>
                <label>ทาย <span class="guess-label"></span> = <input name="guess" type="number" min="0" size="4"></label>
                <button type="button" data-act="check">ตรวจคำตอบ</button>
                <span class="widget-score"></span>
            </div>
            <div class="widget-controls">
                <button type="button" data-act="back">← ย้อนกลับ</button>
                <button type="button" data-act="next">ถัดไป →</button>
                <button type="button" data-act="all">เติมทั้งหมด</button>
                <button type="button" data-act="reset">เริ่มใหม่</button>
            </div>
            <p class="widget-summary" aria-live="polite"></p>`;
    }

    function renderTable(root, s) {
        const step = s.filled;
        const reads = step <= s.n ? s.coins.filter((c) => c <= step).map((c) => step - c) : [];
        const cells = s.dp.map((v, i) => {
            const cls = [i === step ? 'is-current' : '', reads.includes(i) ? 'is-read' : '']
                .filter(Boolean).join(' ');
            const value = i < step ? show(v) : i === step ? '?' : '';
            return `<td class="${cls}">${value}</td>`;
        });
        const heads = s.dp.map((_, i) => `<th scope="col">${i}</th>`);
        root.querySelector('.widget-table').innerHTML = `<table>
            <tr><th scope="row">i</th>${heads.join('')}</tr>
            <tr><th scope="row">dp[i]</th>${cells.join('')}</tr></table>`;
    }

    function summary(s) {
        const { n, dp, pick, coins } = s;
        if (dp[n] === Infinity) return `ทอน ${n} ด้วยเหรียญชุดนี้ไม่ได้เลย`;
        const best = rebuild(pick, n);
        const g = greedy(coins, n);
        const dpLine = `DP: ทอน ${n} ใช้ ${best.length} เหรียญ (${best.join(' + ')}) ย้อนรอยจากเหรียญที่เลือกในแต่ละช่อง`;
        if (!g) return `${dpLine}. ส่วน greedy (หยิบเหรียญใหญ่สุดก่อน) ทอนไม่ได้เลย`;
        const verdict = g.length > best.length ? 'greedy ได้คำตอบที่แย่กว่า!' : 'ครั้งนี้ greedy ได้เท่ากัน';
        return `${dpLine}. Greedy: ${g.length} เหรียญ (${g.join(' + ')}) - ${verdict}`;
    }

    function render(root, s) {
        renderTable(root, s);
        const done = s.filled > s.n;
        const last = s.filled - 1;
        root.querySelector('.widget-explain').textContent = s.message
            || (last >= 1 ? explain(s.coins, s.dp, last) : 'dp[0] = 0 (base case: ทอน 0 บาทไม่ต้องใช้เหรียญ)');
        root.querySelector('.widget-summary').textContent = done ? summary(s) : '';
        root.querySelector('.guess-row').hidden = !s.guessMode || done;
        root.querySelector('.guess-label').textContent = `dp[${s.filled}]`;
        root.querySelector('.widget-score').textContent = s.tries ? `ทายถูก ${s.correct}/${s.tries}` : '';
        root.querySelector('[data-act="back"]').disabled = s.filled <= 1;
        root.querySelector('[data-act="next"]').disabled = done || s.guessMode;
        root.querySelector('[data-act="all"]').disabled = done;
    }

    function readInputs(root) {
        const coins = parseCoins(root.querySelector('[name="coins"]').value);
        const n = Number(root.querySelector('[name="n"]').value);
        if (!coins || !Number.isInteger(n) || n < 1 || n > 40) return null;
        return { coins, n, ...solve(coins, n) };
    }

    function checkGuess(root, s) {
        const input = root.querySelector('[name="guess"]');
        const raw = input.value.trim();
        const truth = s.dp[s.filled];
        const guess = raw === '∞' || raw.toLowerCase() === 'inf' ? Infinity : Number(raw);
        if (raw === '') return;
        s.tries += 1;
        const ok = guess === truth;
        if (ok) s.correct += 1;
        s.filled += 1;
        s.message = `${ok ? '✓ ถูกต้อง' : `✗ ยังไม่ถูก คำตอบคือ ${show(truth)}`} - ${explain(s.coins, s.dp, s.filled - 1)}`;
        input.value = '';
        input.focus();
    }

    function mount(root) {
        root.innerHTML = template();
        let s = null;
        const reset = () => {
            const base = readInputs(root);
            const guessMode = root.querySelector('[name="guess-mode"]').checked;
            if (!base) {
                root.querySelector('.widget-explain').textContent = 'ใส่เหรียญเป็นจำนวนเต็ม 1-50 คั่นด้วย , และ n ระหว่าง 1-40';
                return;
            }
            s = { ...base, guessMode, filled: 1, tries: 0, correct: 0, message: '' };
            render(root, s);
        };
        const actions = {
            next: () => { s.filled += 1; },
            back: () => { s.filled -= 1; },
            all: () => { s.filled = s.n + 1; },
            reset: () => {},
            check: () => checkGuess(root, s),
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act || !s) return;
            if (act === 'reset') return reset();
            s.message = '';
            actions[act]();
            render(root, s);
        });
        root.querySelector('[name="guess"]').addEventListener('keydown', (event) => {
            if (event.key !== 'Enter') return;
            checkGuess(root, s);
            render(root, s);
        });
        root.querySelectorAll('[name="coins"], [name="n"], [name="guess-mode"]')
            .forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { solve, rebuild, greedy, parseCoins, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="coin-change"]').forEach(CoinChange.mount);
}
