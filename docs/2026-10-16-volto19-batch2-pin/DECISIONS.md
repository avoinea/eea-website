# Decizii (în ordine)

1. **Batch extins de la 3 la 6 repo-uri** — user: „dacă ai 6 candidați, fă-le pe toate 6”.
   Override explicit al protocolului de batch-uri de 3 din skill-ul `volto19-green-campaign`.
2. **Subagenți doar pentru diagnoză (read-only)** — 2 × `scout` (selector hero-block,
   lanțul razzle-dev-utils). Aplicarea/push-ul le face părintele (un singur writer/repo).
3. **redirector: `createPortal` din `react-dom`** în loc de declararea dependinței
   `react-portal` — evită sincronizarea `pnpm-lock.yaml` (react-dom e deja peer dep).
4. **hero-block: selector dual V18+V19** în același `cy.get` — testul rulează pe ambele
   stage-uri; un selector doar-V19 rupe V18.
5. **embed-content: `check-ci` 600→1200 + `NODE_OPTIONS=--max-old-space-size=8192`** —
   worker heap = `max(implicit, cerut)`; 4096 era no-op față de implicitul ~4G.
6. **Fără release `volto-eea-chatbot` 4.1.6** (user) — următorul release e major
   (breaking: scos Yarn + Volto 17). În loc de shim: **pin git din branch-ul `volto19`**
   + checkbox de unpin în PR-ul `volto19→develop` (sau merge în ordine + retestare).
   Respinse: shim de `node_modules`, patch-uri, `patchedDependencies`.
7. **Pin git = override cu `github:eea/<repo>#volto19&path:/packages/<repo>`** —
   pnpm suportă subdirectoare de monorepo. A necesitat scoaterea `prepare` din
   pachetele chatbot/searchlib (pnpm tratează pachetele cu `prepare` ca build-required
   și rulează `pnpm install` în checkout → pică pe devDeps `workspace:*`); husky mutat
   în `prepare`-ul de la root-ul fiecărui repo.
8. **Refresh de lock (f19fbe5 / 144558e)** — lock-urile erau deja în urmă față de
   core-ul 19.5.0 (`a424fdb`): `--frozen-lockfile` pica și înainte. Regenerat cu
   pnpm 10.20.0 + `core` clonat la tag-ul 19.5.0 (gitignored). Efect secundar: a adus
   `@eeacms/search` (+ react@17, devDep) în graf — nu a fost cauza #423 (vezi mai jos).
9. **globalsearch React #423: clean install în Dockerfile** (`rm -rf /app/node_modules`
   înainte de `pnpm install`), nu revert la pin sau la shim. Motiv: imaginea de bază are
   un `node_modules` scris de un pnpm vechi (`react-dom@18.2.0_react@18.2.0`); pnpm 10
   adaugă aceleași pachete cu naming nou (`react-dom@18.2.0(react@18.2.0)`) → bundle cu
   două instanțe React → #423. Validat: build izolat local (în afara monorepo-ului)
   trecea; cu o a doua instanță React în arbore pica (`Cannot read properties of null
   (reading 'useEffect')` în `MatomoAppExtra`).
10. **Nu am aplicat clean-install și la policy** — era deja verde; minimal, fără
    schimbări preventive necerute.
