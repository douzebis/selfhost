+++
title = "Killy - Age Key Management"
+++

# Killy - Age Key Management

## Creating Age Keys Securely

This guide describes how to safely create and encrypt age keys for use with sops.

### Prerequisites

- `age` command-line tool installed
- A secure location to store your keys (e.g., `./killy/` directory)

### Procedure

#### All-in-One Secure Method (Recommended)

This method ensures the unencrypted private key **never exists on the filesystem**:

```bash
mkdir -p ./killy
age-keygen | tee >(age-keygen -y > ./killy/age.pub) | \
  age --encrypt --passphrase --output ./killy/age.key.enc
```

**What this does:**
1. `age-keygen` generates a new key pair and outputs to stdout
2. `tee` splits the output:
   - One copy goes to `age-keygen -y` which converts the identity to a recipient (public key only) and saves to `./killy/age.pub`
   - The original output (including private key) is piped to `age --encrypt`
3. `age --encrypt --passphrase` encrypts the private key with your passphrase and saves to `./killy/age.key.enc`
4. The plaintext private key never touches the disk

**Why use `age-keygen -y`?**
- The `-y` flag converts an identity file to a recipients file (public key)
- It's the official, robust way to extract the public key
- No fragile text parsing needed

You will be prompted to enter and confirm a strong passphrase. **Remember this passphrase** - you'll need it to decrypt the key later.

#### Verify Your Setup

You should now have:
- `./killy/age.pub` - Your public key (can be shared)
- `./killy/age.key.enc` - Your encrypted private key (protected by passphrase)

### Using the Encrypted Key

When you need to use the encrypted private key with sops:

#### Method 1: Using a Secure RAM Disk (Recommended)

If you have a secure RAM disk configured (e.g., `/run/sops-tmp` on NixOS):

```bash
# Decrypt to RAM disk (cleared on reboot)
age --decrypt ./killy/age.key.enc > /run/sops-tmp/age.key

# Use with sops
SOPS_AGE_KEY_FILE=/run/sops-tmp/age.key sops edit secrets.yaml

# Securely remove when done
shred -u /run/sops-tmp/age.key
```

#### Method 2: One-Shot Decryption

For a single sops operation without writing the key to disk:

```bash
SOPS_AGE_KEY=<(age --decrypt ./killy/age.key.enc) sops edit secrets.yaml
```

This uses process substitution to decrypt the key in memory without creating a temporary file.

#### Method 3: Using /tmp (Less Secure)

If neither of the above is available:

```bash
# Decrypt to /tmp
age --decrypt ./killy/age.key.enc > /tmp/age.key

# Use with sops
SOPS_AGE_KEY_FILE=/tmp/age.key sops edit secrets.yaml

# Securely remove
shred -u /tmp/age.key
```

### Security Best Practices

- **Never commit** `age.key` or `age.key.enc` to version control
- Use a strong, unique passphrase for encryption
- Store the passphrase securely (e.g., in a password manager)
- Keep backups of `age.key.enc` in a secure location
- The public key (`age.pub`) can be safely committed to version control
