FROM debian:trixie-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends g++ cmake make

WORKDIR /sndrServer

COPY . .

RUN cmake -S . -B /build -DSONDER_BUILD_GUI=OFF && cmake --build /build --target TCPServer


# Only TcpServer needed on image
FROM debian:trixie-slim

COPY --from=build /build/TCPServer /usr/local/bin/TCPServer

RUN useradd --no-create-home sns
USER sns

EXPOSE 5358

CMD ["/usr/local/bin/TCPServer"]