#!/usr/bin/env bash
set -Eeuo pipefail

# -------- Config --------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${1:-terraform/envs/lab}"
DOTENV="${REPO_ROOT}/.env"

# Optional env:
#   export APPLY_AUTO="-auto-approve"
APPLY_AUTO=${APPLY_AUTO:-}

# -------- Helpers --------
fail() { echo -e "\n[ERROR] $*\n" >&2; exit 1; }
ok()   { echo -e "[OK] $*"; }
info() { echo -e "[INFO] $*"; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || fail "$1 not found in PATH."; }

# -------- Preflight --------
require_cmd terraform

[[ -d "${REPO_ROOT}/${ENV_DIR}" ]] || fail "Env dir not found: ${REPO_ROOT}/${ENV_DIR}"

# -------- Load .env --------
if [[ -f "${DOTENV}" ]]; then
  info "Loading environment from ${DOTENV}"
  # Strip Windows carriage returns (CRLF) to prevent control character errors
  sed -i 's/\r$//' "${DOTENV}"
  set -a
  # shellcheck disable=SC1090
  source "${DOTENV}"
  set +a
  ok ".env loaded"
else
  info "No .env found at ${DOTENV} (continuing without it)"
fi

# -------- Terraform --------
pushd "${REPO_ROOT}/${ENV_DIR}" >/dev/null
  TF_PLAN="./tfplan"
  TF_PLAN_TXT="./tfplan.txt"
  TF_PLAN_JSON="./tfplan.json"
  TF_DEBUG_LOG="./tf-debug.log"

  info "Terraform init (upgrade providers if needed)…"
  terraform init -upgrade -input=false || fail "terraform init failed"

  info "Terraform validate…"
  terraform validate || fail "terraform validate failed"

  info "Terraform planning… (writing plan to ${TF_PLAN})"
  rm -f "$TF_PLAN" "$TF_PLAN_TXT" "$TF_PLAN_JSON" "$TF_DEBUG_LOG"

  if ! terraform plan -out="$TF_PLAN" -lock-timeout=5m -input=false; then
    echo "[ERROR] terraform plan failed"
    [[ -f "$TF_PLAN" ]] && terraform show "$TF_PLAN" | tee "$TF_PLAN_TXT" >/dev/null || true
    popd >/dev/null
    exit 1
  fi

  info "Saving human-readable plan → ${TF_PLAN_TXT}"
  terraform show "$TF_PLAN" | tee "$TF_PLAN_TXT" >/dev/null || true

  # Useful for debugging/CI without needing Ansible
  info "Saving JSON plan → ${TF_PLAN_JSON}"
  terraform show -json "$TF_PLAN" > "$TF_PLAN_JSON" || true

  if [[ -z "${APPLY_AUTO}" ]]; then
    read -r -p $'\nProceed with terraform apply of saved plan? [y/N] ' CONFIRM
    if [[ "${CONFIRM}" =~ ^[Yy]$ ]]; then
      info "Applying Terraform plan…"
      if ! terraform apply "$TF_PLAN"; then
        echo "[ERROR] terraform apply failed; capturing provider debug at ${TF_DEBUG_LOG}"
        TF_LOG=DEBUG TF_LOG_PATH="$TF_DEBUG_LOG" terraform apply "$TF_PLAN" || true
        popd >/dev/null; exit 1
      fi
      ok "Terraform apply completed"
    else
      info "Skipping terraform apply"
    fi
  else
    info "Applying Terraform plan (non-interactive)…"
    if ! terraform apply ${APPLY_AUTO} "$TF_PLAN"; then
      echo "[ERROR] terraform apply failed; capturing provider debug at ${TF_DEBUG_LOG}"
      TF_LOG=DEBUG TF_LOG_PATH="$TF_DEBUG_LOG" terraform apply ${APPLY_AUTO} "$TF_PLAN" || true
      popd >/dev/null; exit 1
    fi
    ok "Terraform apply completed"
  fi
popd >/dev/null

ok "Done."