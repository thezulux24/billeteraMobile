# Plan de módulos y tareas — App Finanzas (Flutter + Supabase + FastAPI)

**Fecha:** 2026-02-25  
**Objetivo:** Definir módulos del producto y el backlog de tareas (WBS) para construir el MVP y extensiones.

---

## 0. Convenciones

- **Prioridad:** P0 (crítico MVP), P1 (importante), P2 (mejora), P3 (futuro).
- **Estado:** TODO / DOING / DONE.
- **Definición de Terminado (DoD) general:**
  - Código en rama principal con PR revisada
  - Pruebas mínimas (unit/integration) donde aplique
  - Documentación técnica breve
  - Telemetría/logs básicos (backend)
  - UI consistente con guía visual “Liquid Glass”
  - Paridad funcional validada en iOS y Android para features del sprint

---

## 1. Módulos (alto nivel)

1. **M0 — Fundaciones del proyecto (infra + arquitectura)**
2. **M1 — Autenticación y perfil**
3. **M2 — Modelo de datos y seguridad (Supabase Postgres + RLS + Soft delete)**
4. **M3 — Gestión de activos (Efectivo + Cuentas bancarias)**
5. **M4 — Tarjetas de crédito y deuda**
6. **M5 — Transacciones (Ingresos/Egresos/Pagos a tarjeta/Transferencias) + Categorías**
7. **M6 — Presupuestos + Alertas**
8. **M7 — Dashboard + Analítica + Insights**
9. **M8 — Amortización (planes, tablas, pagos)**
10. **M9 — Asistente IA (chat + contexto financiero)**
11. **M10 — Premium + Pagos + Feature gating**
12. **M11 — QA, Observabilidad, Seguridad y Release**
13. **M12 — Diseño “Liquid Glass” (Design System + UI polish)**

> Nota: M12 aplica transversalmente, pero se lista como módulo para asegurar tareas explícitas de estética.

---

## 2. Backlog por módulos (tareas)

### M0 — Fundaciones del proyecto (P0)
- [ ] (P0) Definir repositorios: `mobile/` (Flutter), `api/` (FastAPI), `infra/` (scripts)  
- [ ] (P0) Configurar CI básico (lint + tests + build) para Flutter y FastAPI
- [ ] (P0) Configurar pipelines de build para iOS y Android desde CI (artefactos por plataforma)
- [ ] (P0) Estructura Flutter por capas (presentation/domain/data) + navegación base
- [ ] (P0) Estructura FastAPI (routers/services/schemas) + versionado `/api/v1`
- [ ] (P0) Variables de entorno y manejo seguro de secrets
- [ ] (P0) Entornos: dev/stage/prod (Supabase projects o schemas separados)
- [ ] (P1) Configurar analytics/crash reporting (opcional según stack)
- [ ] (P1) Configurar feature flags (puede ser simple: tabla + cache)

**Dependencias:** Ninguna (inicio).

---

### M1 — Autenticación y perfil (P0)
- [ ] (P0) Configurar Supabase Auth (email/password)
- [ ] (P0) Pantallas Flutter: onboarding, login, registro, reset password
- [ ] (P0) Manejo de sesión (persistencia token, refresh, logout)
- [ ] (P0) Tabla `profiles` + trigger/función para crear perfil al registrarse
- [ ] (P0) Pantalla: Configuración básica (moneda base, IA on/off)
- [ ] (P1) OAuth Apple/Google (si aplica)
- [ ] (P2) Biometría local (Face ID/Touch ID en iOS + BiometricPrompt en Android) para desbloqueo rápido

**Dependencias:** M0, M2.

---

### M2 — Modelo de datos y seguridad (Supabase + RLS + Soft delete) (P0)
- [ ] (P0) Diseñar esquema DB definitivo (tablas: wallets, accounts, cards, categories, transactions, budgets, etc.)
- [ ] (P0) Implementar soft delete en tablas clave (`deleted_at`, `deleted_by`)
- [ ] (P0) Implementar RLS por `user_id` en todas las tablas
- [ ] (P0) Índices recomendados (por `user_id`, `date`, `category_id`, `deleted_at`)
- [ ] (P0) Migraciones versionadas (SQL) + documentación
- [ ] (P1) Vistas agregadas: `v_balances`, `v_spending_by_category_month`
- [ ] (P1) Auditoría: `created_at`, `updated_at` + triggers de actualización
- [ ] (P2) Papelera/restore (soft restore flows)

