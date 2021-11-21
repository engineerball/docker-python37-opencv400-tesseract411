FROM python:3.7

WORKDIR /opt/build

ENV OPENCV_VERSION="4.5.4"
ENV TESSERACT_VERSION="4.1.1"
ENV LEPTONICA_VERSION="1.82.0"
ENV TESSDATA_PREFIX "/usr/local/share/tessdata"


RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        build-essential \
        cmake \
        automake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libopenjp2-7-dev \
        libavformat-dev \
        libpq-dev \
        libsdl-pango-dev \
        libicu-dev \
        libcairo2-dev \
        bc \
        # ffmpeg \
        libsm6 \
        libxext6 \
    && pip install numpy \
    && pip install pillow \
    && wget -q https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip \
    && unzip -qq opencv.zip -d /opt \
    && rm -rf opencv.zip \
    && cmake \
        -D BUILD_TIFF=ON \
        -D BUILD_opencv_java=OFF \
        -D WITH_CUDA=OFF \
        -D WITH_OPENGL=ON \
        -D WITH_OPENCL=ON \
        -D WITH_IPP=ON \
        -D WITH_TBB=ON \
        -D WITH_EIGEN=ON \
        -D WITH_V4L=ON \
        -D BUILD_TESTS=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=$(python3.7 -c "import sys; print(sys.prefix)") \
        -D PYTHON_EXECUTABLE=$(which python3.7) \
        -D PYTHON_INCLUDE_DIR=$(python3.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -D PYTHON_PACKAGES_PATH=$(python3.7 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
        /opt/opencv-${OPENCV_VERSION} \
    && make -j$(nproc) \
    && make install \
    && wget https://github.com/DanBloomberg/leptonica/releases/download/${LEPTONICA_VERSION}/leptonica-${LEPTONICA_VERSION}.tar.gz \
    && tar xzf leptonica-${LEPTONICA_VERSION}.tar.gz  \
    && cd leptonica-${LEPTONICA_VERSION} \
    && ./configure \
    && make \
    && make install \
    && wget https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.zip \ 
    && unzip ${TESSERACT_VERSION}.zip \
    && cd tesseract-${TESSERACT_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    && tesseract --version \
    && rm -rf /opt/build/* \
    # && rm -rf /opt/build/opencv-${OPENCV_VERSION} \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -qq autoremove \
    && apt-get -qq clean

# # Install Tesseract
# RUN wget https://github.com/DanBloomberg/leptonica/releases/download/${LEPTONICA_VERSION}/leptonica-${LEPTONICA_VERSION}.tar.gz && \
#     tar xzf leptonica-${LEPTONICA_VERSION}.tar.gz && \
#     cd leptonica-${LEPTONICA_VERSION} && \
#     ./configure && \
#     make && \
#     make install && \
#     cd .. && \
#     rm -Rf leptonica-${LEPTONICA_VERSION} leptonica-${LEPTONICA_VERSION}.tar.gz

# RUN wget https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.zip && \ 
#     unzip ${TESSERACT_VERSION}.zip && \
#     cd tesseract-${TESSERACT_VERSION} && \
#     ./autogen.sh && \
#     ./configure && \
#     make && \
#     make install && \
#     ldconfig && \
#     tesseract --version && \
#     cd .. && \
#     rm -Rf tesseract-${TESSERACT_VERSION} ${TESSERACT_VERSION}.zip

# download the relevant Tesseract OCRB Language Packages
RUN wget https://github.com/tesseract-ocr/tessdata/blob/main/eng.traineddata \
    && wget https://github.com/Shreeshrii/tessdata_ocrb/raw/master/ocrb.traineddata \
    && mkdir -p /usr/local/share/tessdata/ \
    && mv *.traineddata /usr/local/share/tessdata/
