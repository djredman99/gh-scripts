Developers:
- The URL for GitHub will be changing from an on-prem GitHub Server to a cloud (SaaS) hosted GitHub instance (GitHub Enterprise Cloud Enterprise Managed Users...GHEC EMU)
- You will be using token auth in your local git clients and will need to generate your token in GHEC EMU (two options Fine-grained tokens or Classic)
- If your local client has no local changes you need you can simply do a fresh checkout from GHEC EMU
- If you do have local changes not committed to GHES or GHEC EMU, or if you simply prefer, you can just change you local git remote(s) to point to GHEC EMU in your current local git repos

Repo Admins:
- Determine your window(s) for migrating your repos to GHEC EMU
- For Trial/Dry-runs...got to Sandbox
- For prod...Determine what orgs your repos will be moving to (Internal, Private, Sensitive, Archive)
- In the appropriate org, go to the migrations-via-actions repo and create a new issue
- Follow the instructions of the issue to start migrating your repo(s)
- Once migration is complete...sanity checks
   + At glance, does it all look good...history, commits, issues, prs (opened and closed)
   + Jenkins token, pipelines trigger
   + Webhooks


Stuff to deal with:
- System account sync
- Jenkins token
- Groups in IdP
- User accounts created in GitHub EMU
- Webhooks