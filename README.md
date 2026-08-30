# Exam Collector

Automated exam file collection system for Windows computer labs using Ansible.

## Project Overview

Exam Collector is a DevOps automation project designed to collect student exam files automatically from Windows workstations at the end of an exam.

During an exam, each student saves their work under a folder on the local D: drive:

```text
D:\<Student Name> <Student ID>
```

Example:

```text
D:\Aviv Moshe 233211233
```

At the end of the exam, the system automatically connects to the Windows workstations, closes configured exam applications, discovers the student folder, collects the exam files, stores them centrally, and creates a collection report.

## Problem

Manual exam collection from many classroom computers is:

- Time consuming
- Prone to human error
- Difficult to verify
- Difficult to scale across many workstations

The goal of this project is to automate and standardize the collection process.

## Architecture

```text
                         Debian Linux
                    Ansible Control Node
                            |
                            |
                     schedule-exam.sh
                            |
                           cron
                            |
                     run-collector.sh
                            |
                      Ansible Playbook
                            |
                  -----------------------
                  |                     |
                WinRM                 WinRM
                  |                     |
            Windows PC 1          Windows PC 2
                  |                     |
          D:\Student ID           D:\Student ID
                  |                     |
                  -----------+-----------
                              |
                         File Collection
                              |
                              v
                    Central Debian Storage
                         collected/
                              |
                              v
                           reports/
```

## Main Technologies

### Ansible

Ansible is the orchestration layer of the project.

It allows one Linux controller to manage multiple Windows workstations from a central location.

The Windows computers are defined in an Ansible inventory, while the exam collection workflow is implemented as a reusable Ansible Role.

### WinRM

WinRM (Windows Remote Management) is used by Ansible to remotely execute tasks on the Windows workstations.

The project currently uses:

```text
WinRM
Port 5985
NTLM authentication
```

### PowerShell

PowerShell commands are executed remotely by Ansible for Windows-specific operations such as detecting and closing exam applications.

### Cron

Cron is used as the scheduler for the POC.

The exam administrator can schedule the collection process to start automatically at the exam end time.

### Ansible Vault

Sensitive Windows credentials are stored using Ansible Vault instead of being stored directly in the project files.

The Vault password file is kept locally on the Ansible controller and excluded from Git.

## Project Structure

```text
exam-collector/
├── collect-exams.yml
├── run-collector.sh
├── schedule-exam.sh
├── inventory.example.ini
├── inventory.ini
├── inventory-home.ini
├── group_vars/
│   └── windows/
│       └── vault.yml
├── roles/
│   └── exam_collector/
│       ├── defaults/
│       │   └── main.yml
│       └── tasks/
│           └── main.yml
├── collected/
├── reports/
└── .gitignore
```

Local inventories, collected student files, reports, logs, and the Vault password file are excluded from Git where appropriate.

## Collection Workflow

```text
Exam ends
    |
    v
Scheduler starts the collection
    |
    v
Ansible connects to Windows workstations using WinRM
    |
    v
Configured exam applications are closed
    |
    v
Search D: for the student exam folder
    |
    v
Find exam files recursively
    |
    v
Calculate number of files and total size
    |
    v
Fetch files to the Debian controller
    |
    v
Generate collection report
    |
    v
SUCCESS / WARNING
```

## Supported Exam Applications

The current configuration checks for the following processes:

```text
Foxit PDF Reader
Adobe Reader
AutoCAD
SketchUp
```

The application list can be changed in:

```text
roles/exam_collector/defaults/main.yml
```

## Student Folder Detection

The system searches directly under the D: drive for a student folder whose name ends with a 9-digit student ID.

Example:

```text
D:\Student Name 123456789
```

## Running the Collector

Home test environment:

```bash
./run-collector.sh home
```

Lab environment:

```bash
./run-collector.sh lab
```

## Scheduling an Exam Collection

Example:

```bash
./schedule-exam.sh lab 14:30
```

This schedules the collection process using cron.

In the current POC, scheduled cron entries should be removed manually after the exam.

## Reports

A report is generated for every workstation.

Example:

```text
Exam Collection Report
======================
Computer: home-test
Student folders found: 1
Exam files found: 1
Total size: 4 bytes
Collection status: SUCCESS - Exam files collected successfully
```

Possible statuses include:

```text
SUCCESS - Exam files collected successfully

WARNING - Student folder not found!

WARNING - Student folder is empty!
```

## Reliability Tests

The project was tested against several scenarios.

### Normal Collection

```text
Computer reachable
Student folder exists
Exam files exist
Result: SUCCESS
```

### Workstation Unavailable

An unreachable workstation does not prevent collection from the remaining available computers.

```text
PC-1 -> SUCCESS
PC-2 -> UNREACHABLE
PC-3 -> SUCCESS
```

### Student Folder Missing

```text
Student folders found: 0
Exam files found: 0
Result: WARNING
```

### Empty Student Folder

```text
Student folders found: 1
Exam files found: 0
Result: WARNING
```

## Security

The project uses Ansible Vault to protect credentials.

Sensitive local files are excluded using `.gitignore`.

The Vault password file has restricted Linux permissions:

```text
chmod 600 .vault_pass
```

For a production environment, additional improvements could include HTTPS WinRM, Kerberos/domain authentication, AWX credential management, or an external secrets manager.

## Current POC Limitations

The current implementation intentionally keeps several areas simple:

- Exam applications are stopped after students are expected to save their work.
- Cron entries are manually removed after scheduled exams.
- File collection currently uses a flat destination structure.
- Duplicate filenames located in different nested directories may require additional handling.
- Reports currently represent the latest collection result per workstation.

## Future Improvements

Possible future improvements include:

- Preserve the complete student directory structure
- Protect against duplicate filenames
- Generate historical reports per exam
- Create a central summary report for all workstations
- Add file checksums for integrity verification
- Use a production one-shot scheduler
- Improve graceful application shutdown
- Use HTTPS/Kerberos for WinRM
- Integrate AWX or another centralized automation platform

## DevOps Concepts Demonstrated

This project demonstrates:

- Infrastructure automation
- Centralized orchestration
- Configuration management
- Reusable Ansible Roles
- Windows automation using WinRM and PowerShell
- Scheduling
- Secrets management
- Logging and reporting
- Fault isolation
- Git version control
- Testing and validation
