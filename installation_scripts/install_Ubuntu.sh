#!/bin/bash

# -----------------------------------------------------------------
# DISCLAIMER
# Adapted from http://michal.kosmulski.org/computing/shell-scripts/
# -----------------------------------------------------------------
# This script come without warranty of any kind. 
# You use it at your own risk. 
# We assume no liability for the accuracy, correctness, completeness, or usefulness of this script, nor for any sort of damages that using it may cause.

# -------------------------
# REQUIRES USER INTERACTION
# -------------------------

bashfile=~/.bashrc
echo ""
echo "Do you want to add Homebrew/Linuxbrew and deal.II paths"
echo "to $bashfile? [Y/n]:"
read addHBpaths

echo "You are about to be asked for your password so that "
echo "essential system libraries can be installed."
echo "After this, the rest of the build should be automatic."

# ------------------------
# GENERIC WITH SYSTEM BLAS
# ------------------------
sudo apt-get install \
build-essential curl git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev csh subversion \
gcc g++ gfortran \
mpi-default-bin libopenmpi-dev \
cmake \
libblas-dev liblapack-dev
sudo -k # Safety first: Invalidate user timestep

# --------------
# LINUXBREW BASE
# --------------
export HOMEBREW_PREFIX=~/.linuxbrew
git clone https://github.com/Homebrew/linuxbrew.git $HOMEBREW_PREFIX

export HOMEBREW_LOGS=$HOMEBREW_PREFIX/_logs/linuxbrew
export HOMEBREW_CACHE=$HOMEBREW_PREFIX/_cache/linuxbrew
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man:$MANPATH"
export INFOPATH="$HOMEBREW_PREFIX/share/info:$INFOPATH"

brew install pkg-config && \
brew install openssl && brew postinstall openssl && \
brew install ruby

# -------------
# DEAL.II SUITE
# -------------
brew tap davydden/dealiisuite

brew install boost --with-mpi --without-single && \
brew install hdf5 --with-mpi --c++11 && \
brew install hypre --with-mpi --without-check && \
brew install metis && \
brew install parmetis && \
brew install superlu_dist && \
brew install scalapack --without-check && \
brew install mumps && \
brew install petsc --without-check && \
brew install arpack --with-mpi && \
brew install slepc --without-check && \
brew install p4est --without-check && \
HOMEBREW_MAKE_JOBS=1 brew install trilinos && \
brew install dealii --HEAD # Build problem related to C++11 detected by Trilinos and not deal.II 8.3.0

if [[ -e $bashfile ]]; then
  if [[ (( $addHBpaths == "y" )) || (( $addHBpaths == "Y" )) || (( $addHBpaths == "Yes" )) || (( $addHBpaths == "yes" )) ]]; then
    echo "Adding Homebrew paths to $bashfile"

    echo "" >> $bashfile
    echo "## === LINUXBREW ===" >> $bashfile
    echo "HOMEBREW_PREFIX=~/.linuxbrew" >> $bashfile
    echo "HOMEBREW_LOGS=\$HOMEBREW_PREFIX/_logs" >> $bashfile
    echo "HOMEBREW_CACHE=\$HOMEBREW_PREFIX/_cache" >> $bashfile
    echo "PATH=\"\$HOMEBREW_PREFIX/bin:\$PATH\"" >> $bashfile
    echo "MANPATH=\"\$HOMEBREW_PREFIX/share/man:\$MANPATH\"" >> $bashfile
    echo "INFOPATH=\"\$HOMEBREW_PREFIX/share/info:\$INFOPATH\"" >> $bashfile
    echo "DEAL_II_DIR=\$HOMEBREW_PREFIX" >> $bashfile
  else
    echo "To use deal.II you must pass the following flag to CMake"
    echo "when configuring your problems:"
    echo "-DDEAL_II_DIR=$HOMEBREW_PREFIX"
  fi
else
  echo "Error: Bash file does not exist. Could not add paths"
  echo "as requested."
fi
