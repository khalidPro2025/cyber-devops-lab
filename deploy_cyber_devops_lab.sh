#!/bin/bash
# ============================================================
# Script de déploiement GitHub - Projet Cyber-DevOps
# Projet  : cyber-devops-lab
# Auteur  : Khalid
# Objectif: Versionnement & déploiement GitHub sécurisé
# ============================================================

set -e

# ===================== VARIABLES =============================
GIT_USER="khalidPro2025"
REPO_NAME="cyber-devops-lab"
BRANCH="main"

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"
SSH_EMAIL="${GIT_USER}@github.com"

REMOTE_URL="git@github.com:${GIT_USER}/${REPO_NAME}.git"

# =============================================================
echo ""
echo "============================================================"
echo "[INIT] Déploiement du projet $REPO_NAME"
echo "============================================================"

# ===================== ETAPE 1 ================================
# Vérification / génération clé SSH
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "[SSH] Aucune clé détectée, génération..."
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY_PATH" -N ""
else
    echo "[SSH] Clé SSH existante détectée"
fi

# ===================== ETAPE 2 ================================
# Agent SSH
echo "[SSH] Démarrage de l'agent SSH..."
eval "$(ssh-agent -s)" >/dev/null
ssh-add "$SSH_KEY_PATH"

# ===================== ETAPE 3 ================================
# Test connexion GitHub
echo "[TEST] Test de connexion SSH GitHub..."
if ssh -T git@github.com 2>&1 | grep -qi "successfully authenticated"; then
    echo "[SSH] Connexion GitHub OK"
else
    echo "[ERREUR] Clé SSH non enregistrée sur GitHub"
    echo "------------------------------------------------"
    cat "$SSH_PUB_KEY"
    echo "------------------------------------------------"
    echo "Ajoute la clé ici : https://github.com/settings/keys"
    exit 1
fi

# ===================== ETAPE 4 ================================
# Initialisation Git
if [ ! -d ".git" ]; then
    echo "[GIT] Initialisation du dépôt Git..."
    git init
    git branch -M "$BRANCH"
else
    echo "[GIT] Dépôt Git déjà initialisé"
fi

# ===================== ETAPE 5 ================================
# Configuration remote
echo "[GIT] Configuration du remote GitHub..."
if git remote -v | grep -q "$REMOTE_URL"; then
    echo "[GIT] Remote déjà configuré"
else
    git remote remove origin 2>/dev/null || true
    git remote add origin "$REMOTE_URL"
    echo "[GIT] Remote ajouté : $REMOTE_URL"
fi

# ===================== ETAPE 6 ================================
# Vérification structure projet (audit simple)
echo "[CHECK] Vérification de la structure du projet..."

REQUIRED_PATHS=("api" "k8s" "docker-compose.yml" "prometheus")

for path in "${REQUIRED_PATHS[@]}"; do
    if [ ! -e "$path" ]; then
        echo "[ERREUR] Élément manquant : $path"
        exit 1
    fi
done

echo "[CHECK] Structure du projet conforme"

# ===================== ETAPE 7 ================================
# Ajout & commit
echo "[GIT] Ajout des fichiers..."
git add .

if git diff-index --quiet HEAD --; then
    echo "[GIT] Aucun changement à commit"
else
    COMMIT_MSG="Cyber-DevOps Lab deployment - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "[GIT] Commit : $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
fi

# ===================== ETAPE 8 ================================
# Push GitHub
echo "[GIT] Push vers GitHub..."
git push -u origin "$BRANCH"

# ===================== FIN ================================
echo ""
echo "============================================================"
echo "Déploiement terminé avec succès ✅"
echo "Projet : $REPO_NAME"
echo "GitHub : https://github.com/${GIT_USER}/${REPO_NAME}"
echo "Date   : $(date)"
echo "============================================================"
