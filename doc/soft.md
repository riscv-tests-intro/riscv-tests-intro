# Установка необходимого ПО

- [Установка необходимого ПО](#установка-необходимого-по)
  - [Перед установкой](#перед-установкой)
  - [Общие зависимости](#общие-зависимости)
  - [Генератор случайных инструкций RISC-V AAPG `2d7d40f`](#генератор-случайных-инструкций-risc-v-aapg-2d7d40f)
  - [ПО riscv-gnu-toolchain `6d7b5b7`](#по-riscv-gnu-toolchain-6d7b5b7)
  - [Программная модель RISC-V Spike ISS `887d02e`](#программная-модель-risc-v-spike-iss-887d02e)
  - [Verilator 5.024 `522bead`](#verilator-5024-522bead)
  - [GTKWave](#gtkwave)
  - [Завершение установки](#завершение-установки)


## Перед установкой

Установка разбита на шаги. Если какое-то ПО из списка уже установлено на вашей машине, то можно попробовать пропустить его установку. Однако, **если версия ПО не совпадает c указанной в заголовке, то автор не гарантирует его корректной работы в рамках данного курса.**

Подразумевается, что репозиторий склонирован способом, который указан в разделе [работа с репозиторием](../README.md/#работа-с-репозиторием) основого README, а также что вы на каждом этапе находитесь в корневой директории `riscv-tests-basic`.


## Общие зависимости

Устанавливаем общие зависимости:

```bash
sudo apt-get install git make gcc g++ clang python3 \
python3-pip libyaml-dev libpython2.7-dev -y
sudo pip install pathlib3x typeguard typing_utils \
pybind11 meson==1.8.1
```

Определяем директорию установки:

```bash
export INSTALL_DIR=/usr/bin
```

## Генератор случайных инструкций RISC-V AAPG `2d7d40f`

Переходим в директорию и устанавливаем:

```bash
cd submodules/aapg-miriscv
sudo python3 setup.py install
sudo python3 setup.py install
```

Да, `setup.py` действительно нужно выполнить дважды.

## ПО riscv-gnu-toolchain `6d7b5b7`

Переходим в директорию и устанавливаем зависимости:

```bash
cd submodules/riscv-gnu-toolchain
sudo apt-get install autoconf automake autotools-dev curl \
python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk \
build-essential bison flex texinfo gperf libtool patchutils bc \
zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev \
libslirp-dev -y
```

Создаем директорию сборки и переходим в нее:

```bash
mkdir build
cd build
```

Конфигурируем:

```
../configure --prefix=$INSTALL_DIR/riscv-gnu-toolchain \
--with-arch=rv32im_zicsr --with-abi=ilp32
```

Собираем и устанавливаем (в зависимости от мощности машины время сборки ~5-30 мин):

```bash
sudo make -j $(nproc)
```

Добавляем в PATH для всех рользователей:

```bash
echo "PATH=$INSTALL_DIR/riscv-gnu-toolchain/bin"':$PATH' | sudo tee -a /etc/profile
source /etc/profile
```

**или** текущего:

```bash
echo "PATH=$INSTALL_DIR/riscv-gnu-toolchain/bin"':$PATH' >> ~/.profile
source ~/.profile
```

## Программная модель RISC-V Spike ISS `887d02e`

Переходим в директорию и устанавливаем зависимости:

```bash
cd submodules/riscv-isa-sim
sudo apt-get install device-tree-compiler -y
```

Создаем директорию сборки и переходим в нее:

```bash
mkdir build
cd build
```

Конфигурируем:

```bash
../configure --without-boost --without-boost-asio --without-boost-regex --prefix=$INSTALL_DIR/spike
```

Собираем:

```bash
sudo make -j $(nproc)
```

Устанавливаем: 

```bash
sudo make install
```

Добавляем в PATH для всех рользователей:

```bash
echo "PATH=$INSTALL_DIR/spike/bin"':$PATH' | sudo tee -a /etc/profile
source /etc/profile
```

**или** текущего:

```bash
echo "PATH=$INSTALL_DIR/spike/bin"':$PATH' >> ~/.profile
source ~/.profile
```

## Verilator 5.024 `522bead`

Переходим в директорию и устанавливаем зависимости:

```bash
cd submodules/verilator
sudo apt-get install git help2man perl python3 make autoconf \
g++ flex bison ccache -y
sudo apt-get install libgoogle-perftools-dev numactl perl-doc -y
sudo apt-get install libfl2  -y # Ignore if gives error
sudo apt-get install libfl-dev  -y # Ignore if gives error
sudo apt-get install zlibc zlib1g zlib1g-dev  -y # Ignore if gives error
```

Конфигурируем:

```bash
autoconf
./configure --prefix=$INSTALL_DIR/verilator
```

Собираем:

```bash
sudo make -j $(nproc)
```

Устанавливаем:

```
sudo make install
```

Добавляем в PATH для всех рользователей:

```bash
echo "PATH=$INSTALL_DIR/verilator/bin"':$PATH' | sudo tee -a /etc/profile
source /etc/profile
```

**или** текущего:

```bash
echo "PATH=$INSTALL_DIR/verilator/bin"':$PATH' >> ~/.profile
source ~/.profile
```

## GTKWave

Устанавливаем


```
sudo apt-get install gtkwave -y
```

## Завершение установки

После завершения установки необходимо перезапустить машину.
