<!--
    Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
    SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Features & Support

The vision for the Ghaf platform is to create a virtualized, scalable reference
platform that enables the building of secure products leveraging trusted,
reusable, and portable software for edge devices. For more information on
reference implementation for several devices, see [Reference
Implementations](/ref_impl/reference_implementations.md).

We are currently supporting different sets of features based on our different
reference devices and platforms.

## Status

- &#x2705;: Integrated & Tested in `main` branch.
- &#x1f6A7;: Prototyped or work-in-progress in a development branch/PR.
- &#x274C;: Not implemented yet, or has major regression or bugs.

## Reference Devices

Ghaf has been tested on these systems, with a reference implementation included
in the project's repository.

| Platform    | Edition     | Target Name          | Status   | Description                                   |
| ----------- | ----------- | -------------------- | -------- | --------------------------------------------- |
| Lenovo X1   | Gen 10 & 11 | `lenovo-x1`          | &#x2705; | For lightweight business laptop use-cases     |
| Jetson Orin | AGX & NX    | `nvidia-jetson-orin` | &#x2705; | For robotics & ML use-cases                   |
| VM          | (qemu)      | `vm`                 | &#x2705; | For testing on QEMU (no compartmentalization) |
| NXP i.MX8MP | EVK         | `nxp-imx8mp-evk`     | &#x2705; | Lightweight system                            |

For each platform, a `debug` and `release` version may be available. We aim to
make sure cross-compilation is supported for all packages included by default.

## Features Support

Different features may be supported on different platforms.

### Core Enablers

| Feature                              | Status    | Supported Platforms    | Details                                                   |
| ------------------------------------ | --------- | ---------------------- | --------------------------------------------------------- |
| Compartmentalization                 | &#x1f6A7; | Lenovo X1, Jetson Orin | With VMs for networking, GUI, and applications            |
| Minimal Host                         | &#x2705;  | All                    | See [Minimal Host](/architecture/adr/minimal-host.md) ADR |
| GUI VM                               | &#x2705;  | Lenovo X1              | With GPU passthrough & Wayland compositor                 |
| Network VM                           | &#x2705;  | Lenovo X1, Jetson Orin | With passthrough, supports Wi-Fi                          |
| IDS VM                               | &#x1f6A7; | Lenovo X1              | Intrusion Detection System                                |
| Application VMs                      | &#x2705;  | Lenovo X1              | Support depends on GUI VM                                 |
| Admin VM                             | &#x1f6A7; | Lenovo X1              | For system management                                     |
| SW Update                            | &#x274C;  | None Yet               | A/B update tooling being evaluated                        |
| PCI Passthrough                      | &#x2705;  | Lenovo X1, Jetson Orin | Implemented for networking, GPU (depending on platform)   |
| USB passthrough                      | &#x2705;  | Lenovo X1              | Implemented for webcam, fingerprint reader                |
| UART Passthrough                     | &#x2705;  | Jetson Orin            | No specific use-case implemented                          |
| ARM platform bus devices passthrough | &#x1f6A7; | Jetson Orin            | NVIDIA BPMP virtualization being developed                |
| Inter-VM Comms: VSOCK                | &#x2705;  | Lenovo X1, Jetson Orin | Used with Waypipe                                         |
| Inter-VM Comms: gRPC                 | &#x1f6A7; | Lenovo X1              | Under development for admin VM                            |
| Inter-VM Comms: Shared Memory        | &#x1f6A7; | None Yet               | For low latency IPC                                       |

### Core System

| Feature                 | Status    | Supported Platforms | Details                 |
| ----------------------- | --------- | ------------------- | ----------------------- |
| Secure Boot             | &#x1f6A7; | Lenovo X1           | Testing with Lanzaboote |
| VM Management Interface | &#x274C;  | None Yet            | System design phase     |
| Centralized Logging     | &#x1f6A7; | None Yet            | System design phase     |

### Available Graphical Applications

Currently, GUI is supported only on Lenovo X1 and Jetson Orin. These are
applications that are tested and included in the default builds.

| Feature              | Jetson Orin | Lenovo X1 |
| -------------------- | ----------- | --------- |
| Chromium             | &#x274C;    | &#x2705;  |
| Firefox              | &#x2705;    | &#x274C;  |
| Element              | &#x2705;    | &#x2705;  |
| AppFlowy             | &#x274C;    | &#x2705;  |
| GALA                 | &#x274C;    | &#x2705;  |
| Zathura (PDF Viewer) | &#x2705;    | &#x2705;  |

## Development

When using `-debug` variant of the system, these platforms will support SSH and
serial (if applicable). Developer should be able to remotely update the system
through `nixos-rebuild`.

| Feature                | Status   | Supported Platforms | Details                                                                           |
| ---------------------- | -------- | ------------------- | --------------------------------------------------------------------------------- |
| Quick Rebuild Switch   | &#x2705; | All                 | See [Development](/ref_impl/development.md)                                       |
| Jetson Device Flashing | &#x2705; | Jetson Orin         | See [Flashing Jetson](/ref_impl/build_and_run.md#flashing-nvidia-jetson-orin-agx) |
| Debug: SSH             | &#x2705; | All                 | Available only in `-debug` builds                                                 |
| Debug: Serial          | &#x2705; | Jetson Orin         | Available only in `-debug` builds                                                 |