**Dependencias:** M0.

---

### M3 — Gestión de activos: efectivo + cuentas bancarias (P0)
- [ ] (P0) CRUD `cash_wallets` (normalmente 1 por usuario, permitir múltiples opcional)
- [ ] (P0) CRUD `bank_accounts`
- [ ] (P0) UI: Listado + detalle + crear/editar (con validaciones)
- [ ] (P0) Cálculo de saldos: inicial + movimientos (vía vista/endpoint agregador)
- [ ] (P1) Transferencias entre cuentas y/o efectivo (si se habilita en v1.1)

**Dependencias:** M1, M2.

---

### M4 — Tarjetas de crédito y deuda (P0)
- [ ] (P0) CRUD `credit_cards` (alias, network, last4, issuer, moneda, cupo opcional)
- [ ] (P0) UI: Listado tarjetas + detalle (deuda actual)
- [ ] (P0) Regla de negocio: gastos en tarjeta aumentan deuda, no bajan activos
- [ ] (P0) Regla de negocio: pagos a tarjeta bajan deuda y bajan activos
- [ ] (P1) Fechas corte/pago y recordatorios (alertas)
- [ ] (P2) Simulador de pago mínimo vs total (premium candidato)

**Dependencias:** M2, M5.

---

### M5 — Transacciones + Categorías (P0)
**Categorías**
- [ ] (P0) Seed de categorías base (comida, transporte, entretenimiento, etc.)
- [ ] (P0) CRUD `categories` (crear/editar/archivar)
- [ ] (P0) UI selector categoría (rápido, con búsqueda)

**Transacciones**
- [ ] (P0) Modelo `transactions` con tipos: income, expense, payment_to_card, transfer
- [ ] (P0) UI: crear transacción (form con validación y UX premium)
- [ ] (P0) UI: listado transacciones con filtros (fecha/categoría/fuente)
- [ ] (P0) Soft delete transacciones + recalcular agregados
- [ ] (P1) Adjuntos/recibos (Supabase Storage)
- [ ] (P2) Reglas automáticas de categorización (por merchant/nota) (premium candidato)

**Dependencias:** M2, M3, M4.

---

### M6 — Presupuestos + Alertas (P0)
- [ ] (P0) Tabla `budgets` (monto, mes, categoría, umbrales)
- [ ] (P0) UI: crear/editar presupuesto mensual
- [ ] (P0) UI: vista progreso presupuesto (barras, percent)
- [ ] (P0) Motor de consumo: gasto del mes por categoría
- [ ] (P0) Disparador alertas (in-app) al 80%/100% con anti-spam (`budget_alerts`)
- [ ] (P1) Notificaciones push (APNs/FCM)
- [ ] (P2) Presupuestos por subcategoría o por merchant (premium candidato)

**Dependencias:** M5, M7 (parcial).

---

### M7 — Dashboard + Analítica + Insights (P0)
- [ ] (P0) Endpoint `GET /dashboard` con métricas base (activos, deudas, neto, resumen mes)
- [ ] (P0) UI dashboard “Liquid Glass”: cards + gráficas (línea/barras/donut)
- [ ] (P0) “Top categorías del mes” + comparación mes anterior
- [ ] (P0) Filtros de periodo (mes/rango)
- [ ] (P1) Insights por reglas (p.ej. “subiste 30% en comida”)
- [ ] (P1) Ahorro/meta (goals) (premium candidato)
- [ ] (P2) Reportes avanzados (YoY, cohortes, heatmaps) (premium candidato)

**Dependencias:** M2, M5.

---

### M8 — Amortización (P1 -> P0 si es parte del MVP)
- [ ] (P1) Tabla `amortization_plans` + `amortization_schedule`
- [ ] (P1) Servicio FastAPI para generar tabla (método francés mínimo)
- [ ] (P1) UI: crear plan (principal, tasa, plazo, inicio, periodicidad)
- [ ] (P1) UI: ver schedule (tabla paginada/scroll) + marcar cuotas pagadas
- [ ] (P1) Al pagar cuota: crear transacción egreso desde efectivo/cuenta
- [ ] (P2) Abonos extra a capital + recalcular schedule (premium candidato)
- [ ] (P2) Métodos alemán/americano (premium candidato)

