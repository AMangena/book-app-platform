# 🏗️ BookApp Platform — App + Multi-Environment Terraform

A complete, realistic project: an **ASP.NET Core app** (`src/`) plus **Terraform infrastructure** organised the professional way — **one reusable module** called by **three environments** (dev, staging, prod), each with its own values and its own state.

This is the "Environments Layer + Modules Layer" pattern from the best-practices diagrams, made real.

---

## The whole structure at a glance

```
book-app-platform/
├── src/BookApp/                  THE APP (developer's concern)
│
├── infra/                        THE INFRASTRUCTURE (your concern)
│   ├── modules/
│   │   └── webapp/               ◄── ONE reusable module (defined once)
│   │       ├── main.tf               the resources
│   │       ├── variables.tf          its inputs
│   │       └── outputs.tf            its outputs
│   │
│   └── environments/             ◄── THREE callers (each uses the module)
│       ├── dev/                      cheap: B1
│       ├── staging/                  cheap: B1
│       └── prod/                     beefier: B2
│           ├── main.tf               calls the module with prod values
│           ├── variables.tf
│           ├── terraform.tfvars      prod's specific values
│           └── backend.tf            prod's OWN state (prod.tfstate)
│
├── .github/workflows/
│   ├── app.yml                   build/test/deploy the app
│   └── infra.yml                 terraform: plan on PR, apply dev→staging→prod
│
└── bootstrap-state.ps1           one-time state storage setup
```

---

## The ONE idea to internalise

**The module is written once. Each environment calls it with different values and stores its own state.**

```
                  modules/webapp   (the single blueprint)
                   ▲      ▲      ▲
        calls it  /       |       \  calls it
                 /        |        \
        environments/dev  staging   prod
         B1, dev.tfstate  B1,       B2,
                          staging…  prod.tfstate
```

Look at the three `terraform.tfvars` files — they're the *only* meaningful difference between environments:

| | dev | staging | prod |
|---|---|---|---|
| app_name | book-app-dev-… | book-app-staging-… | book-app-prod-… |
| sku_name | B1 | B1 | **B2** (bigger) |
| state key | dev.tfstate | staging.tfstate | prod.tfstate |

Same module, three sets of values, three separate states. That's the entire multi-environment pattern.

---

## PHASE 1 — Run the app locally (the developer's half)

```powershell
cd src/BookApp
dotnet restore
dotnet run
```

Open the printed URL → you'll see the book library, with "Environment: local". `Ctrl+C` to stop. This confirms the app works before you build anywhere to host it.

---

## PHASE 2 — Bootstrap remote state (one time)

State for all three environments lives in one storage account (different blob keys).

```powershell
cd ..\..        # back to project root
./bootstrap-state.ps1
```

Copy the storage account name it prints. Then paste it into the `backend.tf` of **all three** environments (dev, staging, prod), replacing `tfstateamangena5094`.

> Tip: do a find-and-replace across the `infra/environments/` folder for that placeholder.

---

## PHASE 3 — Deploy DEV (your first environment)

```powershell
cd infra/environments/dev
terraform init        # initialises dev's remote state (dev.tfstate)
terraform plan        # 3 to add
terraform apply       # type yes
```

You've built the dev infrastructure. Note the state went to `dev.tfstate` in your storage account.

---

## PHASE 4 — Deploy STAGING and PROD (the aha moment)

Now the payoff. Do the **same three commands** in the other two environment folders:

```powershell
cd ../staging
terraform init
terraform apply       # type yes  → builds staging (its own state: staging.tfstate)

cd ../prod
terraform init
terraform apply       # type yes  → builds prod  (B2 plan, own state: prod.tfstate)
```

Stop and notice what just happened:

- You ran the **same module** three times.
- Each environment built **separate Azure resources** (book-app-dev-rg, -staging-rg, -prod-rg).
- Each has its **own state file** — they never interfere.
- prod got a **B2** plan while dev/staging got B1 — *because their tfvars differ*, not because the module differs.

**That is exactly how real teams manage dev/staging/prod.** One definition, many environments.

---

## PHASE 5 — Deploy the app onto an environment

The infrastructure is the empty house; now move the app in. Manually for dev:

```powershell
cd ../../../src/BookApp
dotnet publish -c Release -o publish
az webapp deploy --resource-group book-app-dev-rg --name book-app-dev-amangena-2026 --src-path publish --type zip
```

Refresh `https://book-app-dev-amangena-2026.azurewebsites.net` → your book library, live. (The pipelines automate this — see Phase 6.)

---

## PHASE 6 — The pipelines (automation)

Two workflows:

- **`app.yml`** — on changes to `src/`, builds/tests the app and deploys it (to dev by default).
- **`infra.yml`** — on changes to `infra/`: **plan all three envs on a PR**, then on merge **apply dev → staging → prod**, each gated by its GitHub environment for approval. This is the **promotion flow** — changes roll forward through environments with approvals.

Setting up the pipelines needs the same OIDC + environments work as your earlier projects, now with environments named `dev`, `staging`, and `production`, and federated credentials matching each. The README covers it; tackle this only after the local multi-env flow makes sense.

---


## 🧪 Testing — both kinds

This project tests **both** the app and the infrastructure.

**App tests (xUnit)** — in `tests/BookApp.Tests/`. Run locally:
```powershell
dotnet test
```
The `app.yml` pipeline runs these on every push/PR; broken code can't deploy.

**Terraform tests (native)** — in `infra/modules/webapp/tests/webapp.tftest.hcl`. They use `mock_provider` (no real Azure) and `command = plan` (creates nothing), so they're fast and free. Run locally:
```powershell
cd infra/modules/webapp
terraform init -backend=false
terraform test
```
They assert things like "SKU defaults to B1" and "prod can override to B2". The `infra.yml` pipeline runs `fmt -check`, `validate`, and `terraform test` as a quality gate before any plan/apply.

> Note: run `terraform fmt -recursive` once from `infra/` and commit, so the pipeline's `fmt -check` passes.

## Cleanup

Destroy each environment when done (from each env folder):

```powershell
cd infra/environments/prod ;    terraform destroy   # yes
cd ../staging ;                 terraform destroy   # yes
cd ../dev ;                     terraform destroy   # yes
```

---

## 💼 What you can now explain in an interview

- **"Modules + environments"** — "I define infrastructure once as a module and call it from per-environment folders (dev/staging/prod), each passing its own values — so environments stay consistent but can differ where needed, like a bigger SKU in prod."
- **"Separate state per environment"** — "Each environment has its own state file (its own backend key), so a change to dev can never affect prod's state."
- **"Promotion flow"** — "Infra changes plan on a PR across all envs, then on merge apply dev → staging → prod with approval gates between them."
- **"Separation of app and infra"** — "The app lives in src/ and is the developer's concern; the infra/ folder and pipelines are the DevOps concern, connected by the deploy step."

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `init`: backend / storage 403 | Paste your real storage account name into each `backend.tf`; ensure your user has Storage Blob Data role |
| App name not available | The `app_name` in that env's tfvars must be globally unique — change the number |
| Two envs share state | Check each `backend.tf` has a DIFFERENT `key` (dev/staging/prod.tfstate) |
| prod uses B1 not B2 | Check `prod/terraform.tfvars` sku_name = "B2" |
