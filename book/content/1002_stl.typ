#import "@preview/ilm:1.4.0": *

== STL library ที่ใช้บ่อย

=== Max/Min

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  cout << max(2, 4); // 4
  cout << min(2, 4); // 2
  return 0;
}
```

=== Sort 

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  int a[] = {3, 1, 2};
  cout << a[0] << " " << a[1] << " " << a[2] << "\n"; // 3 1 2
  sort(a, a+3);
  cout << a[0] << " " << a[1] << " " << a[2] << "\n"; // 1 2 3
  return 0;
}
```

=== Vector

- เป็น dynamic array (array ที่สามารถเพิ่มลดขนาดได้)
- `vector` มีการใช้งานโดยใช้ `vector<T> varName;` เช่น `vector<int> A;`

==== Access

- `A[i]` ได้เหมือน array
- `A.front()` และ `A.back()`

==== Functions

- `A.size()` เช็คขนาดของ vector
- `A.empty()` เช็คว่า vector ว่างหรือไม่
- `A.push_back(10)` ไว้เพิ่มสมาชิกต่อท้าย
- `A.pop_back()` ไว้ลบสมาชิกตัวสุดท้าย

==== Loop

```cpp
for (int i = 0; i < A.size(); i++)
  cout << A[i] << endl;
```

==== Example

```cpp
#include <bits/stdc++.h>

using namespace std;

void printVec(vector<int> v) {
  for (int i = 0; i < v.size(); i++) {
    cout << v[i] << " ";
  }
  cout << "\n";
}

int main() {
  vector<int> A;
  A.push_back(2);
  A.push_back(5);
  printVec(A); // OUTPUT: 2 5 \n

  A.push_back(9);
  printVec(A); // OUTPUT: 2 5 9 \n

  cout << A.front() << "\n"; // OUTPUT: 2\n
  cout << A.back() << "\n";  // OUTPUT: 9\n
  cout << A.size() << "\n";  // OUTPUT: 3\n

  A.pop_back();
  A.pop_back();
  printVec(A); // OUTPUT: 2 \n
}
```

=== Pair

- เป็น struct สำเร็จรูปที่มีสมาชิกสองตัว
- `pair<T1, T2> varName;` เช่น `pair<int, double> A;`

==== Access

- `A.first` และ `A.second`

==== Example

```cpp
#include <bits/stdc++.h>

using namespace std;

int main() {
  pair<int, double> A;
  A.first = 4;
  A.second = 7.5;
  cout << A.first << "\n";  // OUTPUT: 4
  cout << A.second << "\n"; // OUTPUT: 7.5
  A = pair<int, double>(6, 2.3);
  cout << A.first << "\n";  // OUTPUT: 6
  cout << A.second << "\n"; // OUTPUT: 2.3
}
```
