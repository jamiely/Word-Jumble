FROM ortussolutions/commandbox:latest

WORKDIR /app

ENV CFENGINE=lucee@5.4
ENV PORT=8080

COPY . /app

EXPOSE 8080

CMD ["/bin/bash", "-lc", "box server start --console --host 0.0.0.0 --port ${PORT} --cfengine=${CFENGINE} --openbrowser=false"]
