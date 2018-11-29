make build
chmod 777 bin/amd64/nginx-ingress-controller
docker build . -f fastDockerfile -t quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.20.0-fast

docker-compose -f docker-compose.yml down
docker-compose -f docker-compose.yml up
