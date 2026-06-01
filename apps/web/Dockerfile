FROM node:22-alpine AS deps

WORKDIR /app

COPY package.json ./
RUN npm install --legacy-peer-deps

FROM node:22-alpine AS builder

WORKDIR /app

ARG NEXT_PUBLIC_API_URL=http://localhost:6823
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# Optional Google sign-in client ID — baked at build time. Leave empty
# to hide the "Sign in with Google" button.
ARG NEXT_PUBLIC_GOOGLE_CLIENT_ID=
ENV NEXT_PUBLIC_GOOGLE_CLIENT_ID=$NEXT_PUBLIC_GOOGLE_CLIENT_ID

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=3233

COPY --from=builder /app ./

EXPOSE 3233

CMD ["npm", "run", "start", "--", "--hostname", "0.0.0.0", "--port", "3233"]
