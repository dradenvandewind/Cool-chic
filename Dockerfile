# ===== Step 1 : Build =====
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV DISPLAY=:0 # Changed to :0 for default display
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64/
ENV TF_FORCE_GPU_ALLOW_GROWTH=true
ENV TF_ENABLE_GPU_GARBAGE_COLLECTION=false
ENV TAG=v4.2.0 
LABEL maintainer="erwanleblond@gmail.com"
ENV AUTHOR="Erwan Le Blond erwanleblond@gmail.com"

RUN apt update && apt install -y \
    software-properties-common curl git build-essential g++ \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt update && apt install -y python3.10 python3.10-dev python3.10-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/Orange-OpenSource/Cool-Chic.git && \
    cd Cool-Chic && \
    git checkout tags/$TAG && \
    python3.10 -m venv venv && \
    . /app/Cool-Chic/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install virtualenv numpy setuptools wheel cython && \
    pip install -e .

# ===== Step 2 : Runtime =====
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV DISPLAY=:1
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64/
ENV TF_FORCE_GPU_ALLOW_GROWTH=true
ENV TF_ENABLE_GPU_GARBAGE_COLLECTION=false

RUN apt update && apt install -y \
    python3.10 python3.10-venv python3-pip vim && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app/Cool-Chic/

COPY --from=builder /app /app

# Définir le PATH pour inclure le venv
ENV PATH="/app/Cool-Chic/venv/bin:$PATH"

# Option 1: Lancer un shell avec venv activé
CMD ["/bin/bash", "-c", "source /app/Cool-Chic/venv/bin/activate && /bin/bash"]

#Encoding test command
#python3 samples/encode.py -i /app/Cool-Chic/test/data/kodim15_192x128_01p_yuv420_8b.yuv -o kodim15_192x128_01p_yuv420_8b.cool

#decoding test command
#python coolchic/decode.py -i samples/bitstreams/a365_wd.cool -o a365_wd.ppm