# 📦 Terraform Modules for Proxmox

Repozytorium biblioteczne zawierające reużywalne, uniwersalne moduły Terraform przeznaczone do zarządzania infrastrukturą w środowisku Proxmox Virtual Environment (PVE).

> **Ważne:** To repozytorium zawiera **wyłącznie logikę tworzenia zasobów**. Nie przechowuje ono żadnego stanu (`.tfstate`) ani konfiguracji dla konkretnych środowisk. Rzeczywista infrastruktura (parametry, adresacja IP, wywołania modułów) zarządzana jest w repozytorium docelowym, `proxmox-infrastructure`: https://github.com/skni-kod/proxmox-infrastructure

## 🛠️ Stack Technologiczny

- **Terraform:** `>= 1.5.0`
- **Provider Proxmox:** [bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest)

## 📂 Struktura Repozytorium

Repozytorium jest logicznie podzielone na katalogi z modułami. Każdy moduł to niezależny komponent realizujący konkretne zadanie (np. utworzenie wirtualnej maszyny z Cloud-Init).

```text
terraform-modules/
|── .github/workflows         # Workflow'y CI/CD
│      ├── verification.yml   # Pipeline weryfikacyjny
│      └── release.yml        # Release nowego tagu
├── proxmox-vm/               # 1 moduł: Moduł tworzący pojedynczą maszynę wirtualną
│      ├── main.tf            # Główna logika (zasoby bpg/proxmox)
│      └── variables.tf       # Definicje parametrów wejściowych
└── README.md
```

## 🚀 Jak używać modułów?

Inne repozytoria (np. środowisko docelowe `proxmox-infrastructure`) pobierają moduły bezpośrednio z GitHuba, wskazując odpowiedni tag (wersję).

Przykład użycia modułu `proxmox-vm` w zewnętrznym repozytorium:

```hcl
module "k8s_master" {
  # Pobieranie modułu prosto z repozytorium ze wskazaniem konkretnej wersji (ref)
  source = "git::https://github.com/skni-kod/terraform-modules.git//modules/proxmox-vm?ref=v1.2.0"

  # Parametry wejściowe zdefiniowane w variables.tf modułu
  node_name    = "pve-01"
  vm_name      = "k8s-master-1"
  cpu_cores    = 4
  memory       = 4096
  ipv4_address = "192.168.1.10/24"
  ipv4_gateway = "192.168.1.1"

  # Tagi kluczowe dla dynamicznego inwentarza Ansible
  tags = ["k8s-master", "ubuntu"]
}
```

## 🔄 Sposób Pracy (Workflow CI/CD)

Repozytorium jest w pełni zautomatyzowane za pomocą GitHub Actions. Proces tworzenia i wdrażania zmian składa się z dwóch głównych etapów: walidacji kodu przed scaleniem (CI) oraz automatycznej publikacji nowej wersji (CD).

### 1. Weryfikacja kodu (Continuous Integration)

Po otwarciu Pull Requesta do gałęzi `main`, automatycznie uruchamia się workflow **Terraform Modules CI**. Dba on o spójność i poprawność modułów:

- **Check formatting:** Weryfikuje, czy cały kod HCL jest poprawnie sformatowany (zgodnie ze standardem `terraform fmt`).
- **Init & Validate Modules:** Skrypt automatycznie wykrywa wszystkie katalogi zawierające plik `main.tf`. W każdym z nich uruchamia `terraform init -backend=false` (inicjalizacja bez łączenia ze zdalnym stanem) oraz `terraform validate` (weryfikacja składni i zależności zmiennych).

Jeśli którykolwiek z modułów nie przejdzie walidacji, Pull Request zostanie zablokowany.

### 2. Publikacja po merge'u (Continuous Deployment)

Kiedy kod przejdzie Code Review i zostanie zmergowany do `main`, uruchamia się workflow **Terraform Modules CD**.

- **Automatyczne tagowanie:** Potok analizuje historię commitów i automatycznie podbija wersję (generuje nowy tag).
- **GitHub Release:** Na podstawie historii zmian generowany jest czytelny changelog (lista wprowadzonych zmian) i tworzone jest nowe wydanie (Release) w zakładce repozytorium.

---

## 📝 Konwencja Commitów (Conventional Commits)

Ponieważ workflow CD automatycznie nadaje numery wersji (Semantic Versioning), **bardzo ważne jest odpowiednie nazywanie commitów**. Używamy standardu _Conventional Commits_, który informuje mechanizm o tym, jak bardzo podbić numer nowej wersji.

Każdy commit (lub tytuł Pull Requesta przy squashowaniu) powinien zaczynać się od jednego z poniższych przedrostków:

- **`feat!:`** lub **`fix!:`** (z wykrzyknikiem) – Wprowadza zmiany niekompatybilne wstecz (Breaking Change).
  - _Skutek:_ Podbicie wersji **MAJOR** (np. z `v1.2.3` na `v2.0.0`).
  - _Przykład:_ `feat!: zmiana struktury zmiennych wymaganych przez moduł maszyny`
- **`feat:`** – Dodanie nowej funkcjonalności do modułu.
  - _Skutek:_ Podbicie wersji **MINOR** (np. z `v1.2.3` na `v1.3.0`).
  - _Przykład:_ `feat: dodanie wsparcia dla dodatkowych dysków w proxmox-vm`
- **`fix:`** – Naprawa błędu w istniejącym module.
  - _Skutek:_ Podbicie wersji **PATCH** (np. z `v1.2.3` na `v1.2.4`).
  - _Przykład:_ `fix: poprawka literówki w tagach inwentarza`

**Dodatkowe przedrostki (nie wpływające zazwyczaj na numerację, ułatwiające zarządzanie kodem):**

- **`docs:`** – Zmiany wyłącznie w dokumentacji (np. aktualizacja README).
- **`chore:`** – Zmiany w konfiguracji repozytorium, potokach CI/CD lub zależnościach zewnętrznych (nie dotyczące samego kodu HCL).
- **`refactor:`** – Zmiany w kodzie poprawiające jego czytelność, ale nie dodające nowych funkcji ani nie naprawiające błędów.
