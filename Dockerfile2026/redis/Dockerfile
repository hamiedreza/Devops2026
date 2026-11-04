
FROM redis:7.4

LABEL maintainer="hamiedreza Asosheh"

ENV TZ=UTC

EXPOSE 6379

CMD ["sh", "-c", "exec redis-server --requirepass \"$REDIS_PASSWORD\""]

