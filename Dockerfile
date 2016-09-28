#docker build
 

FROM ruby:2.0.0
MAINTAINER Autodesk BIM 360 Docs <BIM360dm.dev.no-reply@autodesk.com>

# Prepare
RUN apt-get update -qq && apt-get -y install --no-install-recommends \
    locales=2.19-18+deb8u6 \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
RUN touch /etc/default/locale
RUN echo LANG=en_US.UTF-8 >> /etc/default/locale
RUN echo LANGUAGE=en_US.UTF-8 >> /etc/default/locale
RUN echo LC_ALL=en_US.UTF-8 >> /etc/default/locale

# Dependencies
RUN apt-get update -qq && apt-get -y install --no-install-recommends \
    nodejs=0.10.29~dfsg-2 \
    graphicsmagick=1.3.20-3+deb8u1 \
    build-essential=11.7 \
    libpq-dev=9.4.9-0+deb8u1 \
    libxslt1-dev=1.1.28-2+deb8u1 \
    libleptonica-dev=1.71-2.1+b2 \
    postgresql-client=9.4+165+deb8u1 \
    iptables=1.4.21-2+b1 \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ROOT /root/RAILSTEST
 

 
WORKDIR $RAILS_ROOT
 
# Cache gems so followed up bundling can be much faster
# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
ENV BUNDLE_PATH=/root/bundle
ENV PATH=/root/bundle/bin:/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN gem ins bundler
RUN bundle config --global silence_root_warning 1
RUN bundle config git.allow_insecure true
RUN bundle install --without production
COPY . .
RUN bundle exec rake db:migrate
RUN bundle exec rake db:test:prepare
# Make sure every file is executable, since git in windows may lose it
RUN chmod +x $RAILS_ROOT/bin/*
RUN chmod +x config/containers/app_cmd.sh
CMD [ "config/containers/app_cmd.sh" ]