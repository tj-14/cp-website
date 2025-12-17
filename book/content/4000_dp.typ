#import "@preview/ilm:1.4.0": *

= Anon's Guide to DP

== Improving from Divide & Conquer - Memoization

ลองพิจารณาถึงการคำนวณ Fibonacci Number ที่เราได้พูดคุยไปในบท \# Divide Conquer
ถ้าเรานำเอา Divide Conquer มาใช้จะต้องใช้เวลามากถึง // $\mathcal{O}(\varphi^n)$ 

สำหรับการหาจำนวนฟิโบนัชชีลำดับที่ $n$ ซึ่งเป็นรูปแบบการเติบโตแบบ exponential เลยทีเดียว! แล้วเราจะทำอะไรได้เพื่อลดเวลาที่ต้องใช้ในการคำนวณ?

ถ้าเราวาดแผนผังต้นไม้ในการหาจำนวนฟิโบนัชชีลำดับที่ $n$ จะเห็นว่ามีการเรียกฟังก์ชันซ้ำค่อนข้างมาก เช่น $"Fib"(3)$ ที่ถูกเรียกถึง 5 ครั้ง ลองจินตนาการดูว่าถ้าเราจะหา $"Fib"(100)$ จะต้องเรียกฟังก์ชันซ้ำมากขนาดไหน

ถ้าเรา *จำ* $"Fib"(i)$ ที่เคยคำนวณไว้ในอาร์เรย์หนึ่ง โดยให้เก็บค่าของ $"Fib"(i)$ และเรียกค่าจากที่เก็บมาได้ โค้ดจะมีลักษณะดังนี้:

```cpp
vector<int> v(n, -1);
int fib(int i) {
    if(v[i] > -1) return v[i];
    if(i == 0 || i == 1) {
        v[i] = i;
        return v[i];
    }
    v[i] = fib(i-1) + fib(i-2);
    return v[i];
}
```

การใช้เทคนิคนี้เรียกว่า memoization โดยมาจากการเก็บค่าไว้ใน memo หรือโน้ตเตือนความจำนั่นเอง

== Definition of Dynamic Programming

Dynamic Programming (หรือ DP) ก็คือการทำ Divide & Conquer โดยนำเอา memoization มาช่วยบูสต์ให้สามารถคำนวณผลเฉลยโดยพิจารณาจาก state ก่อนหน้าหรือ state ที่เล็กกว่า ทำให้ปัญหานั้นสามารถแก้ได้ภายในเวลา Polynomial Time

DP นั้นเหมาะกับการแก้ปัญหา Optimization หรือการหาค่าที่ดีที่สุด เช่น ราคาถูกที่สุด ยาวที่สุด ได้กำไรมากที่สุด ใช้เวลาน้อยที่สุด โดยปัญหาที่ใช้ DP แก้ได้จะต้องมีองค์ประกอบ 2 อย่างด้วยกัน

== Optimal Substructure

ปัญหาที่จะใช้ DP นั้นจะมี Optimal Substructure หรือโครงสร้างย่อยที่ดีที่สุด ก็ต่อเมื่อคำตอบที่ดีที่สุดของปัญหาใด ๆ สามารถหาได้จากการนำคำตอบที่ดีที่สุดของปัญหาย่อย ๆ มาผ่านขั้นตอนการคำนวณที่วางไว้

== Overlapping Subproblem

ปัญหาที่จะใช้ DP นั้นจะมี Overlapping Subproblem หรือปัญหาย่อยที่ซ้อนเหลื่อมกัน ก็ต่อเมื่อปัญหานั้นสามารถแบ่งเป็นปัญหาย่อย ๆ ที่ถูกใช้ซ้ำหลาย ๆ ครั้ง

== Framework for Recursive Algorithm - SRTBOT
	•	SUBPROBLEM definition: การนิยามปัญหาย่อย
	•	RELATE subproblems to solutions recursively: หาความสัมพันธ์แบบเวียนเกิดในการหาคำตอบของปัญหาย่อย
	•	TOPOLOGICAL order on subproblem to guarantee acyclicness: ลำดับในการแก้ปัญหาจากปัญหาที่ควรแก้ก่อนเพื่อป้องกัน infinite loop
	•	BASE case of relation: กำหนดขั้นฐานของความสัมพันธ์เวียนเกิด
	•	ORIGINAL problem: solve via subproblems: กำหนดปัญหาเดิมที่สามารถหาคำตอบได้ผ่านปัญหาย่อย
	•	TIME analysis: วิเคราะห์เวลาที่ต้องใช้ (ส่วนใหญ่ผ่าน Master Theorem)

== Top-Down & Bottom-up Approach to Dynamic Programming

เมื่อนำ DP มาเขียนโค้ด จะเห็นว่าเราสามารถพิจารณาขั้นตอนการแก้ปัญหาได้ 2 แบบ คือ Top-Down (บนลงล่าง) และ Bottom-up (ล่างขึ้นบน) โดยด้านบนมักจะเป็นปัญหาที่ใหญ่กว่าด้านล่าง

== Top-Down

vector<int> v(n, -1);
int fib(int i) {
    if(v[i] > -1) return v[i];
    if(i == 0 || i == 1) {
        v[i] = i;
        return v[i];
    }
    v[i] = fib(i-1) + fib(i-2);
    return v[i];
}

วิธีคิดแบบ Top-Down นั้นจะพิจารณาหาคำตอบของ Original Case โดยแบ่งไปหาให้ค่อย ๆ เล็กลงจนถึง Base Case แล้วนำมาแก้ปัญหา

== Bottom-up

vector<int> v(n, -1);
int fib(int i) {
    for(int j = 0; j < i; j++) {
        if(j == 0 || j == 1) {
            v[j] = j;
        }
        else v[j] = fib(j-1) + fib(j-2);
    }
    return v[i];
}

วิธีคิดแบบ Bottom-up จะเริ่มวนลูปจาก Base Case ไปยัง Original Case โดยค่อย ๆ สร้างคำตอบของปัญหาให้ใหญ่ขึ้นเรื่อย ๆ จนสามารถแก้ปัญหาเดิมได้ในที่สุด
