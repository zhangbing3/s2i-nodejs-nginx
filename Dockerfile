
# s2i-vue-nginx
FROM openshift/base-centos7

# Put the maintainer name in the image metadata
MAINTAINER zhangbing <zhangbing3@foxmail.com>

# Rename the builder environment variable to inform users about application you provide them
ENV BUILDER_VERSION 1.0

# Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building vue or react App" \
      io.k8s.display-name="builder vue nginx" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,vue,nginx"

# install Node.js
RUN wget https://npm.taobao.org/mirrors/node/v9.9.0/node-v9.9.0-linux-x64.tar.gz && \
	tar -zxf node-v9.9.0-linux-x64.tar.gz -C /usr/local && \
	rm -f node-v9.9.0-linux-x64.tar.gz

# set PATH
ENV PATH $PATH:/usr/local/node-v9.9.0-linux-x64/bin

# install cnpm
# RUN npm install -g cnpm --registry=https://registry.npm.taobao.org

# install epel
RUN yum install -y epel-release

# install nginx
RUN INSTALL_PKGS="nginx" && \
	yum install -y $INSTALL_PKGS && \
	rpm -V $INSTALL_PKGS && \
	yum clean all -y

# Change the default port for nginx
#RUN sed -i 's/80/8080/' /etc/nginx/nginx.conf
#RUN sed -i 's/user nginx;//' /etc/nginx/nginx.conf

ADD ./nginx/nginx.conf  /etc/nginx/nginx.conf


# following dirs are owned by user:nginx, and their mode are 755.
# so change their mode to 777 for non-ROOT user
RUN chmod -R 777 /var/log/nginx /var/lib/nginx

# following dirs are owned by user:root, and their mode are 755.
# so change their mode to 775 for non-ROOT user
RUN chmod -R 775 /run /usr/share/nginx/html /etc/nginx

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i
COPY ./s2i/bin/ /usr/libexec/s2i

# This default user is created in the openshift/base-centos7 image
USER   1001

# Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
