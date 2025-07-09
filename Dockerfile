FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y wget
ARG HUGO_VERSION=0.147.3
RUN wget -O hugo.deb "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" \
    && dpkg -i hugo.deb && rm hugo.deb

WORKDIR /src
COPY . .
RUN hugo --minify 

# --config /src/hugo.yaml

FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80