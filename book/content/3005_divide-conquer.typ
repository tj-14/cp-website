#import "@preview/ilm:1.4.0": *

== Divide & Conquer

=== หลักการ

- ประกอบด้วยขั้นตอนหลักสามขั้นตอน
    - Divide แบ่งปัญหาให้เป็นปัญหาเดียวกันที่ขนาดเล็กลง
    - Conquer แก้ปัญหาย่อยๆ ให้ได้
    - Combine
    รวบรวมคำตอบของปัญหาย่อยที่ถูกแก้แล้วมารวมกันเพื่อแก้ปัญหาเดิมที่ใหญ่กว่า
- ปัญหาที่ยังสามารถย่อยต่อเพื่อแก้ปัญหาได้เรียกว่า recursive case
- ปัญหาที่ขนาดเล็กเพียงพอที่จะแก้ปัญหาได้โดยไม่ต้องย่อยต่อเรียกว่า base case
- ปัญหาส่วนใหญ่จะใช้เวลา $O(N^? log N )$ โดย $log N $
มาจากการแบ่งปัญหาเป็นครึ่ง ๆ ไปเรื่อย ๆ

==== General Pseudocode

```
DAC(p):
    if is_base_case(p):
        solve(p)
    else:
        divide p into p_1, p_2, ..., p_k
        apply DAC(p_1), DAC(p_2), ..., DAC(p_k)
        combine(DAC(p_1), DAC(p_2), ..., DAC(p_k))
```

=== Binary Search

การหาจำนวน (หรือคำตอบที่ต้องการ) ในอาเรย์ที่มีการเรียงแล้ว
โดยตัวอัลกอริธึมจะตรวจสอบกับตัวเลขตรงกลาง
ก่อนที่จะแบ่งอาร์เรย์ออกเป็นสองฝั่งเพื่อหาตัวเลขนั้นอีกครั้ง
หากตัวเลขที่กำลังหาอยู่มากกว่าตัวเลขตรงกลาง
ก็จะไปหาจำนวนนั้นในอาร์เรย์ฝั่งขวา
แต่ถ้าหากตัวเลขที่กำลังหาอยู่น้อยกว่าตัวเลขตรงกลาง
ก็จะไปหาจำนวนนั้นในอาร์เรย์ฝั่งซ้าย

==== Pattern

```cpp
int lo = 0, hi = N;
while (lo <= hi) {
  int mi = (lo + hi) / 2; // ระวัง overflow ตอน lo+hi
  if (A[mi] > target) {
    hi = mi - 1;
  } else {
    lo = mi + 1;
  }
}
```

==== STL

- upper_bound
- lower_bound

==== Binary Search คำตอบ

- ปัญหาบางอย่างสามารถสมมุติคำตอบแล้ว check ได้เร็ว
- หากคำตอบมี pattern เช่น ถ้าค่าน้อยสามารถทำได้แล้วค่าที่มากกว่าจะทำได้ด้วยเสมอ ก็จะสามารถ binary search ได้

=== More on Binary Search

- สอน Binary Search ฉบับสมบูรณ์โคตรๆ (aquablitz11) #footnote[https://aquablitz11.github.io/2019/04/12/complete-bsearch-tutorial.html]
- https://csacademy.com/lesson/binary_search/

=== Closest Pair

https://www.geeksforgeeks.org/closest-pair-of-points-using-divide-and-conquer-algorithm/

=== ปัญหาเลขยกกำลัง

พิจารณาวิธีหาค่าของ $A^N$ หากทำการคูณเลขตรงๆ จะเป็น $O(N)$

ถ้าเราแบ่ง

- Recursive case
    - $A^N = A^{N/2} \cdot A^{N/2} " เมื่อ " N mod 2 = 0$
    - $A^N = A^{\lfloor N/2 \rfloor} \cdot A^{\lfloor N/2 \rfloor} " เมื่อ " N mod 2 = 1$
- Base case
    - $A^N = A " เมื่อ " N = 1$
    - $A^N = 1 " เมื่อ " N = 0$

=== จำนวน Fibonacci

จำนวนฟิโบนัชชี (เขียนแทนว่า $F_n$)
คือลำดับจำนวนที่ถูกนิยามจากผลบวกของจำนวนฟิโบนัชชีสองตัวก่อนหน้า
โดยกำหนดให้จำนวนฟิโบนัชชีสองตัวแรกเป็น 0 และ 1 ตามลำดับ นั่นคือ 

$ F_i = cases(
1 "if" i = 1,
F_(i-1) + F_(i-2) "else",
)
$

โดยจะสามารถเขียนลำดับได้เป็น 

$0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...$ 

เพราะฉะนั้นแล้ว base case ก็คือ $0 <= i <= 1$ และ recursive
case ก็คือ $i >= 2$

=== Merge Sort

```cpp
void merge(int array[], int const left, int const mid, int const right) {
  auto const subArrayOne = mid - left + 1;
  auto const subArrayTwo = right - mid;

  // Create temp arrays
  auto *leftArray = new int[subArrayOne], *rightArray = new int[subArrayTwo];

  // Copy data to temp arrays leftArray[] and rightArray[]
  for (auto i = 0; i < subArrayOne; i++)
    leftArray[i] = array[left + i];
  for (auto j = 0; j < subArrayTwo; j++)
    rightArray[j] = array[mid + 1 + j];

  auto indexOfSubArrayOne = 0,   // Initial index of first sub-array
      indexOfSubArrayTwo = 0;    // Initial index of second sub-array
  int indexOfMergedArray = left; // Initial index of merged array

  // Merge the temp arrays back into array[left..right]
  while (indexOfSubArrayOne < subArrayOne && indexOfSubArrayTwo < subArrayTwo) {
    if (leftArray[indexOfSubArrayOne] <= rightArray[indexOfSubArrayTwo]) {
      array[indexOfMergedArray] = leftArray[indexOfSubArrayOne];
      indexOfSubArrayOne++;
    } else {
      array[indexOfMergedArray] = rightArray[indexOfSubArrayTwo];
      indexOfSubArrayTwo++;
    }
    indexOfMergedArray++;
  }
  // Copy the remaining elements of
  // left[], if there are any
  while (indexOfSubArrayOne < subArrayOne) {
    array[indexOfMergedArray] = leftArray[indexOfSubArrayOne];
    indexOfSubArrayOne++;
    indexOfMergedArray++;
  }
  // Copy the remaining elements of
  // right[], if there are any
  while (indexOfSubArrayTwo < subArrayTwo) {
    array[indexOfMergedArray] = rightArray[indexOfSubArrayTwo];
    indexOfSubArrayTwo++;
    indexOfMergedArray++;
  }
}
```

=== Square Root Decomposition

- https://usaco.guide/plat/sqrt?lang=cpp
- https://cp-algorithms.com/data_structures/sqrt_decomposition.html
