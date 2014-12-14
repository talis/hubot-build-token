# Hubot Build Token

A script package for Hubot, adding build token functionality.

This script was created at a Talis Hackday.

## Installation

In your hubot repository, run:

`npm install hubot-build-token --save`

Then add **hubot-build-token** to your `external-scripts.json`:

```json
["hubot-build-token"]
```

## Example interactions

Create a build token:

```
malcyl> create build token for cool_new_project
hubot> You have created a build token for cool_new_project
```

Check if anyone has a build token:

```
malcyl> who has the build token for cool_new_project
hubot> no one has the build token for cool_new_project
```

or f someone already has the build token:

```
malcyl> who has the build token for cool_new_project
hubot> kiyanwang has the build token for cool_new_project
```

Taking a build token:

```
malcyl> give me the build token for cool_new_project
hubot> You have the build token for cool_new_project
```

Releasing a build token:

```
malcyl> release the build token for cool_new_project
hubot> You have released the build token for cool_new_project
```
