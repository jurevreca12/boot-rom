FROM hpretl/iic-osic-tools:2025.07

RUN pip install --upgrade pip && \
    pip install "cython<3.0.0" wheel && \
    pip install "PyYAML==5.2" --no-build-isolation && \
    pip install cocotb==2.0.0 && \
    pip install git+https://github.com/jurevreca12/forastero.git@09c1817

USER 0:0
RUN curl -L https://github.com/sifive/elf2hex/archive/refs/tags/v20.08.00.00.tar.gz -o elf2hex.tar.gz && \
    tar -xvzpf elf2hex.tar.gz && \
    rm elf2hex.tar.gz && \
    cd elf2hex-* && \
    ./configure --target=riscv32-unknown-elf && \
    make && \
    make install && \
    cd .. && \
    rm -rf elf2hex-*

WORKDIR /foss/designs/boot-rom
