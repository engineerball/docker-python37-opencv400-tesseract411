FROM jjanzic/docker-python3-opencv:opencv-4.0.0

ENV TESSDATA_PREFIX "/usr/local/share/tessdata"

# Install Tesseract
RUN apt-get update -y && apt-get install -y python3-pip python3-dev build-essential automake pkg-config libsdl-pango-dev libicu-dev libcairo2-dev bc ffmpeg libsm6 libxext6 & \
    # apt-get -y install tesseract-ocr && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/DanBloomberg/leptonica/releases/download/1.82.0/leptonica-1.82.0.tar.gz && \
    tar xzf leptonica-1.82.0.tar.gz && \
    cd leptonica-1.82.0 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -Rf leptonica-1.82.0 leptonica-1.82.0.tar.gz

RUN wget https://github.com/tesseract-ocr/tesseract/archive/4.1.1.zip && \ 
    unzip 4.1.1.zip && \
    cd tesseract-4.1.1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    tesseract --version && \
    cd .. && \
    rm -Rf tesseract-4.1.1 4.1.1.zip

# download the relevant Tesseract OCRB Language Packages
RUN wget https://github.com/tesseract-ocr/tessdata/blob/main/eng.traineddata && \
    wget https://github.com/Shreeshrii/tessdata_ocrb/raw/master/ocrb.traineddata 
RUN mkdir -p /usr/local/share/tessdata/ && mv *.traineddata /usr/local/share/tessdata/

RUN pip install pillow==8.3.2
