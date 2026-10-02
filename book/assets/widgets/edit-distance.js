// Interactive edit distance: fill the dp table cell by cell, then trace the edits back.
const EditDistance = (() => {
    const MAX_LEN = 10;

    function solve(a, b) {
        const dp = Array.from({ length: a.length + 1 }, () => Array(b.length + 1).fill(0));
        for (let i = 0; i <= a.length; i++) {
            for (let j = 0; j <= b.length; j++) {
                if (i === 0 || j === 0) dp[i][j] = i + j;
                else if (a[i - 1] === b[j - 1]) dp[i][j] = dp[i - 1][j - 1];
                else dp[i][j] = 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
            }
        }
        return dp;
    }

    // Walks back from the corner; returns visited cells and the edit list in forward order.
    function trace(a, b, dp) {
        let i = a.length;
        let j = b.length;
        const cells = [[i, j]];
        const ops = [];
        while (i > 0 || j > 0) {
            if (i > 0 && j > 0 && a[i - 1] === b[j - 1] && dp[i][j] === dp[i - 1][j - 1]) {
                ops.push(`คง ${a[i - 1]}`);
                i -= 1;
                j -= 1;
            } else if (i > 0 && j > 0 && dp[i][j] === dp[i - 1][j - 1] + 1) {
                ops.push(`แทน ${a[i - 1]} ด้วย ${b[j - 1]}`);
                i -= 1;
                j -= 1;
            } else if (i > 0 && dp[i][j] === dp[i - 1][j] + 1) {
                ops.push(`ลบ ${a[i - 1]}`);
                i -= 1;
            } else {
                ops.push(`เพิ่ม ${b[j - 1]}`);
                j -= 1;
            }
            cells.push([i, j]);
        }
        return { cells, ops: ops.reverse() };
    }

    function explain(s, i, j) {
        const { a, b, dp } = s;
        if (i === 0 || j === 0) return `dp[${i}][${j}] = ${i + j}: แปลงข้อความยาว ${i} เป็นยาว ${j} เมื่อฝั่งหนึ่งว่าง ต้องเพิ่มหรือลบทุกตัว`;
        if (a[i - 1] === b[j - 1]) return `dp[${i}][${j}]: ${a[i - 1]} = ${b[j - 1]} ไม่ต้องแก้ จึงเท่ากับ dp[${i - 1}][${j - 1}] = ${dp[i][j]}`;
        return `dp[${i}][${j}]: ${a[i - 1]} ≠ ${b[j - 1]} จึงเป็น 1 + min(ลบ ${dp[i - 1][j]}, เพิ่ม ${dp[i][j - 1]}, แทน ${dp[i - 1][j - 1]}) = ${dp[i][j]}`;
    }

    function render(root, s) {
        const cols = s.b.length + 1;
        const total = (s.a.length + 1) * cols;
        const done = s.filled >= total;
        const ci = Math.floor(s.filled / cols);
        const cj = s.filled % cols;
        const reads = !done && ci > 0 && cj > 0 ? [[ci - 1, cj], [ci, cj - 1], [ci - 1, cj - 1]] : [];
        const path = done ? trace(s.a, s.b, s.dp) : { cells: [], ops: [] };
        const has = (list, i, j) => list.some(([x, y]) => x === i && y === j);
        const head = `<tr><th></th><th>ε</th>${[...s.b].map((c) => `<th>${c}</th>`).join('')}</tr>`;
        const rows = s.dp.map((row, i) => {
            const label = i === 0 ? 'ε' : s.a[i - 1];
            const cells = row.map((v, j) => {
                const k = i * cols + j;
                const cls = [k === s.filled ? 'is-current' : '', has(reads, i, j) ? 'is-read' : '', has(path.cells, i, j) ? 'is-path' : '']
                    .filter(Boolean).join(' ');
                return `<td class="${cls}">${k < s.filled ? v : (k === s.filled ? '?' : '')}</td>`;
            }).join('');
            return `<tr><th scope="row">${label}</th>${cells}</tr>`;
        }).join('');
        root.querySelector('.ed-table').innerHTML = `<table>${head}${rows}</table>`;
        const last = s.filled - 1;
        const note = s.message || (last >= 0 ? explain(s, Math.floor(last / cols), last % cols) : 'dp[i][j] = จำนวนการแก้น้อยสุดที่แปลง i ตัวแรกของคำบน เป็น j ตัวแรกของคำด้านข้าง');
        root.querySelector('.widget-explain').textContent = note;
        root.querySelector('.ed-result').textContent = done
            ? `edit distance = ${s.dp[s.a.length][s.b.length]}: ${path.ops.filter((o) => !o.startsWith('คง')).join(', ') || 'เหมือนกันอยู่แล้ว'} (เส้นทางย้อนรอยไฮไลต์ในตาราง)`
            : '';
        root.querySelector('.ed-guess').hidden = !s.guessMode || done;
        root.querySelector('.ed-guess-label').textContent = `dp[${ci}][${cj}]`;
        root.querySelector('.widget-score').textContent = s.tries ? `ทายถูก ${s.correct}/${s.tries}` : '';
        root.querySelector('[data-act="next"]').disabled = done || s.guessMode;
        root.querySelector('[data-act="all"]').disabled = done;
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>จาก <input name="a" value="LOVE" maxlength="${MAX_LEN}" size="8"></label>
                <label>เป็น <input name="b" value="MOVIE" maxlength="${MAX_LEN}" size="8"></label>
                <label><input name="guess-mode" type="checkbox"> ให้ฉันทายก่อน</label>
            </div>
            <div class="ed-table widget-table"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls ed-guess" hidden>
                <label>ทาย <span class="ed-guess-label"></span> = <input name="guess" type="number" min="0" size="4"></label>
                <button type="button" data-act="check">ตรวจคำตอบ</button>
                <span class="widget-score"></span>
            </div>
            <div class="widget-controls">
                <button type="button" data-act="next">ถัดไป →</button>
                <button type="button" data-act="all">เติมทั้งหมด</button>
                <button type="button" data-act="reset">เริ่มใหม่</button>
            </div>
            <p class="widget-summary ed-result" aria-live="polite"></p>`;
    }

    function check(root, s) {
        const input = root.querySelector('[name="guess"]');
        if (input.value.trim() === '') return;
        const cols = s.b.length + 1;
        const i = Math.floor(s.filled / cols);
        const j = s.filled % cols;
        const ok = Number(input.value) === s.dp[i][j];
        s.tries += 1;
        if (ok) s.correct += 1;
        s.filled += 1;
        s.message = `${ok ? '✓ ถูกต้อง' : `✗ ยังไม่ถูก คำตอบคือ ${s.dp[i][j]}`} - ${explain(s, i, j)}`;
        input.value = '';
    }

    function mount(root) {
        root.innerHTML = template();
        const s = {};
        const reset = () => {
            const clean = (name) => root.querySelector(`[name="${name}"]`).value.trim().toUpperCase().slice(0, MAX_LEN);
            Object.assign(s, { a: clean('a'), b: clean('b'), filled: 0, tries: 0, correct: 0, message: '' });
            s.dp = solve(s.a, s.b);
            s.guessMode = root.querySelector('[name="guess-mode"]').checked;
            render(root, s);
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act) return;
            if (act === 'reset') return reset();
            s.message = '';
            if (act === 'next') s.filled += 1;
            if (act === 'all') s.filled = (s.a.length + 1) * (s.b.length + 1);
            if (act === 'check') check(root, s);
            render(root, s);
            if (act === 'check') root.querySelector('[name="guess"]').focus();
        });
        root.querySelector('[name="guess"]').addEventListener('keydown', (event) => {
            if (event.key !== 'Enter') return;
            s.message = '';
            check(root, s);
            render(root, s);
        });
        root.querySelectorAll('[name="a"], [name="b"], [name="guess-mode"]').forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { solve, trace, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="edit-distance"]').forEach(EditDistance.mount);
}
