# Orchestra C++ SDK Docker in Ubuntu 16.04 (Xenial)

You'll have to add the orchestra-sdk-1.8-1.x86_64.tgz file (login required, from https://collaborate.mr.gehealthcare.com/) 
to the same folder as the Dockerfile, then run (on a system with Docker installed):

```docker build --rm -f "Dockerfile" -t ubuntudocker:latest "."```
