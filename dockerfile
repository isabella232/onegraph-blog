FROM node:14 as builder

COPY . .

ENV BASE_PATH="/blog"
ENV NODE_ENV=production
ARG gcp_project

RUN yarn install

RUN yarn build && rm -rf .next/cache

RUN yarn firebase-deploy-directory --project $gcp_project --subpath blog/_next/static --directory .next/static/ --commit

FROM node:14

ENV BASE_PATH="/blog"
ENV NODE_ENV=production

COPY package.json .
COPY yarn.lock .
# Copies public environment variables
COPY .env.local .env
COPY server.js.example server.js
COPY next.config.js .
COPY .pnp.js .
COPY .yarn .
COPY .yarnrc.yml .

RUN yarn install

COPY --from=builder .next .next

CMD [ "yarn", "node", "server.js" ]
