#include <bits/stdc++.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
using namespace std;
const int maxn = 1000000; // Ԫ��ֵ���� - һ����
const int maxl = 1000000; // ���鳤 - һ����
int* h_a, * h_b, * h_sum, * h_cpusum, tot = 0; // ����ָ��
clock_t pro_start, pro_end, sum_start, sum_end; // CPU ʱ�Ӽ���
cudaEvent_t e_start, e_stop; // CUDA ���ܲ��Ե�
__global__ void numAdd(int* a, int* b, int* sum) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    sum[i] = a[i] + b[i];
}
extern "C" int test_1() {
    srand(time(0)); // �趨���������
    h_a = new int[maxl], h_b = new int[maxl], h_sum = new int[maxl], h_cpusum = new int[maxl]; // ��̬�����ڴ�
    pro_start = clock();
    for (int i = 0; i < maxl; ++i) {
        h_a[i] = rand() % maxn; h_b[i] = rand() % maxn; // ��ʼ���������
    }
    pro_end = clock();
    // ��� ��������� ��ʱ ������ CUDA ���޷����������ĳ�ʼ�����첻���жԱȣ�
    printf("produce %d random number to two array use time : %0.3f ms\n", maxl, double(pro_end - pro_start) / CLOCKS_PER_SEC * 1000);
    system("pause");
    int* d_a, * d_b, * d_sum;
    cudaEventCreate(&e_start); cudaEventCreate(&e_stop); // ���� CUDA �¼�
    cudaEventRecord(e_start, 0); // ��¼ CUDA �¼�
    // ���Դ��Ϸ��䵥Ԫ
    cudaMalloc((void**)&d_a, sizeof(int) * maxl);
    cudaMalloc((void**)&d_b, sizeof(int) * maxl);
    cudaMalloc((void**)&d_sum, sizeof(int) * maxl);
    /*printf("memory allocated!\n");*/
    // �����ڴ����ݵ��Դ�
    cudaMemcpy(d_a, h_a, sizeof(int) * maxl, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, sizeof(int) * maxl, cudaMemcpyHostToDevice);
    /*printf("copy finished!\n");*/
    numAdd << <1000, 1000 >> > (d_a, d_b, d_sum); // ���� Kernel �������������ִ�д���
    cudaDeviceSynchronize(); // ͬ��GPU�ϵ������̣߳��ȴ������߳̽������ټ���
    /*printf("sum finished!\ncopy backing...\n");*/
    cudaMemcpy(h_sum, d_sum, sizeof(int) * maxl, cudaMemcpyDeviceToHost); // ���Դ濽��������ݵ��ڴ�
    /*printf("copy backed!\n");*/
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_sum); // �ͷ�GPU�Ϸ�����Դ�
    /*printf("device RAM released!\n");*/
    cudaEventRecord(e_stop, 0); cudaEventSynchronize(e_stop); // ��¼��ʱ
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, e_start, e_stop);
    printf("CUDA sum use time : %0.3f ms\n", elapsedTime);
    sum_start = clock();
    for (int i = 0; i < maxl; ++i) h_cpusum[i] = h_a[i] + h_b[i]; // CPU ���мӷ�����
    sum_end = clock();
    printf("CPU  sum use time : %0.3f ms\n", double(pro_end - pro_start) / CLOCKS_PER_SEC * 1000);
    for (int i = 0; i < maxl; ++i) if (h_cpusum[i] != h_sum[i]) ++tot; // ���� CPU ������ �� GPU �������Ƿ�һ�£�ͳ�Ʋ�һ�¸���
    printf("error sum num : %d\n", tot);
    system("pause");
    delete h_a; delete h_b; delete h_sum; // �ͷ��ڴ�
    return 0;
}