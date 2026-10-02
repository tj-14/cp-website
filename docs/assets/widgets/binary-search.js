// Interactive binary search: lower_bound on a sorted array with lo / mid / hi pointers.
const BinarySearch = (() => {
    // Half-open [lo, hi): answer is the first index with a[i] >= x (n when none).
    function lowerBoundSteps(a, x) {
        let lo = 0;
        let hi = a.length;
        const steps = [];
        while (lo < hi) {
            const mid = Math.floor((lo + hi) / 2);
            const right = a[mid] < x;
            steps.push({ lo, hi, mid, right });
            if (right) lo = mid + 1;
            else hi = mid;
        }
        return { steps, answer: lo };
    }

    function randomSorted(n) {
        const a = [];
        let v = 1 + Math.floor(Math.random() * 4);
        for (let i = 0; i < n; i++) {
            a.push(v);
            v += Math.floor(Math.random() * 6);  // gaps of 0 keep duplicates in play
        }
        return a;
    }

    function stepNote(s, st) {
        const cmp = st.right
            ? `a[${st.mid}] = ${s.a[st.mid]} < ${s.x} คำตอบต้องอยู่ทางขวาของ mid จึงตั้ง lo = ${st.mid + 1}`
            : `a[${st.mid}] = ${s.a[st.mid]} ≥ ${s.x} mid อาจเป็นคำตอบ จึงเก็บไว้และตั้ง hi = ${st.mid}`;
        return `ช่วง [${st.lo}, ${st.hi}) mid = (${st.lo} + ${st.hi}) / 2 = ${st.mid}: ${cmp}`;
    }

    function render(root, s) {
        const { steps, answer } = s.run;
        const done = s.step >= steps.length;
        const cur = steps[s.step];
        const lo = done ? answer : cur.lo;
        const hi = done ? answer : cur.hi;
        const cells = s.a.map((v, i) => {
            const cls = [];
            if (i < lo || i >= hi) cls.push('is-out');
            if (!done && i === cur.mid) cls.push('is-mid');
            if (done && i === answer) cls.push('is-answer');
            const tags = [i === lo ? 'lo' : '', !done && i === cur.mid ? 'mid' : '', !done && i === hi - 1 ? 'hi-1' : '']
                .filter(Boolean).join(' ');
            return `<span class="bs-cell ${cls.join(' ')}"><small>${i}</small>${v}<em>${tags}</em></span>`;
        });
        if (done && answer === s.a.length) cells.push('<span class="bs-cell is-answer"><small>n</small>-<em>lo</em></span>');
        root.querySelector('.bs-cells').innerHTML = cells.join('');
        let note;
        if (done) {
            note = answer < s.a.length
                ? `lo = hi = ${answer}: ตำแหน่งแรกที่ a[i] ≥ ${s.x} คือ index ${answer} (a[${answer}] = ${s.a[answer]})`
                : `lo = hi = n = ${s.a.length}: ไม่มีค่าใดที่ ≥ ${s.x}`;
        } else {
            note = s.guessMode
                ? `ช่วง [${cur.lo}, ${cur.hi}) mid = ${cur.mid}, a[mid] = ${s.a[cur.mid]} ทายว่าคำตอบอยู่ฝั่งไหน`
                : (s.step > 0 ? stepNote(s, steps[s.step - 1]) : `หา lower_bound ของ ${s.x}: ตำแหน่งแรกที่ค่า ≥ ${s.x} เริ่มที่ lo = 0, hi = n = ${s.a.length}`);
        }
        root.querySelector('.widget-explain').textContent = s.message ? `${s.message} ${note}` : note;
        const limit = Math.ceil(Math.log2(s.a.length + 1));
        root.querySelector('.widget-summary').textContent =
            `ใช้ ${Math.min(s.step, steps.length)} ขั้น (n = ${s.a.length} จึงไม่เกิน ⌈log₂(n + 1)⌉ = ${limit} ขั้น)`
            + (s.tries ? ` ทายถูก ${s.correct}/${s.tries}` : '');
        root.querySelector('.bs-guess').hidden = !s.guessMode || done;
        root.querySelector('[data-act="next"]').disabled = done || s.guessMode;
        root.querySelector('[data-act="all"]').disabled = done;
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>หา x <input name="x" type="number" value="12"></label>
                <label>n <select name="n"><option>8</option><option selected>16</option><option>32</option></select></label>
                <button type="button" data-act="random">สุ่ม array ใหม่</button>
                <label><input name="guess-mode" type="checkbox"> ให้ฉันทายก่อน</label>
            </div>
            <div class="bs-cells widget-table"></div>
            <p class="widget-explain" aria-live="polite"></p>
            <div class="widget-controls bs-guess" hidden>
                <button type="button" data-guess="left">คำตอบอยู่ที่ mid หรือทางซ้าย</button>
                <button type="button" data-guess="right">คำตอบอยู่ทางขวาของ mid</button>
            </div>
            <div class="widget-controls">
                <button type="button" data-act="next">ถัดไป →</button>
                <button type="button" data-act="all">ทำจนจบ</button>
                <button type="button" data-act="reset">เริ่มใหม่</button>
            </div>
            <p class="widget-summary"></p>`;
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { a: [1, 3, 3, 5, 6, 8, 9, 12, 12, 15, 17, 20, 21, 24, 27, 30] };
        const reset = () => {
            s.x = Number(root.querySelector('[name="x"]').value) || 0;
            s.guessMode = root.querySelector('[name="guess-mode"]').checked;
            s.run = lowerBoundSteps(s.a, s.x);
            Object.assign(s, { step: 0, tries: 0, correct: 0, message: '' });
            render(root, s);
        };
        root.addEventListener('click', (event) => {
            const { act, guess } = event.target.dataset ?? {};
            if (guess) {
                const st = s.run.steps[s.step];
                const ok = (guess === 'right') === st.right;
                s.tries += 1;
                if (ok) s.correct += 1;
                s.step += 1;
                s.message = `${ok ? '✓ ถูกต้อง' : '✗ ยังไม่ถูก'} - ${stepNote(s, st)}.`;
                render(root, s);
                return;
            }
            if (!act) return;
            s.message = '';
            if (act === 'next') s.step += 1;
            if (act === 'all') s.step = s.run.steps.length;
            if (act === 'random') {
                s.a = randomSorted(Number(root.querySelector('[name="n"]').value));
                root.querySelector('[name="x"]').value = s.a[Math.floor(Math.random() * s.a.length)];
            }
            if (act === 'random' || act === 'reset') return reset();
            render(root, s);
        });
        root.querySelector('[name="n"]').addEventListener('change', (event) => {
            s.a = randomSorted(Number(event.target.value));
            reset();
        });
        root.querySelectorAll('[name="x"], [name="guess-mode"]').forEach((el) => el.addEventListener('change', reset));
        reset();
    }

    return { lowerBoundSteps, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="binary-search"]').forEach(BinarySearch.mount);
}
