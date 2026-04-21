#!/usr/bin/env bash
set -Eeuo pipefail

# -------- Config --------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${1:-terraform/envs/lab}"
DOTENV="${REPO_ROOT}/.env"

# -------- Helpers --------
fail() { echo -e "\n[ERROR] $*\n" >&2; exit 1; }
ok()   { echo -e "[OK] $*"; }
info() { echo -e "[INFO] $*"; }

# -------- Preflight --------
command -v terraform >/dev/null 2>&1 || fail "terraform not found in PATH."

[[ -d "${REPO_ROOT}/${ENV_DIR}" ]] || fail "Env dir not found: ${REPO_ROOT}/${ENV_DIR}"

# -------- Load .env --------
if [[ -f "${DOTENV}" ]]; then
  info "Loading environment from ${DOTENV}"
  set -a
  source "${DOTENV}"
  set +a
  
  # Proxmox variables are already named TF_VAR_* in the .env file
  # Set them properly for the subshell to inherit
  export TF_VAR_pm_api_url="${TF_VAR_pm_api_url:-}"
  export TF_VAR_pm_user="${TF_VAR_pm_user:-}"
  export TF_VAR_pm_token_name="${TF_VAR_pm_token_name:-}"
  export TF_VAR_pm_token_value="${TF_VAR_pm_token_value:-}"
else
  info "No .env found at ${DOTENV} (continuing, but terraform might prompt for credentials)"
fi

pushd "${REPO_ROOT}/${ENV_DIR}" >/dev/null

# Get a unique list of managed containers from Terraform state
info "Fetching deployed containers from Terraform state..."
mapfile -t CTS < <(terraform state list 2>/dev/null | grep 'module.cts\[' | awk -F '"' '{print $2}' | sort -u)

if [[ ${#CTS[@]} -eq 0 ]]; then
  info "No containers found in terraform state! Nothing to destroy."
  popd >/dev/null
  exit 0
fi

echo ""
echo "--------------------------------------------------------"
echo "Select containers to destroy:"
echo "--------------------------------------------------------"
echo "0)  Destroy ALL containers"
for i in "${!CTS[@]}"; do
  echo "$((i+1)))  ${CTS[$i]}"
done
echo "--------------------------------------------------------"
echo ""

read -r -p "Enter numbers separated by spaces (e.g. '1 3 4' or '0' for all) [Leave empty to cancel]: " selection

if [[ -z "$selection" ]]; then
  info "Action canceled."
  popd >/dev/null
  exit 0
fi

if [[ "$selection" == "0" ]]; then
  read -r -p "You selected ALL containers. Are you sure you want to destroy everything? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    CT_IPS_JSON="${REPO_ROOT}/ansible/vars/ct_ips.json"
    if [[ -f "${CT_IPS_JSON}" ]]; then
      info "Removing known_hosts entries for all containers..."
      if command -v jq >/dev/null 2>&1; then
        for ip in $(jq -r 'to_entries[] | .value' "${CT_IPS_JSON}" 2>/dev/null || true); do
          [[ -n "$ip" ]] && ssh-keygen -R "$ip" 2>/dev/null || true
        done
      else
        for ip in $(sed -E 's/["{} ]//g; s/,/\n/g' "${CT_IPS_JSON}" | awk -F: 'NF==2{print $2}' || true); do
          [[ -n "$ip" ]] && ssh-keygen -R "$ip" 2>/dev/null || true
        done
      fi
    fi

    info "Running full terraform destroy..."
    terraform destroy -auto-approve
    ok "Full destroy complete."
  else
    info "Action canceled."
  fi
  popd >/dev/null
  exit 0
fi

# Build target list for specific containers
TARGETS=()
IPS_TO_REMOVE=()
CT_IPS_JSON="${REPO_ROOT}/ansible/vars/ct_ips.json"

for num in $selection; do
  # Validate input is a number
  if ! [[ "$num" =~ ^[0-9]+$ ]]; then
    fail "Invalid input: $num is not a number."
  fi
  
  index=$((num-1))
  if [[ "$index" -ge 0 ]] && [[ "$index" -lt "${#CTS[@]}" ]]; then
    container_name="${CTS[$index]}"
    TARGETS+=("-target=module.cts[\"${container_name}\"]")
    
    if [[ -f "${CT_IPS_JSON}" ]]; then
      if command -v jq >/dev/null 2>&1; then
        ip=$(jq -r ".\"${container_name}\" // empty" "${CT_IPS_JSON}" 2>/dev/null || true)
      else
        ip=$(grep -o "\"${container_name}\":\"[^\"]*\"" "${CT_IPS_JSON}" 2>/dev/null | cut -d'"' -f4 || true)
      fi
      if [[ -n "$ip" ]]; then
        IPS_TO_REMOVE+=("$ip")
      fi
    fi
  else
    fail "Invalid selection: $num. Out of range."
  fi
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  info "No valid containers selected. Action canceled."
  popd >/dev/null
  exit 0
fi

echo ""
info "You have selected the following targets:"
for t in "${TARGETS[@]}"; do
  echo "  $t"
done

read -r -p "Proceed with destroying these specific containers? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  if [[ ${#IPS_TO_REMOVE[@]} -gt 0 ]]; then
    info "Removing known_hosts entries for selected containers..."
    for ip in "${IPS_TO_REMOVE[@]}"; do
      ssh-keygen -R "$ip" 2>/dev/null || true
    done
  fi

  info "Running terraform destroy for selected targets..."
  terraform destroy -auto-approve "${TARGETS[@]}"
  ok "Destroy complete."
else
  info "Action canceled."
fi

popd >/dev/null
