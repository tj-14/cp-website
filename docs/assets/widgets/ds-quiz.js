// Review quiz: pick the data structure that fits each scenario.
const DsQuiz = (() => {
    const QUESTIONS = [
        {
            q: 'ตรวจว่าข้อความ {[()]} มีวงเล็บเปิด-ปิดถูกต้องหรือไม่',
            options: ['queue', 'stack', 'set', 'priority_queue'],
            answer: 1,
            why: 'วงเล็บปิดต้องคู่กับวงเล็บเปิด "ล่าสุด" ที่ยังไม่ถูกปิด ซึ่งคือ LIFO',
        },
        {
            q: 'จำลองแถวรับบริการ ใครมาก่อนได้รับบริการก่อน',
            options: ['stack', 'queue', 'map', 'vector ที่ sort แล้ว'],
            answer: 1,
            why: 'มาก่อนออกก่อนคือ FIFO',
        },
        {
            q: 'มีงานเข้ามาเรื่อย ๆ และทุกครั้งต้องดึงงานที่ priority สูงที่สุดออกมาทำ',
            options: ['queue', 'vector', 'priority_queue', 'stack'],
            answer: 2,
            why: 'heap ให้ push และ pop ค่ามากสุดใน O(log n)',
        },
        {
            q: 'อ่านตัวเลข 10^6 ตัว และต้องตอบทันทีว่าตัวเลขนี้เคยเห็นแล้วหรือยัง (ไม่สนลำดับ)',
            options: ['unordered_set', 'vector', 'stack', 'deque'],
            answer: 0,
            why: 'hash table ตรวจสมาชิกได้เฉลี่ย O(1) (set ก็ใช้ได้ที่ O(log n)) แต่ vector ต้องไล่ O(n)',
        },
        {
            q: 'เพิ่มและลบตัวเลขได้ตลอด และต้องหา "ค่าแรกที่ ≥ x" บ่อย ๆ',
            options: ['unordered_set', 'set', 'queue', 'priority_queue'],
            answer: 1,
            why: 'set เก็บเรียงลำดับ จึงมี lower_bound ใน O(log n) ส่วน unordered_set ไม่เรียงลำดับ',
        },
        {
            q: 'นับว่าแต่ละคำปรากฏกี่ครั้ง แล้วพิมพ์ผลเรียงตามตัวอักษร',
            options: ['vector<string>', 'map<string, int>', 'stack<string>', 'priority_queue<string>'],
            answer: 1,
            why: 'map จับคู่คำกับจำนวน และวนผลลัพธ์เรียงตาม key ให้อยู่แล้ว',
        },
        {
            q: 'เพิ่มข้อมูลต่อท้ายเรื่อย ๆ และต้องเข้าถึงตัวที่ i ได้ทันที',
            options: ['linked list', 'vector', 'set', 'queue'],
            answer: 1,
            why: 'vector เข้าถึง v[i] ใน O(1) และ push_back เฉลี่ย O(1)',
        },
        {
            q: 'ต้องเพิ่มและลบข้อมูลได้ทั้งหัวและท้ายใน O(1)',
            options: ['vector', 'stack', 'deque', 'set'],
            answer: 2,
            why: 'deque รองรับ push/pop ทั้ง front และ back',
        },
        {
            q: 'หาจำนวนก้าวน้อยที่สุดในเขาวงกต (ทุกก้าวเท่ากัน) ด้วย BFS',
            options: ['stack', 'queue', 'map', 'set'],
            answer: 1,
            why: 'BFS ใช้ queue เพื่อเยี่ยมตามระยะทางจากจุดเริ่ม',
        },
        {
            q: 'ใน array ที่ไม่มีการแก้ค่า ต้องตอบผลรวมช่วง [l, r] เป็นแสนครั้ง',
            options: ['prefix sum array', 'set', 'priority_queue', 'วน loop ทุกครั้ง'],
            answer: 0,
            why: 'prefix sum ตอบได้ใน O(1) ต่อคำถาม: pref[r] - pref[l-1]',
        },
    ];

    function render(root, s) {
        const box = root.querySelector('.qz-body');
        if (s.i >= QUESTIONS.length) {
            box.innerHTML = `<p class="qz-q">ได้ ${s.score}/${QUESTIONS.length} คะแนน</p>
                <p>${s.score === QUESTIONS.length ? 'ยอดเยี่ยม! พร้อมไปบท Algorithms แล้ว' : 'ลองทบทวนบทของข้อที่ตอบผิด แล้วทำใหม่อีกครั้ง'}</p>
                <div class="widget-controls"><button type="button" data-act="restart">ทำใหม่</button></div>`;
            return;
        }
        const item = QUESTIONS[s.i];
        const buttons = item.options.map((o, k) => {
            let cls = '';
            if (s.picked !== null) {
                if (k === item.answer) cls = 'is-right';
                else if (k === s.picked) cls = 'is-wrong';
            }
            return `<button type="button" class="qz-option ${cls}" data-option="${k}" ${s.picked !== null ? 'disabled' : ''}>${o}</button>`;
        }).join('');
        const feedback = s.picked === null ? '' : `<p class="widget-explain">${s.picked === item.answer ? '✓ ถูกต้อง' : `✗ คำตอบคือ ${item.options[item.answer]}`} - ${item.why}</p>
            <div class="widget-controls"><button type="button" data-act="next">${s.i + 1 < QUESTIONS.length ? 'ข้อถัดไป →' : 'ดูคะแนน'}</button></div>`;
        box.innerHTML = `<p class="widget-summary">ข้อ ${s.i + 1}/${QUESTIONS.length} - คะแนน ${s.score}</p>
            <p class="qz-q">${item.q}</p>
            <div class="qz-options">${buttons}</div>
            <div aria-live="polite">${feedback}</div>`;
    }

    function mount(root) {
        root.innerHTML = '<div class="qz-body"></div>';
        const s = { i: 0, score: 0, picked: null };
        root.addEventListener('click', (event) => {
            const t = event.target;
            if (t.dataset.option !== undefined && s.picked === null) {
                s.picked = Number(t.dataset.option);
                if (s.picked === QUESTIONS[s.i].answer) s.score += 1;
                render(root, s);
                root.querySelector('[data-act="next"]')?.focus();
            } else if (t.dataset.act === 'next') {
                s.i += 1;
                s.picked = null;
                render(root, s);
                root.querySelector('.qz-option, [data-act="restart"]')?.focus();
            } else if (t.dataset.act === 'restart') {
                Object.assign(s, { i: 0, score: 0, picked: null });
                render(root, s);
            }
        });
        render(root, s);
    }

    return { QUESTIONS, mount };
})();

if (typeof document !== 'undefined') {
    document.querySelectorAll('[data-widget="ds-quiz"]').forEach(DsQuiz.mount);
}
