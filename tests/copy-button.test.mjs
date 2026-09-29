import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../scripts/build_docs.py', import.meta.url), 'utf8');
const script = source.match(/COPY_BUTTON_SCRIPT = """\s*<script>([\s\S]*?)<\/script>/)[1];

test('copying twice preserves only the code, including whitespace', async () => {
    const code = 'int main() {\n    return 0;\n}\n';
    const copied = [];
    let click;
    let button;
    const pre = {
        querySelector: () => ({ textContent: code }),
        get innerText() { return code + (button?.textContent ?? ''); },
        appendChild: (child) => { button = child; },
    };
    runInNewContext(script, {
        document: {
            querySelectorAll: () => [pre],
            createElement: () => ({ addEventListener: (_, handler) => { click = handler; } }),
        },
        navigator: { clipboard: { writeText: async (value) => { copied.push(value); } } },
        setTimeout: () => {},
    });
    await click();
    await click();
    assert.deepEqual(copied, [code, code]);
});
