#!/bin/bash
sudo docker build -f Dockerfile . -t europe-west2-docker.pkg.dev/prj-biomodal-forte/europe-ml-docker/test_boltz:0.0.1
sudo docker build -f Dockerfile . -t us-docker.pkg.dev/prj-biomodal-forte/us-ml-docker/test_boltz:0.0.1

docker push europe-west2-docker.pkg.dev/prj-biomodal-forte/europe-ml-docker/test_boltz:0.0.1
docker push us-docker.pkg.dev/prj-biomodal-forte/us-ml-docker/test_boltz:0.0.1