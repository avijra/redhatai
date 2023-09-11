# syntax=docker/dockerfile:1
# Build as `docker build . -t localgpt`, requires BuildKit.
# Run as `docker run -it --mount src="$HOME/.cache",target=/root/.cache,type=bind --gpus=all localgpt`, requires Nvidia container toolkit.

FROM nvidia/cuda:12.2.0-devel-ubi9

RUN yum -y update \
    && yum -y install gcc  \
    && yum -y install gcc-c++  \
   && yum -y --allowerasing install curl bzip2 \
    && curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm -rf /tmp/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

## ADD CONDA PATH TO LINUX PATH 
ENV PATH /opt/conda/bin:$PATH

## COPY ENV REQUIREMENTS FILES
COPY ./env_config.yml /tmp/env_config.yml

## CREATE CONDA ENVIRONMENT USING YML FILE
RUN conda update conda \
    && conda env create -f /tmp/env_config.yml

## ADD CONDA ENV PATH TO LINUX PATH 
ENV PATH /opt/conda/envs/myconda/bin:$PATH
ENV CONDA_DEFAULT_ENV myconda

## MAKE ALL BELOW RUN COMMANDS USE THE NEW CONDA ENVIRONMENT
RUN echo "conda activate myconda" >> ~/.bashrc

COPY ./requirements.txt . 

RUN --mount=type=cache,target=/root/.cache  pip install --timeout 100 -r requirements.txt

RUN --mount=type=cache,target=/root/.cache CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install --upgrade --force-reinstall llama-cpp-python
COPY SOURCE_DOCUMENTS ./SOURCE_DOCUMENTS
#COPY pyproject.toml run_localGPT.py ingest.py constants.py ./
# Docker BuildKit does not support GPU during *docker build* time right now, only during *docker run*.
# See <https://github.com/moby/buildkit/issues/1436>.
# If this changes in the future you can `docker build --build-arg device_type=cuda  . -t localgpt` (+GPU argument to be determined).
#ARG device_type=cpu
#RUN --mount=type=cache,target=/root/.cache python ingest.py --device_type $device_type
WORKDIR /app
COPY . .

ENV device_type=cuda
#COPY localGPT_UI.py ./
#CMD streamlit run localGPT_UI.py
EXPOSE 8501
ENTRYPOINT ["streamlit", "run", "redhat_ai.py", "--server.port=8501", "--server.address=0.0.0.0"]


   

 