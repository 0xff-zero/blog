
docker build  --platform=linux/arm64 -t devops.cscec.com/udp/udp-monitor:1.9.5-137.5-m-arm64  --build-arg APP_NAME=udp-monitor --build-arg APP_VERSION=1.9.5  -f deploy/multi_arch/Dockerfile .

docker build  --platform=linux/amd64 -t devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m-amd64  --build-arg APP_NAME=udp-monitor --build-arg APP_VERSION=1.9.5  -f deploy/multi-arch/Dockerfile .

docker push  devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m-arm64
docker push  devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m-amd64

docker manifest create devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m  devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m-arm64    devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m-amd64

docker manifest annotate  devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m  devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m-amd64  --os linux --arch amd64
docker manifest annotate  devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m  devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m-arm64  --os linux --arch arm64

docker manifest push devops.cscec.com/udp/udp-monitor:1.9.5-137.6-m