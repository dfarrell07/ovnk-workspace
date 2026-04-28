# OVN-Kubernetes Workspace

Multi-repo workspace for OVN-Kubernetes (ovnk) CI, AI, and docs automation.
This directory is a git repo tracking workspace-level files only -- the 36
cloned sub-repos are managed independently. For repo-specific agent guidance,
check for AGENTS.md inside each repo.

Repos with AGENTS.md: ai-helpers, kubernetes-mcp-server, openshift-ci-mcp, rebasebot, sippy.
Repos with .claude/ commands or skills: ci-tools, enhancements, openshift-ci-mcp, sippy.

## Upstream vs Downstream

ovn-kubernetes/ is upstream (ovn-org/ovn-kubernetes) -- community project, GitHub Actions CI.
ovn-kubernetes-ds/ is downstream (openshift/ovn-kubernetes) -- Prow CI via openshift/release.
Downstream adds: Dockerfile, Dockerfile.base, Dockerfile.microshift, Dockerfile.utest,
and an openshift/ directory with OTE (ovn-kubernetes-tests-ext) code.

rebasebot syncs upstream -> downstream via automated rebase PRs.

Note: upstream ovnk has no CLAUDE.md yet. PR #5597 (by abhat) is stalled -- maintainer
trozet requested a vendor-neutral name. Convention in openshift-eng: AGENTS.md symlinked
to CLAUDE.md.

## Repo Map

### Core

```text
ovn-kubernetes                   ovn-org         Upstream ovnk controller + CNI plugin (Go)
ovn-kubernetes-ds                openshift       Downstream fork with OpenShift integration
cluster-network-operator         openshift       Deploys and configures ovnk on OpenShift
cloud-network-config-controller  openshift       Cloud EgressIP management (AWS/Azure/GCP)
multus-cni                       openshift       Meta-CNI for multiple network interfaces
network-tools                    openshift       Debug tools + Claude Code JIRA labeling (PR #168)
openshift-api                    openshift       OpenShift API types and feature gates
```

### Networking Stack

```text
ovn                              ovn-org         OVN virtual network control plane (C)
ovs                              openvswitch     Open vSwitch datapath (C)
libovsdb                         ovn-kubernetes  Go OVSDB client library (236 files import it)
frr-k8s                          metallb         FRR routing for BGP/EVPN integration
network-policy-api               kubernetes-sigs  NetworkPolicy v2 API (AdminNetworkPolicy)
```

### CI and Testing

```text
ci-tools                         openshift       ci-operator engine and tooling
ci-docs                          openshift       OpenShift CI system documentation
ci-test-mapping                  openshift-eng   Maps tests to components for readiness tracking
sippy                            openshift       CI analytics dashboard (job/test pass rates)
openshift-ci-mcp                 openshift-eng   MCP server for Sippy/Search.CI/Release Controller
gangway-cli                      openshift-eng   CLI for triggering Prow jobs via API
origin                           openshift       openshift-tests binary and networking e2e suites
openshift-tests-extension        openshift-eng   Framework for decentralized OCP test contributions
kubernetes-traffic-flow-tests    ovn-kubernetes  Network connectivity test suite (Python)
ovn-fake-multinode               ovn-org         Simulated multi-chassis OVN for testing
ovn-heater                       ovn-org         OVN scale/performance test framework
rebasebot                        openshift-eng   Automated upstream -> downstream sync (Python)
openshift-release                openshift       Prow job definitions and step registry
```

### Docs and Design

```text
openshift-docs                   openshift       OCP product documentation (AsciiDoc)
enhancements                     openshift       OpenShift enhancement proposals
kubernetes-enhancements          kubernetes      Upstream Kubernetes KEPs
ovn-website                      ovn-org         OVN project website (Hugo)
runbooks                         openshift       Alert runbooks for OCP operators
```

### AI and Automation

