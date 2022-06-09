FROM relaysh/core:latest
RUN apk add --no-cache ruby ruby-dev build-base \
    && gem install json puppet_forge            \
    && apk --no-cache del build-base ruby-dev

COPY "../shared.rb" "/shared.rb"
COPY "./step.rb" "/step.rb"
ENTRYPOINT []
CMD ["ruby", "/step.rb"]

LABEL "org.opencontainers.image.title"="Puppet Forge step describe modules"
LABEL "org.opencontainers.image.description"="This step will describe modules matching search parameters"
LABEL "sh.relay.sdk.version"="v1"
