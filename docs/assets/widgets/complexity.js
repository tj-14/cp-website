// Interactive complexity estimator: operations and time per complexity class for a given n.
const Complexity = (() => {
    const OPS_PER_SECOND = 1e8;

    // ln(x!): exact sum for small x, Stirling's approximation otherwise.
    const logFactorial = (x) => {
        let sum = 0;
        if (x < 20) {
            for (let i = 2; i <= x; i++) sum += Math.log(i);
            return sum;
        }
        return x * Math.log(x) - x + 0.5 * Math.log(2 * Math.PI * x) + 1 / (12 * x);
    };

    // Each class returns log10 of its operation count so huge values stay finite.
    const CLASSES = [
        { label: 'O(1)', log10: () => 0 },
        { label: 'O(log n)', log10: (n) => Math.log10(Math.max(1, Math.log2(n))) },
        { label: 'O(√n)', log10: (n) => 0.5 * Math.log10(n) },
        { label: 'O(n)', log10: (n) => Math.log10(n) },
        { label: 'O(n log n)', log10: (n) => Math.log10(n * Math.max(1, Math.log2(n))) },
        { label: 'O(n²)', log10: (n) => 2 * Math.log10(n) },
        { label: 'O(n³)', log10: (n) => 3 * Math.log10(n) },
        { label: 'O(2ⁿ)', log10: (n) => n * Math.log10(2) },
        { label: 'O(n!)', log10: (n) => logFactorial(n) / Math.LN10 },
    ];

    function estimate(n, limitSeconds) {
        const budget = Math.log10(OPS_PER_SECOND * limitSeconds);
        return CLASSES.map((c) => {
            const log10 = c.log10(n);
            return { label: c.label, log10, passes: log10 <= budget };
        });
    }

    function formatOps(log10) {
        if (log10 < 6) return Math.round(10 ** log10).toLocaleString('en-US');
        if (log10 > 300) return '> 10^300';
        const exp = Math.floor(log10);
        return `${(10 ** (log10 - exp)).toFixed(1)} × 10^${exp}`;
    }

    function formatTime(log10) {
        const seconds = 10 ** (log10 - Math.log10(OPS_PER_SECOND));
        if (seconds < 1e-3) return '< 1 ms';
        if (seconds < 1) return `${Math.round(seconds * 1000)} ms`;
        if (seconds < 120) return `${seconds.toFixed(1)} วินาที`;
        if (seconds < 7200) return `${Math.round(seconds / 60)} นาที`;
        if (seconds < 86400 * 365) return `${Math.round(seconds / 3600)} ชั่วโมง`;
        return 'นานกว่า 1 ปี';
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>n <input name="n" class="cx-n" type="number" min="1" max="1000000000" value="100000"></label>
                <label>เวลาที่โจทย์ให้ <select name="limit"><option value="1">1 วินาที</option><option value="2">2 วินาที</option></select></label>
                <label><input name="guess-mode" type="checkbox"> ให้ฉันทายก่อน</label>
            </div>
            <p class="widget-explain cx-hint" hidden>คลิกแถวที่คิดว่าผ่านเวลา แล้วกด "ตรวจคำตอบ"</p>
            <div class="widget-table"><table class="cx-table"></table></div>
            <div class="widget-controls cx-guess" hidden>
                <button type="button" data-act="check">ตรวจคำตอบ</button>
            </div>
            <p class="widget-summary" aria-live="polite"></p>`;
    }

    function verdictCell(row, s, i) {
        if (s.guessMode && !s.checked) return s.picks.has(i) ? '✓ (ทาย)' : '?';
        const mark = row.passes ? '✓ ผ่าน' : '✗ ไม่ผ่าน';
        if (!s.guessMode) return mark;
        return s.picks.has(i) === row.passes ? `${mark} - ทายถูก` : `${mark} - ทายผิด`;
    }

    function render(root, s) {
        const rows = estimate(s.n, s.limit);
        const maxBar = 12;  // log10 scale: bars cap at 10^12 operations
        const budget = Math.log10(OPS_PER_SECOND * s.limit);
        const body = rows.map((row, i) => {
            const width = Math.min(100, Math.max(1, (row.log10 / maxBar) * 100));
            const reveal = !s.guessMode || s.checked;
            const cls = [reveal ? (row.passes ? 'is-pass' : 'is-fail') : '', s.picks.has(i) ? 'is-picked' : '']
                .filter(Boolean).join(' ');
            return `<tr class="${cls}" data-row="${i}" ${s.guessMode && !s.checked ? 'tabindex="0" role="button"' : ''}>
                <th scope="row">${row.label}</th>
                <td>${formatOps(row.log10)}</td>
                <td>${reveal ? formatTime(row.log10) : '?'}</td>
                <td class="cx-bar-cell"><span class="cx-bar" style="width:${width}%"></span></td>
                <td>${verdictCell(row, s, i)}</td></tr>`;
        });
        const line = Math.min(100, (budget / maxBar) * 100);
        root.querySelector('.cx-table').innerHTML = `<thead><tr><th scope="col">complexity</th>
            <th scope="col">จำนวนคำสั่งโดยประมาณ</th><th scope="col">เวลา</th>
            <th scope="col" class="cx-bar-cell">เทียบ (log scale, เส้น = ${s.limit} วินาที)</th><th scope="col">ผล</th></tr></thead>
            <tbody style="--cx-limit:${line}%">${body.join('')}</tbody>`;
        root.querySelector('.cx-hint').hidden = !s.guessMode || s.checked;
        root.querySelector('.cx-guess').hidden = !s.guessMode || s.checked;
        const slowestPass = rows.filter((r) => r.passes).pop();
        let summary = `สมมติว่า grader รันได้ 10^8 คำสั่งต่อวินาที วิธีที่ช้าที่สุดที่ยังผ่านคือ ${slowestPass.label}`;
        if (s.guessMode && s.checked) {
            const right = rows.filter((r, i) => s.picks.has(i) === r.passes).length;
            summary = `ทายถูก ${right}/${rows.length} แถว. ${summary}`;
        }
        root.querySelector('.widget-summary').textContent = summary;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { n: 100000, limit: 1, guessMode: false, checked: false, picks: new Set() };
        const read = () => {
            const n = Math.round(Number(root.querySelector('[name="n"]').value));
            s.n = Number.isFinite(n) ? Math.min(Math.max(n, 1), 1e9) : 1;
            s.limit = Number(root.querySelector('[name="limit"]').value);
            s.guessMode = root.querySelector('[name="guess-mode"]').checked;
            s.checked = false;
            s.picks = new Set();
            render(root, s);
        };
        const toggle = (target) => {
            const row = target.closest?.('[data-row]');
            if (!row || !s.guessMode || s.checked) return false;
            const i = Number(row.dataset.row);
            if (s.picks.has(i)) s.picks.delete(i);
            else s.picks.add(i);
            render(root, s);
            root.querySelector(`[data-row="${i}"]`)?.focus();
            return true;
        };
        root.addEventListener('click', (event) => {
            if (toggle(event.target)) return;
            if (event.target.dataset?.act === 'check') {
                s.checked = true;
                render(root, s);
            }
        });
        root.addEventListener('keydown', (event) => {
            if ((event.key === 'Enter' || event.key === ' ') && toggle(event.target)) event.preventDefault();
        });
        root.querySelectorAll('input, select').forEach((el) => el.addEventListener('change', read));
        read();
    }

    return { estimate, formatOps, formatTime, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="complexity"]').forEach(Complexity.mount);
}
