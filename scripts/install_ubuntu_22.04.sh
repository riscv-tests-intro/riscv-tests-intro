#-----------------------------------------------------------------
# Get arguments
#-----------------------------------------------------------------

while getopts d: flag
do
    case "${flag}" in
        d) INSTALL_DIR=${OPTARG};;
        ?)
          echo "script usage: $(basename \$0) [-d install-directory]" >&2
          exit 1
          ;;
    esac
done


#-----------------------------------------------------------------
# Common
#-----------------------------------------------------------------

sudo apt-get install git make gcc g++ clang python3 \
python3-pip libyaml-dev libpython2.7-dev -y
sudo pip install pathlib3x typeguard typing_utils \
pybind11 meson==1.8.1


#-----------------------------------------------------------------
# Go to the repository root
#-----------------------------------------------------------------

cd ..


#-----------------------------------------------------------------
# AAPG
#-----------------------------------------------------------------

# Go to the neccessary repo

cd submodules/aapg-miriscv

# Install (2 times)

sudo python3 setup.py install
sudo python3 setup.py install

# Go back

cd ../..


#-----------------------------------------------------------------
# riscv-gnu-toolchain
#-----------------------------------------------------------------

# Go to the neccessary repo

cd submodules/riscv-gnu-toolchain

# Install prerequisites

sudo apt-get install autoconf automake autotools-dev curl \
python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk \
build-essential bison flex texinfo gperf libtool patchutils bc \
zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev \
libslirp-dev -y

# Create build directory

mkdir build
cd build

# Configure

../configure --prefix=$INSTALL_DIR/riscv-gnu-toolchain \
--with-arch=rv32i_zicsr --with-abi=ilp32

# Build and install

sudo make -j $(nproc)

# Add to PATH

echo "PATH=$INSTALL_DIR/riscv-gnu-toolchain/bin"':$PATH' | sudo tee -a /etc/profile
source /etc/profile

# Go back

cd ..

# Remove build

sudo rm -rf build
mkdir build
cd build

# Configure for 64 bit

../configure --prefix=$INSTALL_DIR/riscv-gnu-toolchain-64 \
--with-arch=rv64gcv_zicsr --with-abi=lp64d

# Build and install

sudo make -j $(nproc)

# Add to PATH

echo "PATH=$INSTALL_DIR/riscv-gnu-toolchain-64/bin"':$PATH' | sudo tee -a /etc/profile
source /etc/profile

# Go back

cd ../../..


#-----------------------------------------------------------------
# Spike ISS
#-----------------------------------------------------------------

# Go to the neccessary repo

cd submodules/riscv-isa-sim

# Install prerequisites

sudo apt-get install device-tree-compiler -y

# Create build directory

mkdir build
cd build

# Configure

../configure --without-boost --without-boost-asio --without-boost-regex --prefix=$INSTALL_DIR/spike

# Build

sudo make -j $(nproc)

# Install

sudo make install

# Add to PATH

echo "PATH=$INSTALL_DIR/spike/bin"':$PATH'| sudo tee -a /etc/profile
source /etc/profile

# Go back

cd ../../..


#-----------------------------------------------------------------
# Verilator
#-----------------------------------------------------------------

# Go to the neccessary repo

cd submodules/verilator

# Install prerequisites

sudo apt-get install git help2man perl python3 make autoconf \
g++ flex bison ccache -y
sudo apt-get install libgoogle-perftools-dev numactl perl-doc -y
sudo apt-get install libfl2 -y  # Ignore if gives error
sudo apt-get install libfl-dev -y  # Ignore if gives error
sudo apt-get install zlibc zlib1g zlib1g-dev -y  # Ignore if gives error

# Configure

autoconf
./configure --prefix=$INSTALL_DIR/verilator

# Build

sudo make -j $(nproc)

# Install

sudo make install

# Add to PATH

echo "PATH=$INSTALL_DIR/verilator/bin"':$PATH'| sudo tee -a /etc/profile
source /etc/profile

# Go back

cd ../..
