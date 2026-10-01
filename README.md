# Crease — Ball Tracking Lab

Independent educational cricket ball-tracking and LBW operator simulator. React 19 + TypeScript + Three.js, with a numerical Python core. This is not Hawk-Eye, official DRS, or a live video tracker.

## Run immediately

Requires Node 22+ and Python 3.10+.

```bash
npm ci
npm run build
npm run dev
```

Open the Vite address printed by the command. The browser loads self-hosted Python WASM once; all delivery calculations then run in a Web Worker. No CDN, account, API key, external data feed or Python server is required. The first load downloads about 13 MB of runtime assets; later loads use browser caching.

## Operator workflow

1. Choose one of 12 presets, or adjust speed, line, length, release, swing, seam, spin, restitution, friction and batter position.
2. Run delivery. Physics, observations, least-squares fits, uncertainty and LBW decisions are recomputed. Changed parameters never silently reuse the previous review.
3. Use four cameras, orbit controls, playback speed, timeline event jumps, and layer toggles. Space plays/pauses; keys 1–4 choose cameras.
4. Start broadcast review and progress through clearance, pitching, impact, wickets and final decision. Resolve a possible edge with an operator ruling.
5. Record the result to this device's session log. Export complete delivery JSON or observation/estimate/projection CSV. Load exported parameters to reproduce a delivery.

## Server deployment

FastAPI exposes `GET /health`, `GET /api/presets`, `POST /api/deliveries`, with validation errors returned as HTTP 422. The same Python package supplies the browser and API. For a separate API, set `VITE_API_BASE=https://your-api-host/api` at frontend build time and `CREASE_ALLOWED_ORIGIN=https://your-frontend-host` on the server.

```bash
python -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/uvicorn backend.api.main:app --host 0.0.0.0 --port 8080
```

Or build the combined frontend and FastAPI deployment:

```bash
docker build -t crease-review .
docker run --rm -p 8080:8080 crease-review
```

Docker builds the React interface with `VITE_API_BASE=/api`, then serves static assets and FastAPI from one origin. It does not require WASM to execute deliveries. A health check is included. Before internet-facing API deployment, put the service behind TLS and appropriate request limits for your provider. Session history is device-local; there is no shared multi-user database.

## Quality checks

```bash
python -m unittest discover -s tests -v
node scripts/bundle-python.mjs
node scripts/test-wasm.mjs
npm run build
```

Install `httpx==0.28.1` alongside `requirements.txt` to run API tests. Without API dependencies those six tests are explicitly skipped. See `docs/VALIDATION.md` for the checks performed on this version and remaining validation.

## Project map

- `backend/physics`: centralized SI geometry and RK4 flight/bounce integration.
- `backend/tracking`: seeded noisy observations and piecewise least-squares estimation.
- `backend/uncertainty`: bootstrap impact/projection uncertainty.
- `backend/decision_engine`: wicket-solid intersection and independently configurable review policy.
- `backend/validation`: typed ranges, enums and invalid-combination checks.
- `backend/delivery_generator`: named delivery presets.
- `backend/api`: FastAPI deployment companion.
- `frontend/visualisation`: dynamic WebGL environment and camera control.
- `frontend/controls`: delivery, tracking and review configuration.
- `frontend/components`: numerical wicket plot.
- `frontend/App.tsx`: replay, broadcast stages, evidence diagnostics and device session log.
- `data`: reproducible examples, presets, generated geometry and session format.
- `tests`: physics, law gates, API integration.
- `scripts`: self-hosted Python packaging and runtime parity tests.
- `docs`: model, architecture, deployment and validation notes.

## Scope boundaries

The laws reference is MCC Law 36, including the 2026 terminology update. The simulation uses simplified biomechanics and aerodynamic coefficients; it has not been calibrated against real match footage. Umpire's Call is an independent educational policy, not an official ICC or proprietary implementation. See `docs/MODEL.md` for the explicit approximations, unsupported full-toss/double-bounce reviews, geometry and tracker replacement contract.

All visual paths come from numerical output. No fixed image is used as the main visualization. The optional ground-truth layer is clearly labeled and is not the source of the review projection.

## Windows quick start

Install Node.js 22+ and Python 3.10+, both available in PATH. Extract this project and run `start_windows.bat`. It installs locked dependencies, packages the Python engine, checks/compiles the frontend, and starts the app. Open the printed `http://localhost:4173` address. For FastAPI, create a virtual environment and use `.venv\Scripts\python -m pip install -r requirements.txt` followed by `.venv\Scripts\python -m uvicorn backend.api.main:app --port 8080`.
