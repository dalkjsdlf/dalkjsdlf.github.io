---
layout: single
title: "[실험실] #1 - JAVA Arrays.sort와 직접 구현한 quicksort 성능 측정 비교"
categories: 
 - Test
date: 2024-12-09 00:06:00 +0900
toc: true
toc_sticky: true
---
JAVA Arrays.sort와 직접 구현한 quicksort 성능 측정 비교

# 1. 궁금증

코딩테스트 문제를 풀다보면 정렬을 해야하는 경우가 많이 생기는데 그 때 마다 나는 Arrays.sort를 사용하곤 했다. 이렇게 제공된 정렬 알고리즘에 익숙하다 보니 다른 알고리즘과의 실제 성능차이가 궁금해졌다. 

버블정렬, 삽입정렬, 선택정렬, 퀵정렬, 힙정렬, 병합정렬, 트리정렬 등 여러 정렬이 있는데 이중에 퀵정렬과 자바의 정렬을 비교해 보았다. 

# 2. 시도

## 퀵정렬 구현
같은 자바 클래스에 퀵정렬을 아래와 같이 구현하였다.

{% include code-header.html %}
```java
// 퀵소트 메서드
    public static void quickSort(int[] arr, int low, int high) {
        if (low < high) {
            int pi = partition(arr, low, high);

            quickSort(arr, low, pi-1);  // 왼쪽 부분 배열 정렬
            quickSort(arr, pi+1, high); // 오른쪽 부분 배열 정렬
        }
    }

    // 배열을 분할하는 메서드
    public static int partition(int[] arr, int low, int high) {
        int pivot = arr[high];
        int i = (low-1); // 작은 요소의 인덱스

        for (int j = low; j < high; j++) {
            if (arr[j] <= pivot) {
                i++;

                // arr[i]와 arr[j] 교체
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }

        // arr[i+1]와 arr[high] (또는 pivot) 교체
        int temp = arr[i+1];
        arr[i+1] = arr[high];
        arr[high] = temp;

        return i+1;
    }
```

## 테스트 발생
테스트 대상인 배열은 뭔가 테스트 케이스를 두고 하고 싶었지만 우선 커다란 범위의 난수 상황에서 성능 상황을 지켜보고 싶어 난수를 배열의 개수만큼 생성하였다.
{% include code-header.html %}
```java
    public static int[] generateRandomArray(int size, int min, int max) {
        Random random = new Random();
        int[] array = new int[size];

        for (int i = 0; i < size; i++) {
            array[i] = random.nextInt((max - min) + 1) + min; // min부터 max 사이의 난수 생성
        }

        return array;
    }
```
# 3. 결과
최종적으로 main 함수에서 난수배열로 1~100,000까지의 숫자가 난수로 적용된 크기가 10만인 배열을 퀵정렬과 java의 Arrays.sort에 인자로 넣어 각각 수행하여 Milli 시간만큼의 시간 차이를 측정하여 결과 아래와 같이 나왔다.

## 퀵정렬과 Arrays.sort 비교 결과

{% include code-header.html %}
```java
=======================퀵정렬로 수행한 결과!============================
ElapsedTime : [8ms]
===================================================================

=======================Arrays.sort로 수행한 결과!=====================
ElapsedTime : [1ms]
===================================================================
```

좀 더 눈에 띄는 결과를 보기 위해서 배열 크기를 백만까지 늘려 보았다.
{% include code-header.html %}
```java
=======================퀵정렬로 수행한 결과!============================
ElapsedTime : [58ms]
===================================================================

=======================Arrays.sort로 수행한 결과!=====================
ElapsedTime : [2ms]
===================================================================
```

헉 이럴 수가 격차는 훠어씬 더 벌어졌다.

혹시 몰라 천만까지 …
{% include code-header.html %}
```java
=======================퀵정렬로 수행한 결과!============================
ElapsedTime : [566ms]
===================================================================

=======================Arrays.sort로 수행한 결과!=====================
ElapsedTime : [7ms]
===================================================================
```

위 결과는 여러번 수행 시도 하여도 거의 비슷한 결과가 나온다. 

## 오름차순, 내림차순 정렬한 뒤 재정렬
이번에는 동일한 크기(천만건)으로 초기 배열 값을 오름차순,내림차순으로 정렬한 뒤에 재 정렬을 수행시켜 보겠다. 

결과는 …!

1. 오름차순
{% include code-header.html %}
```java
======================퀵정렬로 수행한 결과!============================
StackOverflowError!
===================================================================

=======================Arrays.sort로 수행한 결과!=====================
ElapsedTime : [7ms]
===================================================================
```

1. 내림차순
2. {% include code-header.html %}
```java
======================퀵정렬로 수행한 결과!============================
ElapsedTime : [566ms]
===================================================================

=======================Arrays.sort로 수행한 결과!=====================
ElapsedTime : [11ms]
===================================================================
```