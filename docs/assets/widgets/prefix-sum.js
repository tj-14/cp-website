// Interactive prefix sums: range-sum queries and difference-array range updates (1-indexed).
const PrefixSum = (() => {
    const START = [3, 1, 4, 1, 5, 9, 2, 6];

    function prefix(a) {
        const pref = [0];
        a.forEach((x, i) => pref.push(pref[i] + x));
        return pref;
    }

    // Applies (l, r, x) updates through a difference array; returns diff and the final array.
    function applyUpdates(a, updates) {
        const n = a.length;
        const diff = Array(n + 2).fill(0);
        for (const [l, r, x] of updates) {
            diff[l] += x;
            diff[r + 1] -= x;
        }
        let cur = 0;
        const result = a.map((v, i) => {
            cur += diff[i + 1];
            return v + cur;
        });
        return { diff, result };
    }

    const cell = (v, cls = '') => `<td class="${cls}">${v}</td>`;

    function renderSum(root, s) {
        const pref = prefix(s.a);
        const [l, r] = s.l && s.r ? [Math.min(s.l, s.r), Math.max(s.l, s.r)] : [s.l, s.l];
        const idx = ['<th scope="row">i</th>', ...s.a.map((_, i) => `<th>${i + 1}</th>`)].join('');
        const arr = ['<th scope="row">a[i]</th>', ...s.a.map((v, i) => `<td class="${l && i + 1 >= l && i + 1 <= r ? 'is-range' : ''}" tabindex="0" role="button" aria-label="a[${i + 1}] = ${v}">${v}</td>`)].join('');
        const prefRow = ['<th scope="row">pref[i]</th>', ...pref.slice(1).map((v, i) => {
            const k = i + 1;
            const cls = s.r && k === r ? 'is-plus' : (s.r && k === l - 1 ? 'is-minus' : '');
            return cell(v, cls);
        })].join('');
        root.querySelector('.ps-grid').innerHTML = `<table><tr>${idx}</tr><tr class="ps-pick">${arr}</tr><tr>${prefRow}</tr></table>
            <p class="ps-zero">pref[0] = 0${s.r && l === 1 ? ' (ใช้เป็น pref[l-1] เมื่อ l = 1)' : ''}</p>`;
        let note = 'คลิกช่อง a[i] สองช่องเพื่อเลือกช่วง [l, r]';
        if (s.l && !s.r) note = `เลือก l = ${s.l} แล้ว คลิกอีกช่องเพื่อเลือก r`;
        if (s.r) {
            const sum = pref[r] - pref[l - 1];
            note = `ผลรวม a[${l}..${r}] = pref[${r}] - pref[${l - 1}] = ${pref[r]} - ${pref[l - 1]} = ${sum} (ใช้ 2 ค่า ไม่ต้องบวกทีละตัว)`;
        }
        root.querySelector('.widget-explain').textContent = note;
    }

    function renderDiff(root, s) {
        const { diff, result } = applyUpdates(s.a, s.updates);
        const n = s.a.length;
        const head = ['<th scope="row">i</th>', ...Array.from({ length: n + 1 }, (_, i) => `<th>${i + 1}</th>`)].join('');
        const base = ['<th scope="row">a เดิม</th>', ...s.a.map((v) => cell(v)), cell('')].join('');
        const d = ['<th scope="row">diff[i]</th>', ...diff.slice(1, n + 2).map((v) => cell(v, v > 0 ? 'is-plus' : (v < 0 ? 'is-minus' : '')))].join('');
        const res = ['<th scope="row">a ใหม่</th>', ...result.map((v) => cell(v, 'is-range')), cell('')].join('');
        root.querySelector('.ps-grid').innerHTML = `<table><tr>${head}</tr><tr>${base}</tr><tr>${d}</tr><tr>${res}</tr></table>`;
        const list = s.updates.map(([l, r, x]) => `[${l}, ${r}] += ${x}`).join(', ');
        root.querySelector('.widget-explain').textContent = s.updates.length
            ? `update: ${list}. แต่ละ update แก้ diff แค่ 2 ช่อง (diff[l] += x, diff[r+1] -= x) แล้ว prefix sum ของ diff คือค่าที่ต้องบวกเพิ่ม`
            : 'ใส่ช่วง [l, r] และค่า x แล้วกด "เพิ่มค่าในช่วง"';
    }

    function render(root, s) {
        const sumMode = s.mode === 'sum';
        root.querySelector('.ps-diff-ops').hidden = sumMode;
        if (sumMode) renderSum(root, s);
        else renderDiff(root, s);
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>โหมด <select name="mode">
                    <option value="sum">prefix sum: ผลรวมช่วง</option>
                    <option value="diff">difference array: เพิ่มค่าทั้งช่วง</option></select></label>
                <button type="button" data-act="random">สุ่ม array</button>
            </div>
            <div class="widget-controls ps-diff-ops" hidden>
                <label>l <input name="l" type="number" min="1" value="2"></label>
                <label>r <input name="r" type="number" min="1" value="5"></label>
                <label>x <input name="x" type="number" value="10"></label>
                <button type="button" data-act="update">เพิ่มค่าในช่วง</button>
                <button type="button" data-act="clear">ล้าง update</button>
            </div>
            <div class="ps-grid widget-table"></div>
            <p class="widget-explain" aria-live="polite"></p>`;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { mode: 'sum', a: [...START], l: 0, r: 0, updates: [] };
        const num = (name) => Number(root.querySelector(`[name="${name}"]`).value) || 0;
        root.addEventListener('click', (event) => {
            const td = event.target.closest?.('.ps-pick td');
            if (td && s.mode === 'sum') {
                const i = [...td.parentNode.children].indexOf(td);  // column 0 is the row header
                if (!s.l || s.r) {
                    s.l = i;
                    s.r = 0;
                } else {
                    s.r = i;
                }
            }
            const act = event.target.dataset?.act;
            if (act === 'random') {
                s.a = s.a.map(() => 1 + Math.floor(Math.random() * 9));
                s.l = 0;
                s.r = 0;
            } else if (act === 'update') {
                const n = s.a.length;
                const l = Math.min(Math.max(num('l'), 1), n);
                const r = Math.min(Math.max(num('r'), l), n);
                s.updates.push([l, r, num('x')]);
            } else if (act === 'clear') {
                s.updates = [];
            }
            render(root, s);
        });
        root.addEventListener('keydown', (event) => {
            if ((event.key === 'Enter' || event.key === ' ') && event.target.closest?.('.ps-pick td')) {
                event.preventDefault();
                const col = [...event.target.parentNode.children].indexOf(event.target);
                event.target.click();
                // The grid is rebuilt on render; return focus to the same column.
                root.querySelectorAll('.ps-pick td')[col - 1]?.focus();
            }
        });
        root.querySelector('[name="mode"]').addEventListener('change', (event) => {
            s.mode = event.target.value;
            render(root, s);
        });
        render(root, s);
    }

    return { prefix, applyUpdates, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="prefix-sum"]').forEach(PrefixSum.mount);
}