**Dependencias:** M5, M3.

---

### M9 — Asistente IA (P1)
- [ ] (P1) Selección proveedor IA (Gemini u otro free-tier) + claves y límites
- [ ] (P1) Endpoint FastAPI `/ai/chat` con:
  - redacción de contexto (agregados por periodo)
  - rate limiting por usuario
  - logs de trazabilidad (sin exponer datos sensibles)
- [ ] (P1) UI: chat con historial + “preguntas rápidas”
- [ ] (P1) Controles privacidad IA: `AGGREGATES_ONLY` vs `FULL_TRANSACTIONS`
- [ ] (P2) Insights generados por IA en dashboard (premium candidato)
- [ ] (P2) “Planes de ahorro” sugeridos por IA (premium candidato)

**Dependencias:** M7, M1, M2.

---

### M10 — Premium + Pagos + Feature gating (P1)
- [ ] (P1) Definir plan Premium (features y límites)
- [ ] (P1) Implementar compras in-app (iOS/Android) o Stripe (según estrategia)
- [ ] (P1) Backend: verificación de recibos / estado suscripción
- [ ] (P1) Feature gating en app (bloqueos + upsell elegante)
- [ ] (P2) Exportación CSV/PDF (premium)
- [ ] (P2) Dashboards avanzados (premium)
- [ ] (P2) IA ampliada (premium)

**Dependencias:** M7, M9.

---

### M11 — QA, Observabilidad, Seguridad y Release (P0)
- [ ] (P0) Suite de pruebas mínima (unit + integration) en backend
- [ ] (P0) Tests críticos en Flutter (formularios, cálculos, navegación)
- [ ] (P0) Logging estructurado en FastAPI
- [ ] (P0) Manejo de errores y estados vacíos en UI
- [ ] (P0) Revisión seguridad: RLS, tokens, CORS, rate limit IA
- [ ] (P0) Preparar builds: TestFlight + Internal Testing (Play Console)
- [ ] (P0) Ejecutar smoke tests de release en iOS y Android (dispositivo físico + emulador/simulador)
- [ ] (P1) Monitoreo rendimiento (APM opcional)

**Dependencias:** Todos.

---

### M12 — Diseño “Liquid Glass” (Design System + UI polish) (P0 transversal)
- [ ] (P0) Definir Design System: colores, tipografía, radios, blur, sombras, iconos
- [ ] (P0) Componentes base Flutter:
  - GlassCard, GlassButton, GlassSheet, GlassAppBar
  - Inputs y navegación con adaptación por plataforma (iOS/Android)
  - Animaciones (microinteracciones)
- [ ] (P0) Consistencia: spacing, grid, jerarquía tipográfica
- [ ] (P0) Estados: loading skeletons, empty states premium, error states elegantes
- [ ] (P1) Modo oscuro (recomendado)
- [ ] (P2) Temas personalizables (premium candidato)

**Dependencias:** M0.

---

## 3. Orden recomendado de ejecución (MVP)

**Sprint 0 (base)**
1) M0 + M2 (infra + DB + RLS + soft delete)  
2) M12 (design system base)  

**Sprint 1**
3) M1 (auth + perfil)  
4) M3 (efectivo + cuentas)  

**Sprint 2**
5) M5 (categorías + transacciones)  
6) M4 (tarjetas + pagos a tarjeta)  

**Sprint 3**
7) M6 (presupuestos + alertas in-app)  
8) M7 (dashboard base)  

**Sprint 4 (extensiones)**
9) M8 (amortización)  
10) M9 (asistente IA)  
11) M10 (premium/pagos)  

**Continuo**
12) M11 (QA/release) en paralelo desde Sprint 1

---

## 4. Checklist de “Listo para producción” (release gate)

- [ ] RLS validado (intento de leer datos cruzados falla)
- [ ] Soft delete consistente (listas no muestran eliminados)
- [ ] Dashboard consistente con reglas de tarjeta (deuda vs activos)
- [ ] Alertas no generan spam
- [ ] IA respeta privacy mode + rate limits
- [ ] Crash-free básico + logs de backend sin datos sensibles
- [ ] UI con polish: spacing, blur, rendimiento, dark mode (si aplica)

---
