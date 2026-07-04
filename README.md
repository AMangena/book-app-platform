# 🏗️ BookApp Platform

An ASP.NET Core app deployed across **dev / staging / prod** using **Terraform modules** and **per-environment state**, with GitHub Actions pipelines for both app and infrastructure.

- `src/` — the ASP.NET Core app
- `infra/modules/webapp/` — one reusable infrastructure module
- `infra/environments/{dev,staging,prod}/` — three callers of that module, each with its own values + state
- `.github/workflows/` — `app.yml` (build/deploy app) and `infra.yml` (plan-on-PR, apply dev→staging→prod)

👉 Start with **[SETUP_GUIDE.md](./SETUP_GUIDE.md)**.