```text
ovn-kubernetes-mcp               ovn-kubernetes  MCP server for ovnk troubleshooting (OKEP-5494)
ai-helpers                       openshift-eng   Claude Code plugin marketplace (35+ plugins)
kubernetes-mcp-server            containers      General K8s/OpenShift MCP server (1.5k stars)
ocp-performance-analyzer-mcp     openshift-eng   MCP for OCP performance analysis
kube-agentic-networking          kubernetes-sigs  Network APIs for AI agent communication
```

### Release

```text
ocp-build-data                   openshift-eng   ART image/RPM build configs per OCP version
```

## Cross-Repo Dependencies (A -> B means B builds on A)

ovs -> ovn -> libovsdb -> ovn-kubernetes -> ovn-kubernetes-ds -> cluster-network-operator
                                        -> ovn-kubernetes-mcp
frr-k8s, network-policy-api, multus-cni -> ovn-kubernetes (go.mod)
openshift-api -> ovn-kubernetes-ds (go.mod)
rebasebot: ovn-org/ovn-kubernetes -> openshift/ovn-kubernetes (automated sync)
openshift/release -> downstream CI (ci-operator configs define Prow jobs)
ocp-build-data -> downstream images (ART configs define OCP release builds)

## CI Systems

Upstream (ovn-org/ovn-kubernetes):
  GitHub Actions in .github/workflows/ (test.yml, docker.yml, docs.yml, performance-test.yml)

Downstream (openshift/ovn-kubernetes):
  Prow + ci-operator. Configs at openshift-release/ci-operator/config/openshift/ovn-kubernetes/
  Jobs at openshift-release/ci-operator/jobs/openshift/ovn-kubernetes/
  Dashboards: sippy.dptools.openshift.org | search.ci.openshift.org

Release builds:
  ART pipeline (ocp-build-data). Images: ose-ovn-kubernetes, ovn-kubernetes-base,
  ovn-kubernetes-microshift. ovnk does NOT use Konflux -- builds go through ART/Brew/OSBS.

## Entry Points

CI: Start with openshift-release/ci-operator/config/openshift/ovn-kubernetes/
    then sippy/ for analytics, ci-test-mapping/ for component readiness, gangway-cli/ to trigger jobs.

AI: ovn-kubernetes-mcp/ (maintainer: tssurya, dev: arkadeepsen), openshift-ci-mcp/ (21 tools),
    kubernetes-mcp-server/, ai-helpers/ (plugin marketplace), kube-agentic-networking/.

Docs: openshift-docs/ for product docs, ovn-website/ for upstream, enhancements/ for proposals,
      runbooks/ for alert handling.

## Key People

tssurya (Surya Seetharaman)  ovnk maintainer/approver, ovn-kubernetes-mcp lead
jluhrsen (Jamo Luhrsen)      downstream merges, CI infra, OTE tests
abhat (Aniket Bhat)          CLAUDE.md PR #5597 author, cloud-network-config-controller maintainer
arkadeepsen (Arkadeep Sen)   ovn-kubernetes-mcp primary developer (29 commits)
trozet (Tim Rozet)           ovnk maintainer (NVIDIA), requested vendor-neutral AI guide naming

## Workspace Tooling

repos.txt is the source of truth for all repos. Makefile delegates to scripts/.

make help        # list targets
make fetch       # git fetch --all --prune for every repo
make update      # fetch + fast-forward pull (skips dirty/non-default branches)
make clone-all   # clone missing repos from repos.txt
make sync        # clone-all + regenerate .gitignore

Adding a repo: edit repos.txt, run make sync.

## Useful Commands

```bash
# Find repos with agent guidance files
find ~/ovnk -maxdepth 2 -name "AGENTS.md" -o -name "CLAUDE.md" | sort

# Check upstream vs downstream drift
diff <(ls ~/ovnk/ovn-kubernetes/) <(ls ~/ovnk/ovn-kubernetes-ds/)

# Find CI config for a downstream repo
ls openshift-release/ci-operator/config/openshift/<repo-name>/

# Check repo maintainers
cat ~/ovnk/<repo-name>/OWNERS
```
