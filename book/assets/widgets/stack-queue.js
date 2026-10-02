// Interactive stack vs queue: same operations side by side, plus bracket matching with a stack.
const StackQueue = (() => {
    const PAIRS = { ')': '(', ']': '[', '}': '{' };

    // One step per character; stops at the first mismatch.
    function bracketSteps(text) {
        const stack = [];
        const steps = [];
        for (let i = 0; i < text.length; i++) {
            const ch = text[i];
            if ('([{'.includes(ch)) {
                stack.push(ch);
                steps.push({ i, stack: [...stack], note: `เจอ ${ch} จึง push ลง stack` });
            } else if (ch in PAIRS) {
                const top = stack[stack.length - 1];
                if (top !== PAIRS[ch]) {
                    const why = top ? `บนสุดคือ ${top} ซึ่งไม่คู่กับ ${ch}` : `stack ว่าง ไม่มีวงเล็บเปิดให้จับคู่กับ ${ch}`;
                    steps.push({ i, stack: [...stack], note: `${why} จึงไม่ถูกต้อง`, verdict: false });
                    return steps;
                }
                stack.pop();
                steps.push({ i, stack: [...stack], note: `เจอ ${ch} คู่กับ ${top} บนสุดพอดี จึง pop` });
            }
        }
        const ok = stack.length === 0;
        steps.push({
            i: text.length,
            stack: [...stack],
            note: ok ? 'อ่านครบและ stack ว่าง: วงเล็บถูกต้อง' : `อ่านครบแต่ stack ยังเหลือ ${stack.join('')} ที่ไม่มีคู่: ไม่ถูกต้อง`,
            verdict: ok,
        });
        return steps;
    }

    const box = (v, cls = '') => `<span class="sq-item ${cls}">${v}</span>`;

    function renderCompare(root, s) {
        const stack = s.stack.map((v, i) => box(v, i === s.stack.length - 1 ? 'is-end' : '')).join('');
        const queue = s.queue.map((v, i) => box(v, i === 0 ? 'is-end' : '')).join('');
        root.querySelector('.sq-view').innerHTML = `
            <div class="sq-col"><p><strong>stack</strong> (ออกทาง top)</p><div class="sq-stack">${stack || '<em>ว่าง</em>'}</div></div>
            <div class="sq-col"><p><strong>queue</strong> (ออกทาง front ซ้ายสุด)</p><div class="sq-queue">${queue || '<em>ว่าง</em>'}</div></div>`;
        root.querySelector('.widget-explain').textContent = s.message;
    }

    function renderBrackets(root, s) {
        const step = s.steps[s.step - 1];
        const chars = [...s.text].map((ch, i) => {
            const cls = step && i === step.i ? 'is-current' : (step && i < step.i ? 'is-done' : '');
            return `<span class="sq-char ${cls}">${ch === ' ' ? '&nbsp;' : ch.replace('<', '&lt;')}</span>`;
        }).join('');
        const stack = (step ? step.stack : []).map((ch, i, a) => box(ch, i === a.length - 1 ? 'is-end' : '')).join('');
        root.querySelector('.sq-view').innerHTML = `
            <div class="sq-col"><p><strong>ข้อความ</strong></p><div class="sq-text">${chars}</div></div>
            <div class="sq-col"><p><strong>stack</strong></p><div class="sq-stack">${stack || '<em>ว่าง</em>'}</div></div>`;
        root.querySelector('.widget-explain').textContent = step ? step.note : 'กด "ถัดไป" เพื่ออ่านทีละตัวอักษร';
        const done = s.step >= s.steps.length;
        root.querySelector('[data-act="next"]').disabled = done;
        root.querySelector('[data-act="back"]').disabled = s.step === 0;
    }

    function render(root, s) {
        const compare = s.mode === 'compare';
        root.querySelector('.sq-compare').hidden = !compare;
        root.querySelector('.sq-brackets').hidden = compare;
        if (compare) renderCompare(root, s);
        else renderBrackets(root, s);
    }

    function template() {
        return `
            <div class="widget-controls">
                <label>โหมด <select name="mode">
                    <option value="compare">เปรียบเทียบ stack กับ queue</option>
                    <option value="brackets">ตรวจวงเล็บด้วย stack</option></select></label>
            </div>
            <div class="widget-controls sq-compare">
                <label>ค่า <input name="value" type="number" value="1"></label>
                <button type="button" data-act="push">push</button>
                <button type="button" data-act="pop">pop</button>
                <button type="button" data-act="clear">ล้าง</button>
            </div>
            <div class="widget-controls sq-brackets" hidden>
                <label>ข้อความ <input name="text" value="{[()()]}(" size="16" maxlength="24"></label>
                <button type="button" data-act="back">← ย้อนกลับ</button>
                <button type="button" data-act="next">ถัดไป →</button>
            </div>
            <div class="sq-view"></div>
            <p class="widget-explain" aria-live="polite"></p>`;
    }

    function compareAction(root, s, act) {
        const input = root.querySelector('[name="value"]');
        if (act === 'push') {
            const v = Number(input.value) || 0;
            if (s.stack.length >= 10) {
                s.message = 'เต็มแล้ว (ตัวอย่างนี้จำกัด 10 ตัว)';
                return;
            }
            s.stack.push(v);
            s.queue.push(v);
            input.value = v + 1;
            s.message = `push ${v}: ทั้งสองโครงสร้างใส่ ${v} ไว้ท้าย`;
        } else if (act === 'pop') {
            if (s.stack.length === 0) {
                s.message = 'ว่างอยู่ pop ไม่ได้';
                return;
            }
            const top = s.stack.pop();
            const front = s.queue.shift();
            s.message = `pop: stack ได้ ${top} (เข้าหลังสุด ออกก่อน) แต่ queue ได้ ${front} (เข้าก่อน ออกก่อน)`;
        } else if (act === 'clear') {
            s.stack = [];
            s.queue = [];
            s.message = '';
        }
    }

    function mount(root) {
        root.innerHTML = template();
        const s = { mode: 'compare', stack: [], queue: [], message: 'กด push หลายครั้ง แล้วกด pop เพื่อดูว่าแต่ละโครงสร้างนำค่าใดออก', text: '', steps: [], step: 0 };
        const loadText = () => {
            s.text = root.querySelector('[name="text"]').value;
            s.steps = bracketSteps(s.text);
            s.step = 0;
        };
        root.addEventListener('click', (event) => {
            const act = event.target.dataset?.act;
            if (!act) return;
            if (act === 'next') s.step += 1;
            else if (act === 'back') s.step -= 1;
            else compareAction(root, s, act);
            render(root, s);
        });
        root.querySelector('[name="mode"]').addEventListener('change', (event) => {
            s.mode = event.target.value;
            render(root, s);
        });
        root.querySelector('[name="text"]').addEventListener('input', () => {
            loadText();
            render(root, s);
        });
        loadText();
        render(root, s);
    }

    return { bracketSteps, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="stack-queue"]').forEach(StackQueue.mount);
}
