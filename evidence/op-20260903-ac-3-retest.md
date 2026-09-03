**Operational receipt**:  AC-3 runbook retest 20260903
https://github.com/the-metafactory/crucible/blob/main/docs/ac-3-runbook.md

This test captures the VM fingerprint in full pre-corpus and post-corpus to validate no drift.

**Note**: This is a re-test so the procedure begins with destroying the original VM

```sh
❯ source tofu.env

❯ mv inventory/ac3.yaml inventory/destroy/

❯ tofu apply
Acquiring state lock. This may take a few moments...
data.sops_file.secrets: Reading...
data.sops_file.secrets: Read complete after 0s [id=-]
data.proxmox_virtual_environment_nodes.available: Reading...
data.proxmox_virtual_environment_vms.all: Reading...
data.proxmox_virtual_environment_nodes.available: Read complete after 0s [id=nodes]
data.proxmox_virtual_environment_vms.all: Read complete after 0s [id=52a0c236-01b4-4957-8912-330abbc60087]
module.vm-pve["ac3"].proxmox_virtual_environment_vm.this: Refreshing state... [id=501]

OpenTofu used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  - destroy

OpenTofu will perform the following actions:

  # module.vm-pve["ac3"].proxmox_virtual_environment_vm.this will be destroyed
  # (because module.vm-pve["ac3"] is not in configuration)
  - resource "proxmox_virtual_environment_vm" "this" {
      <snip>

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ vms              = {
      - ac3 = {
          - ansible_roles    = [
              - "bun",
              - "claude",
              - "metafactory_arc",
              - "metafactory_cortex",
              - "assay_env",
            ]
          - ansible_user     = "ubuntu"
          - archive_snapshot = "20260721T000000Z"
          - ipv4_addresses   = [
              - "10.0.0.238",
            ]
          - packages         = [
              - "unzip",
              - "git",
            ]
          - ssh_command      = "ssh ubuntu@10.0.0.238"
          - timezone         = "Etc/UTC"
          - vm_id            = 501
        }
    }

Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.vm-pve["ac3"].proxmox_virtual_environment_vm.this: Destroying... [id=501]
module.vm-pve["ac3"].proxmox_virtual_environment_vm.this: Destruction complete after 3s

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.

Outputs:

nodes = tolist([
  "pve",
])
protected_vm_ids = tomap({
  <snip>
})
vms = {}

❯ mv inventory/destroy/ac3.yaml inventory/

❯ estrip inventory/ac3.yaml
vm_id: 501
description: "AC-3: the execution-boundary corpus on a factory VM"
cpu_cores: 4
memory_mb: 8192
disk_gb: 32
ipv4: dhcp
archive_snapshot: 20260721T000000Z
packages: [unzip, git]
ansible_roles: [bun, claude, metafactory_arc, metafactory_cortex, assay_env]
tags: ["ubuntu"]

❯ tofu apply
Acquiring state lock. This may take a few moments...
data.sops_file.secrets: Reading...
data.sops_file.secrets: Read complete after 0s [id=-]
data.proxmox_virtual_environment_nodes.available: Reading...
data.proxmox_virtual_environment_vms.all: Reading...
data.proxmox_virtual_environment_nodes.available: Read complete after 0s [id=nodes]
data.proxmox_virtual_environment_vms.all: Read complete after 0s [id=aa347f0d-cd4b-4341-b267-bd7784d650f0]

OpenTofu used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

OpenTofu will perform the following actions:

  # module.vm-pve["ac3"].proxmox_virtual_environment_vm.this will be created
  + resource "proxmox_virtual_environment_vm" "this" {
      <snip>

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  ~ vms              = {
      + ac3 = {
          + ansible_roles    = [
              + "bun",
              + "claude",
              + "metafactory_arc",
              + "metafactory_cortex",
              + "assay_env",
            ]
          + ansible_user     = "ubuntu"
          + archive_snapshot = "20260721T000000Z"
          + ipv4_addresses   = (known after apply)
          + packages         = [
              + "unzip",
              + "git",
            ]
          + ssh_command      = (known after apply)
          + timezone         = "Etc/UTC"
          + vm_id            = 501
        }
    }

Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.vm-pve["ac3"].proxmox_virtual_environment_vm.this: Creating...
module.vm-pve["ac3"].proxmox_virtual_environment_vm.this: Still creating... [10s elapsed]
module.vm-pve["ac3"].proxmox_virtual_environment_vm.this: Still creating... [20s elapsed]
module.vm-pve["ac3"].proxmox_virtual_environment_vm.this: Creation complete after 23s [id=501]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

nodes = tolist([
  "pve",
])
protected_vm_ids = tomap({
  <snip>
})
vms = {
  "ac3" = {
    "ansible_roles" = tolist([
      "bun",
      "claude",
      "metafactory_arc",
      "metafactory_cortex",
      "assay_env",
    ])
    "ansible_user" = "ubuntu"
    "archive_snapshot" = "20260721T000000Z"
    "ipv4_addresses" = [
      "10.0.0.240",
    ]
    "packages" = tolist([
      "unzip",
      "git",
    ])
    "ssh_command" = "ssh ubuntu@10.0.0.240"
    "timezone" = "Etc/UTC"
    "vm_id" = 501
  }
}

❯ ./scripts/check-ansible.sh
ok    collections (2 pinned)
ok    inventory (1 host(s))
ok    site.yaml syntax
ok    ansible-lint

❯ git ls-remote https://github.com/the-metafactory/cortex main
01f43bb9029e9fbcf8dffd6c99201001434e921f        refs/heads/main

❯ ansible-playbook ansible/site.yaml --limit ac3 \
  -e metafactory_cortex_pin=01f43bb9029e9fbcf8dffd6c99201001434e921f

PLAY [Apply the fleet baseline and each VM's declared roles] *******************************

TASK [Gathering Facts] *********************************************************************
ok: [ac3]

TASK [base : Pin apt to the spec's archive snapshot] ***************************************
changed: [ac3]

TASK [base : Remove the apt snapshot pin when the spec has none] ***************************
skipping: [ac3]

TASK [base : Zero the apt periodic jobs] ***************************************************
changed: [ac3]

TASK [base : Stop and disable the apt-daily timers] ****************************************
ok: [ac3] => (item=apt-daily.timer)
ok: [ac3] => (item=apt-daily-upgrade.timer)

TASK [base : Mask the apt-daily timers] ****************************************************
changed: [ac3] => (item=apt-daily.timer)
changed: [ac3] => (item=apt-daily-upgrade.timer)

TASK [base : Enforce key-only SSH] *********************************************************
changed: [ac3]

TASK [base : Check the assembled sshd config is valid] *************************************
ok: [ac3]

TASK [base : Set the timezone] *************************************************************
ok: [ac3]

TASK [base : Install the spec's packages] **************************************************
changed: [ac3]

TASK [Include each role the VM's spec declares] ********************************************
included: bun for ac3 => (item=bun)
included: claude for ac3 => (item=claude)
included: metafactory_arc for ac3 => (item=metafactory_arc)
included: metafactory_cortex for ac3 => (item=metafactory_cortex)
included: assay_env for ac3 => (item=assay_env)

TASK [bun : Add ~/.bun/bin to the interactive shell PATH] **********************************
changed: [ac3]

TASK [bun : Probe installed bun version] ***************************************************
ok: [ac3]

TASK [bun : Probe for unzip (unarchive needs it for .zip)] *********************************
ok: [ac3]

TASK [bun : Refuse to continue without unzip] **********************************************
skipping: [ac3]

TASK [bun : Create scratch directory] ******************************************************
changed: [ac3]

TASK [bun : Ensure ~/.bun/bin exists] ******************************************************
changed: [ac3]

TASK [bun : Download zip, verified against upstream SHASUMS256.txt] ************************
changed: [ac3]

TASK [bun : Unpack] ************************************************************************
changed: [ac3]

TASK [bun : Install binary] ****************************************************************
changed: [ac3]

TASK [bun : Remove scratch directory] ******************************************************
changed: [ac3]

TASK [claude : Probe installed claude version binary] **************************************
ok: [ac3]

TASK [claude : Probe ~/.local/bin/claude symlink] ******************************************
ok: [ac3]

TASK [claude : Create scratch directory] ***************************************************
changed: [ac3]

TASK [claude : Fetch release manifest] *****************************************************
ok: [ac3]

TASK [claude : Check the manifest checksum is a plausible SHA256] **************************
ok: [ac3] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [claude : Download binary, verified against the manifest checksum] ********************
changed: [ac3]

TASK [claude : Run the vendor installer] ***************************************************
changed: [ac3]

TASK [claude : Remove scratch directory] ***************************************************
changed: [ac3]

TASK [metafactory_arc : Probe for bun (cross-role dependency)] *****************************
ok: [ac3]

TASK [metafactory_arc : Refuse to continue without bun] ************************************
skipping: [ac3]

TASK [metafactory_arc : Probe for git (layer-1 dependency)] ********************************
ok: [ac3]

TASK [metafactory_arc : Refuse to continue without git] ************************************
skipping: [ac3]

TASK [metafactory_arc : Clone arc at the pinned tag] ***************************************
changed: [ac3]

TASK [metafactory_arc : Probe the arc link] ************************************************
ok: [ac3]

TASK [metafactory_arc : Install production dependencies] ***********************************
changed: [ac3]

TASK [metafactory_arc : Link arc into ~/.bun/bin] ******************************************
changed: [ac3]

TASK [metafactory_cortex : Refuse to install an unpinned target] ***************************
ok: [ac3]

TASK [metafactory_cortex : Refuse a pin that is not a full commit SHA] *********************
ok: [ac3]

TASK [metafactory_cortex : Probe for arc (cross-role dependency)] **************************
ok: [ac3]

TASK [metafactory_cortex : Refuse to continue without a working arc] ***********************
skipping: [ac3]

TASK [metafactory_cortex : Probe for git (layer-1 dependency)] *****************************
ok: [ac3]

TASK [metafactory_cortex : Refuse to continue without git] *********************************
skipping: [ac3]

TASK [metafactory_cortex : Ask arc which packages it already has] **************************
ok: [ac3]

TASK [metafactory_cortex : Note where arc says the target is checked out, if anywhere] *****
ok: [ac3]

TASK [metafactory_cortex : Read the HEAD of the checkout arc already has] ******************
skipping: [ac3]

TASK [metafactory_cortex : Refuse to re-pin a checkout arc will not move] ******************
skipping: [ac3]

TASK [metafactory_cortex : Note whether this run would install the target] *****************
ok: [ac3]

TASK [metafactory_cortex : Install the declared commit of cortex] **************************
changed: [ac3]

TASK [metafactory_cortex : Ask arc again where the target is checked out] ******************
ok: [ac3]

TASK [metafactory_cortex : Note the installed checkout's path] *****************************
ok: [ac3]

TASK [metafactory_cortex : Refuse to report a commit for a checkout that is not there] *****
skipping: [ac3]

TASK [metafactory_cortex : Read the installed checkout's HEAD] *****************************
ok: [ac3]

TASK [metafactory_cortex : Read whether the installed checkout has been modified] **********
ok: [ac3]

TASK [metafactory_cortex : Assert the installed commit is the declared pin] ****************
ok: [ac3]

TASK [metafactory_cortex : Assert the installed checkout is unmodified] ********************
ok: [ac3]

TASK [metafactory_cortex : Record the verified commit for the smoke loop] ******************
ok: [ac3]

TASK [metafactory_cortex : Report the install this dry run would have performed] ***********
skipping: [ac3]

TASK [assay_env : Refuse to capture without a capture path] ********************************
skipping: [ac3]

TASK [assay_env : Probe for the capture script on the control node] ************************
ok: [ac3 -> localhost]

TASK [assay_env : Refuse to continue without the capture script] ***************************
skipping: [ac3]

TASK [assay_env : Refuse to continue without an address and login user for the guest] ******
skipping: [ac3]

TASK [assay_env : Capture the guest's fingerprint from the control node] *******************
ok: [ac3 -> localhost]

TASK [assay_env : Extract the digests from the capture's DIGESTS block] ********************
ok: [ac3]

TASK [assay_env : Refuse to write a partial environment file] ******************************
skipping: [ac3]

TASK [assay_env : Create the interchange directory] ****************************************
changed: [ac3]

TASK [assay_env : Assemble the interchange document] ***************************************
ok: [ac3]

TASK [assay_env : Write the assay environment file] ****************************************
changed: [ac3]

RUNNING HANDLER [base : Reload sshd] *******************************************************
changed: [ac3]

PLAY RECAP *********************************************************************************
ac3                        : ok=59   changed=23   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0


❯ scripts/vm-fingerprint.sh ubuntu@10.0.0.240 fingerprints/ac3-20260903-pre-corpus.txt
fingerprint written to fingerprints/ac3-20260903-pre-corpus.txt
##### DIGESTS #####
core      sha256:e371373de3df3a9c27f8a21884ccd384e0b4596af7bad725aa3b5b31f88d905d
provider  sha256:942565ef5b549af6f578e78bf5a3eaa9ead49220e21443f9a2ea8840abf7dd70
combined  sha256:83e765759e727c15767a9c64dcbc355c6b7e8c97471a7e0e069cf4c839c1d7e8

❯ ssh ubuntu@10.0.0.240 cat /etc/assay/environment.json
{
    "core_digest": "sha256:e371373de3df3a9c27f8a21884ccd384e0b4596af7bad725aa3b5b31f88d905d",
    "definition": "inventory/ac3.yaml",
    "provider": "proxmox-ve",
    "provider_digest": "sha256:942565ef5b549af6f578e78bf5a3eaa9ead49220e21443f9a2ea8840abf7dd70",
    "schema": 1
}

❯

❯ ssh ubuntu@10.0.0.240
Welcome to Ubuntu 26.04 LTS (GNU/Linux 7.0.0-28-generic x86_64)

 * Documentation:  https://docs.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Sep  3 21:49:17 UTC 2026

  System load:           0.09
  Usage of /:            9.6% of 29.89GB
  Memory usage:          4%
  Swap usage:            0%
  Processes:             141
  Users logged in:       0
  IPv4 address for eth0: 10.0.0.240
  IPv6 address for eth0: 2600:1702:<snip>
  IPv6 address for eth0: 2600:1702:<snip>


Expanded Security Maintenance for Applications is not enabled.

3 updates can be applied immediately.
3 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


ubuntu@ac3:~$ pwd
/home/ubuntu
ubuntu@ac3:~$ git clone https://github.com/the-metafactory/assay
Cloning into 'assay'...
remote: Enumerating objects: 233, done.
remote: Counting objects: 100% (233/233), done.
remote: Compressing objects: 100% (134/134), done.
remote: Total 233 (delta 114), reused 186 (delta 91), pack-reused 0 (from 0)
Receiving objects: 100% (233/233), 2.34 MiB | 6.89 MiB/s, done.
Resolving deltas: 100% (114/114), done.
ubuntu@ac3:~$ git -C assay checkout 81778d2cbcce5d3cd49441ba6d9cdf602d212fdc
Note: switching to '81778d2cbcce5d3cd49441ba6d9cdf602d212fdc'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at 81778d2 docs: add the process diagram to the worked example (#35)
ubuntu@ac3:~$ cd assay
ubuntu@ac3:~/assay$ bun install --frozen-lockfile
bun install v1.3.14 (0d9b296a)

+ @types/bun@1.3.14
+ typescript@5.9.3

5 packages installed [6.00ms]
ubuntu@ac3:~/assay$
ubuntu@ac3:~/assay$ arc list --json
{
  "packages": [
    {
      "name": "cortex",
      "version": "6.13.4",
      "type": "component",
      "status": "active",
      "tier": "community",
      "repoUrl": "https://github.com/the-metafactory/cortex",
      "installPath": "/home/ubuntu/.local/share/metafactory/arc/repos/cortex"
    },
    {
      "name": "metafactory-cortex-adapter-discord",
      "version": "0.2.0",
      "type": "component",
      "status": "active",
      "tier": "custom",
      "repoUrl": "https://github.com/the-metafactory/metafactory-cortex-adapter-discord",
      "installPath": "/home/ubuntu/.local/share/metafactory/arc/repos/metafactory-cortex-adapter-discord"
    },
    {
      "name": "metafactory-cortex-adapter-mattermost",
      "version": "0.1.0",
      "type": "component",
      "status": "active",
      "tier": "custom",
      "repoUrl": "https://github.com/the-metafactory/metafactory-cortex-adapter-mattermost",
      "installPath": "/home/ubuntu/.local/share/metafactory/arc/repos/metafactory-cortex-adapter-mattermost"
    },
    {
      "name": "metafactory-cortex-adapter-slack",
      "version": "0.1.0",
      "type": "component",
      "status": "active",
      "tier": "custom",
      "repoUrl": "https://github.com/the-metafactory/metafactory-cortex-adapter-slack",
      "installPath": "/home/ubuntu/.local/share/metafactory/arc/repos/metafactory-cortex-adapter-slack"
    },
    {
      "name": "metafactory-cortex-adapter-web",
      "version": "0.1.0",
      "type": "component",
      "status": "active",
      "tier": "custom",
      "repoUrl": "https://github.com/the-metafactory/metafactory-cortex-adapter-web",
      "installPath": "/home/ubuntu/.local/share/metafactory/arc/repos/metafactory-cortex-adapter-web"
    },
    {
      "name": "metafactory-cortex-renderer-pagerduty",
      "version": "0.1.0",
      "type": "component",
      "status": "active",
      "tier": "custom",
      "repoUrl": "https://github.com/the-metafactory/metafactory-cortex-renderer-pagerduty",
      "installPath": "/home/ubuntu/.local/share/metafactory/arc/repos/metafactory-cortex-renderer-pagerduty"
    }
  ]
}
ubuntu@ac3:~/assay$ ASSAY_CORTEX_REPO_PATH=$HOME/.local/share/metafactory/arc/repos/cortex bun run eval:execution-boundary
$ bun run evals/execution-boundary/runner.ts
execution-boundary corpus — 12 case(s)
environment: linux/x64  kernel 7.0.0-28-generic  bun 1.3.14  cortex@01f43bb9029e  env@e371373de3df
substrate:   unknown  (no reliable substrate signal found in the environment. Only Claude Code's CLAUDECODE=1 is currently checked here — no confirmed env-var/marker is known for the other SubstrateId values (bus-peer, openai-codex, cursor, gemini, mistral, pi-dev, agent-team, api-agent). Recorded as unknown rather than assumed, per this corpus's no-guessing rule.)
captured:    2026-09-03T21:50:35.116Z

[PASS] r1-f1  (round 1, documented status: fixed)
       path-guard.hook.ts denied the out-of-scope Read and bash-guard.hook.ts denied the out-of-scope `cat` — the F1 fix (cortex-owned PreToolUse containment) holds.

[PASS] r1-f2  (round 1, documented status: accepted-residual)
       ADR-0024 D4 still discloses the accepted residual verbatim (full daemon authority; compat gate is not a security gate). F2 remains accurately documented as accepted.

[PASS] r1-f3  (round 1, documented status: fixed)
       src/cortex.ts resolves policy.sovereignty.enforce (default false) once and threads it to 2 consumer construction site(s) (>=2 expected) — the review-consumer/brain-consumer asymmetry EBH-6 found is closed.

[PASS] r1-f4  (round 1, documented status: fixed)
       guard-off (disabled:true) session still denies an out-of-scope `cat`, and still lets an uncataloged in-scope command (`sort`) through un-denied — the F4 fix holds without regressing G-300.

[PASS] r1-f5  (round 1, documented status: fixed)
       loader.ts still carries the org-trust gate, the explicit un-spoofable first-party exemption, and the TOCTOU-closing frozen export copy — the properties this review credited are still present.

[PASS] r1-f6  (round 1, documented status: fixed)
       Write into a readOnlyDirs-scoped path is denied; Read of the same path is not — F6 fix holds (read-only is deterministic, not prose).

[PASS] r2-f1  (round 2, documented status: fixed)
       decidePath denies the Write into the nested readOnlyDirs entry: "[Cortex Path Guard] Blocked Write "/tmp/assay-r2f1-6UV4eR/repo/.claude/settings.json": this path is inside a READ-ONLY directory — writes are refused (closes F6, docs/security/reviews/2026-07-23-nws-security-review.md). Reads remain permitted."

[PASS] r2-f2  (round 2, documented status: fixed)
       parsePathGuardConfig treats the malformed field as a genuine failure: "CORTEX_PATH_GUARD.allowedDirs must be an array of strings (got string)"

[PASS] r2-f3  (round 2, documented status: open)
       bash-guard.hook.ts grants "GIT_PAGER=/bin/sh git log" without ever inspecting the stripped GIT_PAGER assignment — the modeling gap NWS described still reproduces (status: open). This does NOT confirm the env var is actually invoked as a shell by the downstream tool (that half remains unverified, per the finding's own conditional severity) — it confirms only that cortex's own guard classifies and grants the command unexamined.

[PASS] r2-f4  (round 2, documented status: open)
       both repro shapes still reproduce (status: open): dot-collision allow=true, double-underscore-collision allow=true.

[PASS] r2-f5  (round 2, documented status: open)
       decidePath allows a Write to a boundary-weakening path (.claude/settings.json) with no denylist protecting it — the round-2 F5 finding still reproduces (status: open).

[PASS] r2-f6  (round 2, documented status: open)
       path-guard.hook.ts auto-grants a path-less Grep despite an out-of-scope cwd — the round-2 F6 finding still reproduces (status: open).

────────────────────────────────────────────────────────────────────────
CORPUS INTEGRITY  12/12 behaved as documented   (fail=0 skip=0)
SECURITY POSTURE  ⚠️  4 finding(s) STILL OPEN — r2-f3, r2-f4, r2-f5, r2-f6
                  those cases PASS *because* the vulnerability still reproduces.
By documented status: fixed=7  accepted-residual=1  open=4
ENVIRONMENT DRIFT ⚠️  12 case(s) with an UNPINNED baseline (captured_on never recorded a comparable environment or substrate) — r1-f1, r1-f2, r1-f3, r1-f4, r1-f5, r1-f6, r2-f1, r2-f2, r2-f3, r2-f4, r2-f5, r2-f6
ubuntu@ac3:~/assay$
ubuntu@ac3:~/assay$
ubuntu@ac3:~/assay$ grep core_digest /etc/assay/environment.json
    "core_digest": "sha256:e371373de3df3a9c27f8a21884ccd384e0b4596af7bad725aa3b5b31f88d905d",
ubuntu@ac3:~/assay$ exit
logout
Connection to 10.0.0.240 closed.

❯ scripts/vm-fingerprint.sh ubuntu@10.0.0.240 fingerprints/ac3-20260903-post-corpus.txt
fingerprint written to fingerprints/ac3-20260903-post-corpus.txt
##### DIGESTS #####
core      sha256:e371373de3df3a9c27f8a21884ccd384e0b4596af7bad725aa3b5b31f88d905d
provider  sha256:942565ef5b549af6f578e78bf5a3eaa9ead49220e21443f9a2ea8840abf7dd70
combined  sha256:83e765759e727c15767a9c64dcbc355c6b7e8c97471a7e0e069cf4c839c1d7e8

❯ diff fingerprints/ac3-20260903-pre-corpus.txt fingerprints/ac3-20260903-post-corpus.txt

❯

# Comparison to yesterday's fingerprint

❯ diff fingerprints/ac3-20260903-post-corpus.txt fingerprints/ac3.txt

❯
```

