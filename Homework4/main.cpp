#include <iostream>
#include <fstream>
#include <mutex>
#include <omp.h>

using namespace std;

int threadAmount; // количество потоков
int** matrix;     // исходная матрица
int matrixSize;   // размер исходной матрицы
bool *result;     // массив для вычисления результата
mutex locker;


void getCofactor(int** mat, int** temp, int p, int q, int n) {
    int i = 0, j = 0;

    for (int row = 0; row < n; row++)
        for (int col = 0; col < n; col++)
            if (row != p && col != q)
            {
                temp[i][j++] = mat[row][col];

                if (j == n - 1)
                {
                    j = 0;
                    i++;
                }
            }
}


int determinantOfMatrix(int** mat, int n) {
    int D = 0;

    if (n == 1)
        return mat[0][0];

    int** temp = new int*[n-1];
    for (int i = 0; i < n-1; ++i)
        temp[i] = new int[n-1];

    int sign = 1;

    for (int f = 0; f < n; f++)
    {
        getCofactor(mat, temp, 0, f, n);
        D += sign * mat[0][f]
             * determinantOfMatrix(temp, n - 1);
        sign = -sign;
    }

    return D;
}


int **minorWithSizeAndOffset(int **mat, int size, int offsetX, int offsetY) {
    int **minor = new int *[size];
    for (int i = 0; i < size; ++i)
        minor[i] = new int[size];

    for (int y = 0; y < size; ++y)
        for (int x = 0; x < size; ++x)
            minor[y][x] = mat[offsetY + y][offsetX + x];

    return minor;
}


void displayMatrix()
{
    for (int i = 0; i < matrixSize; i++)
    {
        for (int j = 0; j < matrixSize; j++)
            printf("  %d", matrix[i][j]);
        printf("\n");
    }
}


void readFromFile(const string& filePath) {
    ifstream inputFile(filePath);

    inputFile >> threadAmount >> matrixSize;

    if (threadAmount < 1 || matrixSize < 1 || matrixSize > 10)
        throw exception("Incorrect value for amount of threads or matrix size!");

    matrix = new int *[matrixSize];
    for (int i = 0; i < matrixSize; ++i)
        matrix[i] = new int[matrixSize];

    for (int y = 0; y < matrixSize; ++y)
        for (int x = 0; x < matrixSize; ++x)
            inputFile >> matrix[y][x];

    inputFile.close();
}


void work(int minorSize, int offsetX, int offsetY) {
    if (result[minorSize - 1] ||
        determinantOfMatrix(minorWithSizeAndOffset(matrix, minorSize, offsetX, offsetY),
                            minorSize) == 0)
        return;

    locker.lock();  // доступ к переменной result предоставляется одновременно лишь одному потоку
    result[minorSize - 1] = true;
    locker.unlock();
}


void calculateRank() {
    // Вычисляем определители всех миноров данной матрицы
#pragma omp parallel for schedule(dynamic) private(s)
    for (int s = 1; s <= matrixSize; ++s)
#pragma omp parallel for schedule(static) private(y)
            for (int y = 0; y <= matrixSize - s; ++y)
#pragma omp parallel for schedule(static) private(x)
                    for (int x = 0; x <= matrixSize - s; ++x)
                        work(s, x, y);
}


int main(int argc, char *argv[]) {
    try {
        readFromFile(argv[1] != nullptr ? argv[1] : "test5.txt"); // считываем файл
        displayMatrix();

        // Устанавливаем количество потоков
        omp_set_num_threads(threadAmount);
        result = new bool[matrixSize + 1]; // инициализируем массив
        for (int i = 0; i < matrixSize+1; ++i)
            result[i] = false;

        calculateRank(); // запускаем вычисление ранга на нескольких потоках

        // выводим результат в консоль
        for (int i = 0; i < matrixSize + 1; ++i)
            if (!result[i]) {
                cout << "\nRank of matrix = " << i << endl;
                break;
            }
    }
    catch (exception ex) {
        cout << ex.what() << endl;
    }
    return 0;
}

