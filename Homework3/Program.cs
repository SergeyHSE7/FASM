using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace RangMatrix
{
    class Program
    {
        private static int threadAmount;  // количество потоков
        private static Matrix matrix;     // исходная матрица
        private static bool[] result;     // массив для вычисления результата
        public static Task[] tasks;       // массив потоков
        private static object locker = new object();  // объект-заглушка для блокировки доступа


        /// <summary>
        /// Метод, для считывания информации из файла
        /// </summary>
        /// <param name="filePath"> Путь до файла </param>
        static void ReadFromFile(string filePath)
        {
            int[,] array;

            using (StreamReader sr = new StreamReader(filePath))
            {
                threadAmount = int.Parse(sr.ReadLine());
                int size = int.Parse(sr.ReadLine());

                if (threadAmount < 1 || size < 1 || size > 10)
                    throw new ArgumentException("Число потоков и/или размер массива не подходят под ограничения!");

                array = new int[size, size];

                for (int y = 0; y < size; ++y)
                    for (int x = 0; x < size; ++x)
                        array[y, x] = int.Parse(sr.ReadLine());
            }
            matrix = new Matrix(array);
        }


        /// <summary>
        /// Точка входа в программу
        /// </summary>
        /// <param name="args"> Аргументы, передаваемые через консоль </param>
        static void Main(string[] args)
        {
            try
            {
                ReadFromFile(args.Length > 0 ? args[0] : "test1.txt"); // считываем файл
                result = new bool[matrix.size + 1]; // инициализируем массив
                result[0] = !matrix.IsZero(); // определяем, является ли матрица нулевой

                CalculateRang(matrix); // запускаем вычисление ранга на нескольких потоках

                // выводим результат в консоль
                for (int i = 0; i < result.Length; ++i)
                    if (!result[i])
                    {
                        Console.WriteLine("Ранг матрицы = " + i);
                        break;
                    }
            }
            catch (IOException io)
            {
                Console.WriteLine("Во время чтения из файла произошла ошибка, " +
                                  "убедитесь в исправности файла с тестовыми данными");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Во время выполнения произошла ошибка: " + ex.Message);
            }

            Console.WriteLine("\nНажмите любую клавишу для завершения программы...");
            Console.ReadKey(true);
        }


        /// <summary>
        /// Метод, который будут выполнять потоки
        /// </summary>
        /// <param name="minorSize"> Размер искомого минора </param>
        /// <param name="offsetX"> Смещение по горизонатали </param>
        /// <param name="offsetY"> Смещение по вертикали </param>
        static void Work(int minorSize, int offsetX, int offsetY)
        {
            if (result[minorSize - 1] ||
                Matrix.Determinant(Matrix.Minor(matrix.array, minorSize, offsetX, offsetY)) == 0)
                return;

            lock (locker)  // доступ к переменной result предоставляется одновременно лишь одному потоку
            {
                result[minorSize - 1] = true;
            }
        }

        /// <summary>
        /// Вычисляем ранг матрицы
        /// </summary>
        static void CalculateRang(Matrix matrix)
        {
            // инициализируем массив потоков
            tasks = new Task[threadAmount];    
            for (int i = 0; i < threadAmount; ++i)
                tasks[i] = Task.FromResult(0);

            // Вычисляем определители всех миноров данной матрицы
            for (int s = 2; s <= matrix.size; ++s)
                for (int y = 0; y <= matrix.size - s; ++y)
                    for (int x = 0; x <= matrix.size - s; ++x)
                    {
                        // создаём локальные копии изменяемых переменных
                        int _s = s, _x = x, _y = y; 

                        // запускаем выполнение метода на освободившемся потоке
                        tasks[Task.WaitAny(tasks)] = Task.Run(() => Work(_s, _x, _y));
                    }
            // дожидаемся выполнения всех потоков
            Task.WaitAll(tasks);    
        }
    }


    /// <summary>
    /// Класс матрицы
    /// </summary>
    public class Matrix
    {
        public readonly int[,] array;
        public int size => array.GetLength(0);
        public bool IsZero() => array.Cast<int>().All(value => value == 0);

        // конструктор
        public Matrix(int[,] array) => this.array = array;

        /// <summary>
        /// Вычисление определителя матрицы
        /// </summary>
        /// <param name="array"> матрица </param>
        /// <returns> Определитель матрицы </returns>
        public static int Determinant(int[,] array)
        {
            int n = (int)Math.Sqrt(array.Length);

            if (n == 1)
                return array[0, 0];

            int det = 0;

            for (int k = 0; k < n; k++)
                det += array[0, k] * Cofactor(array, 0, k);

            return det;
        }


        private static int Cofactor(int[,] array, int row, int column) =>
        (int)Math.Pow(-1, column + row) * Determinant(Minor(array, row, column));

        /// <summary>
        /// Нахождение минора матрицы указанного размера и со смещениями по горизонатали и вертикали
        /// </summary>
        /// <returns> Минор матрицы </returns>
        public static int[,] Minor(int[,] array, int minorSize, int offsetX, int offsetY)
        {
            int[,] minor = new int[minorSize, minorSize];

            for (int y = 0; y < minorSize; ++y)
                for (int x = 0; x < minorSize; ++x)
                    minor[y, x] = array[offsetY + y, offsetX + x];

            return minor;
        }

        /// <summary>
        /// Нахождение минора матрицы за вычетом указанных столбца и ряда
        /// </summary>
        /// <returns> Минор матрицы </returns>
        private static int[,] Minor(int[,] array, int row, int column)
        {
            int n = (int)Math.Sqrt(array.Length);
            int[,] minor = new int[n - 1, n - 1];

            int _i = 0;
            for (int i = 0; i < n; i++)
            {
                if (i == row) continue;

                int _j = 0;
                for (int j = 0; j < n; j++)
                {
                    if (j == column) continue;

                    minor[_i, _j] = array[i, j];
                    _j++;
                }
                _i++;
            }
            return minor;
        }
    }
}
