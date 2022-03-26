
FROM ubuntu:20.04

# Set timezone
RUN  echo "Etc/UTC" > /etc/localtime
RUN apt-get update && \
  apt-get -y --no-install-recommends install build-essential \
  wget libyaml-dev libgdbm-dev libreadline-dev libjemalloc-dev \
	libncurses5-dev libffi-dev zlib1g-dev libssl-dev \
  libssl1.1 libpq5 imagemagick ffmpeg libjemalloc2 \
  libicu66 libprotobuf17 libidn11 libyaml-0-2 \
  file ca-certificates tzdata libreadline8 gcc \
  curl \
  g++ \
  gcc \
  git \
  less \
  libffi-dev \
  libc-dev \
  libxml2-dev \
  libxslt-dev \
  libgcrypt-dev \
  make \
  openssl \
  python \
  libpq-dev \
  postgresql-client \
  imagemagick \
  ffmpeg \
  libmagickwand-dev \
  libssl1.1 \
  libvips \
  g++-6 \
  libprotobuf-dev \
  protobuf-compiler
RUN mkdir -p /quotes-estimator
WORKDIR /quotes-estimator

# Install Ruby
ENV RUBY_VER="2.7.2"
RUN apt-get update && \
  apt-get install -y --no-install-recommends build-essential \
    libyaml-dev libgdbm-dev libreadline-dev libjemalloc-dev \
		libncurses5-dev libffi-dev zlib1g-dev libssl-dev && \
	cd ~ && \
	wget https://cache.ruby-lang.org/pub/ruby/${RUBY_VER%.*}/ruby-$RUBY_VER.tar.gz && \
	tar xf ruby-$RUBY_VER.tar.gz && \
	cd ruby-$RUBY_VER && \
	./configure --prefix=/opt/ruby \
	  --with-jemalloc \
	  --with-shared \
	  --disable-install-doc && \
	make -j"$(nproc)" > /dev/null && \
	make install && \
	rm -rf ../ruby-$RUBY_VER.tar.gz ../ruby-$RUBY_VER

ENV PATH=$HOME:$PATH
ENV PATH="${PATH}:/opt/ruby/bin"
# ENV REDIS_URL=redis://redis:6379/0


ADD Gemfile /application/
ADD Gemfile.lock /application/
RUN gem install bundler:2.2.5
RUN bundle install
COPY . /application

EXPOSE 5000

CMD ["bundle", "exec", "puma"]